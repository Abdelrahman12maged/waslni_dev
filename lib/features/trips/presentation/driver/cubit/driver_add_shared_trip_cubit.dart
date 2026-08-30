import 'dart:developer';

import 'package:car_app/core/resources/images_manager.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/usecases/change_offer_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/change_trip_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/create_trip_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_offers_by_trip_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/make_offer_usecase.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_shared_trip_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class DriverAddSharedTripCubit extends Cubit<DriverAddSharedTripState> {
  final CreateTripUseCase _createTripUseCase;
  final MakeOfferUseCase _makeOfferUseCase;
  final ChangeTripStatusUseCase _changeTripStatusUseCase;
  final ChangeOfferStatusUseCase _changeOfferStatusUseCase;
  final GetOffersByTripUseCase _getOffersByTripUseCase;
  final LocalStorage _storage;
  final MapService _mapService;

  DriverAddSharedTripCubit({
    required CreateTripUseCase createTripUseCase,
    required MakeOfferUseCase makeOfferUseCase,
    required ChangeTripStatusUseCase changeTripStatusUseCase,
    required ChangeOfferStatusUseCase changeOfferStatusUseCase,
    required GetOffersByTripUseCase getOffersByTripUseCase,
    required LocalStorage storage,
    required MapService mapService,
  })  : _createTripUseCase = createTripUseCase,
        _makeOfferUseCase = makeOfferUseCase,
        _changeTripStatusUseCase = changeTripStatusUseCase,
        _changeOfferStatusUseCase = changeOfferStatusUseCase,
        _getOffersByTripUseCase = getOffersByTripUseCase,
        _storage = storage,
        _mapService = mapService,
        super(DriverAddSharedTripInitialState()) {
    _initDefaultDateTime();
    _initSeatsFromCar();
  }

  void _initDefaultDateTime() {
    chooseTripDateTime(DateTime.now());
  }

  Future<void> _initSeatsFromCar() async {
    try {
      final box = await Hive.openBox('hive_box');
      final rawData = box.get('user_data');
      if (rawData is Map) {
        dynamic car;
        if (rawData['user'] is Map && rawData['user']['car'] != null) {
          car = rawData['user']['car'];
        } else if (rawData['data'] is Map && rawData['data']['car'] != null) {
          car = rawData['data']['car'];
        } else {
          car = rawData['car'];
        }
        if (car is List && car.isNotEmpty && car[0] is Map) {
          car = car[0];
        }
        if (car is Map && car['seats'] != null) {
          final parsed = int.tryParse(car['seats'].toString());
          if (parsed != null && parsed > 0) {
            numberOfSeats = parsed;
            log('DriverAddSharedTripCubit: Loaded $numberOfSeats seats from car',
                name: 'DriverAddSharedTripCubit');
            emit(DriverAddSharedTripChangeTripTimeState());
            return;
          }
        }
      }
    } catch (e) {
      log('DriverAddSharedTripCubit: Failed to load car seats: $e',
          name: 'DriverAddSharedTripCubit');
    }
    numberOfSeats = 4;
    emit(DriverAddSharedTripChangeTripTimeState());
  }

  static DriverAddSharedTripCubit get(context) => BlocProvider.of(context);

  bool isBottomSheetShown = false;

  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController destinationLocationController =
      TextEditingController();
  final TextEditingController hourController = TextEditingController();
  final TextEditingController minutesController = TextEditingController();
  final TextEditingController periodController = TextEditingController();

  LatLng destLocation = const LatLng(31.963158, 35.930359);

  DateTime selectedDateTime = DateTime.now();
  String selectedDay = DateFormat('EEEE').format(DateTime.now());
  String selecteddate = DateFormat.yMd().format(DateTime.now());
  String tripFullDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String tripFullTime = DateFormat('HH:mm:ss').format(DateTime.now());
  String tripId = '';
  String tripStatus = 'open';

  int numberOfSeats = 0;
  String gender = 'no_preference';

  Set<Marker> userMarkers = {};
  LocationResult? currentLocationResult;

  LatLng? startLatLng;
  LatLng? destinationLatLng;
  LocationResult? startLocationResult;
  LocationResult? destinationLocationResult;

  int currentLocationChooseIndex = 0;

  /// Returns the trip datetime as a UTC ISO-8601 string.
  /// The server accepts this format and sanitizes Arabic digits server-side.
  String get formattedTripDateTime =>
      selectedDateTime.toUtc().toIso8601String();

  void removeMarkers() {
    userMarkers.clear();
    startLatLng = null;
    destinationLatLng = null;
    currentLocationChooseIndex = 0;
    emit(DriverAddSharedTripSetStartAndDestinationLocationState());
  }

  void changeBottomSheetShow([bool? show]) {
    isBottomSheetShown = show ?? !isBottomSheetShown;
    emit(DriverAddSharedTripChangeBottomSheetShowState());
  }

  void chooseTripDateTime(DateTime dt) {
    selectedDateTime = dt;
    selectedDay = DateFormat('EEEE').format(dt);
    selecteddate = DateFormat.yMd().format(dt);
    tripFullDate = DateFormat('yyyy-MM-dd').format(dt);
    tripFullTime = DateFormat('HH:mm:ss').format(dt);

    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    hourController.text = hour12.toString().padLeft(2, '0');
    minutesController.text = dt.minute.toString().padLeft(2, '0');
    periodController.text = dt.hour >= 12 ? 'PM' : 'AM';

    emit(DriverAddSharedTripChangeTripDateState());
  }

  void incrementSeats() {
    if (numberOfSeats < 6) {
      numberOfSeats++;
      emit(DriverAddSharedTripChangeTripTimeState());
    }
  }

  void decrementSeats() {
    if (numberOfSeats > 1) {
      numberOfSeats--;
      emit(DriverAddSharedTripChangeTripTimeState());
    }
  }

  void changeGender(String selectedGender) {
    gender = selectedGender;
    emit(DriverAddSharedTripChangeTripTimeState());
  }

  Future<void> getAddressFromLatLng() async {
    final result = await _mapService.getAddressFromLatLng(destLocation);
    result.fold(
      (failure) => log(failure.message, name: 'getAddressFromLatLng'),
      (locationResult) {
        currentLocationResult = locationResult;
        emit(DriverAddSharedTripSetStartAndDestinationLocationState());
      },
    );
  }

  Future<LatLng?> getCurrentLocation() async {
    final result = await _mapService.getCurrentLocation();
    return result.fold(
      (failure) {
        log(failure.message, name: 'getCurrentLocation');
        return null;
      },
      (latLng) => latLng,
    );
  }

  Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    final result = await _mapService.searchPlaces(query);
    return result.fold(
      (failure) => [],
      (suggestions) => suggestions,
    );
  }

  Future<LocationResult?> getPlaceDetails(String placeId) async {
    final result = await _mapService.getPlaceDetails(placeId);
    return result.fold(
      (failure) => null,
      (locationResult) => locationResult,
    );
  }

  void setStartAndDestinationLocation() async {
    if (currentLocationChooseIndex == 0) {
      startLatLng = destLocation;
      startLocationResult = currentLocationResult;
      startLocationController.text =
          startLocationResult?.displayName ?? 'Unknown Location';
      userMarkers
          .removeWhere((marker) => marker.markerId.value == "sharedtripstart");

      userMarkers.add(
        Marker(
          markerId: const MarkerId("sharedtripstart"),
          position: destLocation,
          icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(24, 24)),
            ImagesManager.mapMarker,
          ),
        ),
      );

      currentLocationChooseIndex = 1;
      emit(DriverAddSharedTripSetStartAndDestinationLocationState());
    } else {
      destinationLatLng = destLocation;
      destinationLocationResult = currentLocationResult;
      destinationLocationController.text =
          destinationLocationResult?.displayName ?? 'Unknown Location';
      userMarkers.removeWhere(
          (marker) => marker.markerId.value == "sharedtripdestination");

      userMarkers.add(
        Marker(
          markerId: const MarkerId("sharedtripdestination"),
          position: destLocation,
          icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(24, 24)),
            ImagesManager.mapFlag,
          ),
        ),
      );

      currentLocationChooseIndex = 0;
      emit(DriverAddSharedTripSetStartAndDestinationLocationState());
    }
  }

  void editStartLocation() {
    if (startLatLng != null) {
      destLocation = startLatLng!;
    }
    startLatLng = null;
    currentLocationChooseIndex = 0;
    userMarkers
        .removeWhere((marker) => marker.markerId.value == "sharedtripstart");
    emit(DriverAddSharedTripSetStartAndDestinationLocationState());
  }

  void editDestinationLocation() {
    if (destinationLatLng != null) {
      destLocation = destinationLatLng!;
    }
    destinationLatLng = null;
    currentLocationChooseIndex = 1;
    userMarkers.removeWhere(
        (marker) => marker.markerId.value == "sharedtripdestination");
    emit(DriverAddSharedTripSetStartAndDestinationLocationState());
  }

  Future<void> createTrip(BuildContext context) async {
    if (startLatLng == null || destinationLatLng == null) return;

    emit(DriverAddSharedTripLoadingState());

    final startLocName = (startLocationResult?.displayName?.isNotEmpty == true)
        ? startLocationResult!.displayName!
        : (startLocationController.text.isNotEmpty
            ? startLocationController.text
            : S.current.currentLocationFallback);
    final destLocName =
        (destinationLocationResult?.displayName?.isNotEmpty == true)
            ? destinationLocationResult!.displayName!
            : (destinationLocationController.text.isNotEmpty
                ? destinationLocationController.text
                : S.current.specifiedDestinationFallback);

    final currentUid = _storage.read(key: 'userid') ??
        _storage.read(key: 'user_id') ??
        _storage.read(key: 'id');

    // Normalize gender: 'no_preference', 'male', 'female'
    final normalizedGender = (gender == 'male' || gender == 'male_only')
        ? 'male'
        : ((gender == 'female' || gender == 'female_only')
            ? 'female'
            : 'no_preference');

    final payload = {
      "from_latitude": startLatLng?.latitude,
      "from_longitude": startLatLng?.longitude,
      "to_latitude": destinationLatLng?.latitude,
      "to_longitude": destinationLatLng?.longitude,
      "from_location_name": startLocName,
      "to_location_name": destLocName,
      "seats": numberOfSeats,
      // "total_seats": numberOfSeats,
      // "available_seats": numberOfSeats,
      "gender_preference": normalizedGender,
      // "prefer_gender": normalizedGender,
      // "gender": normalizedGender,
      "type": "shared",
      "status": "suspended",
      "creation_type": "driver",
      "user_type": "driver",
      "is_driver": 1,
      if (currentUid != null) "driver_id": currentUid,
      "trip_datetime": formattedTripDateTime,
    };

    log('DRIVER ADD SHARED TRIP request data: $payload',
        name: 'createSharedTrip');

    final result = await _createTripUseCase(payload);

    result.fold(
      (failure) {
        emit(DriverAddSharedTripErrorState(failure.message,
            errorCode: (failure as dynamic).errorCode));
      },
      (trip) async {
        destinationLatLng = null;
        startLatLng = null;
        tripId = trip.id.toString();
        _storage.saveString(
            key: 'pending_pricing_trip_id', value: trip.id.toString());

        // Immediately set status on server to 'suspended' until driver submits pricing
        try {
          await _changeTripStatusUseCase(tripId: trip.id, status: 'suspended');
        } catch (e) {
          log('Change initial status to suspended failed: $e',
              name: 'DriverAddSharedTripCubit');
        }

        final suspendedTrip = trip.copyWith(status: TripStatus.suspended);
        emit(DriverAddSharedTripSuccessState(suspendedTrip));
      },
    );
  }

  Future<bool> submitTripPrice({
    required Trip trip,
    required double price,
    String? note,
  }) async {
    try {
      final rawUid = _storage.read(key: 'userid') ??
          _storage.read(key: 'user_id') ??
          _storage.read(key: 'id');
      final driverId = int.tryParse(rawUid?.toString() ?? '') ??
          (trip.driverId ?? trip.driver?.id ?? 0);

      final result = await _makeOfferUseCase(
        offerData: {
          "driver_id": driverId,
          "trip_id": trip.id,
          "note": note ?? '',
          "price": price,
          "percentage": 0.0,
        },
      );

      return await result.fold(
        (failure) {
          log('Submit price error: ${failure.message}',
              name: 'DriverAddSharedTripCubit');
          return false;
        },
        (_) async {
          // 1. Fetch offers and change the driver's offer status to 'accepted'
          try {
            final offersRes = await _getOffersByTripUseCase(trip.id);
            await offersRes.fold(
              (_) async => null,
              (offers) async {
                final myOffers = offers
                    .where((o) =>
                        o.driverId == driverId || o.driver?.id == driverId)
                    .toList();
                if (myOffers.isNotEmpty) {
                  final targetOffer = myOffers.last;
                  await _changeOfferStatusUseCase(
                    offerId: targetOffer.id,
                    status: 'accepted',
                    userId: driverId,
                  );
                }
              },
            );
          } catch (e) {
            log('Change offer status to accepted error: $e',
                name: 'DriverAddSharedTripCubit');
          }

          // 2. Activate the trip by changing status to 'accepted'
          try {
            await _changeTripStatusUseCase(tripId: trip.id, status: 'accepted');
          } catch (e) {
            log('Change trip status to accepted error: $e',
                name: 'DriverAddSharedTripCubit');
          }

          // 3. Mark offer accepted locally and clear pending flag
          _storage.saveString(
              key: 'offer_status_${trip.id}', value: 'accepted');
          await _storage.remove(key: 'pending_pricing_trip_id');
          return true;
        },
      );
    } catch (e) {
      log('Submit price exception: $e', name: 'DriverAddSharedTripCubit');
      return false;
    }
  }

  Future<bool> cancelTrip(int tripId) async {
    try {
      final result = await _changeTripStatusUseCase(
        tripId: tripId,
        status: 'canceled',
      );
      await _storage.remove(key: 'pending_pricing_trip_id');
      return result.fold(
        (failure) {
          log('Cancel trip error: ${failure.message}',
              name: 'DriverAddSharedTripCubit');
          return false;
        },
        (_) => true,
      );
    } catch (e) {
      log('Cancel trip exception: $e', name: 'DriverAddSharedTripCubit');
      await _storage.remove(key: 'pending_pricing_trip_id');
      return false;
    }
  }

  void userAddSharedTrip(BuildContext context) {
    createTrip(context);
  }
}
