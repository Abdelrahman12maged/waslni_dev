import 'dart:developer';

import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart' as entity;
import 'package:car_app/features/trips/domain/usecases/create_trip_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_nearby_shared_trips_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_trip_details_usecase.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_shared_trip_state.dart';
import 'package:car_app/core/resources/images_manager.dart';
import 'package:car_app/core/utils/fare_estimator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class PassengerAddSharedTripCubit extends Cubit<PassengerAddSharedTripState> {
  final CreateTripUseCase _createTripUseCase;
  final GetNearbySharedTripsUseCase _getNearbySharedTrips;
  final GetTripDetailsUseCase _getTripDetails;
  final LocalStorage _storage;
  final MapService _mapService;

  PassengerAddSharedTripCubit({
    required CreateTripUseCase createTripUseCase,
    required GetNearbySharedTripsUseCase getNearbySharedTrips,
    required GetTripDetailsUseCase getTripDetails,
    required LocalStorage storage,
    required MapService mapService,
  })  : _createTripUseCase = createTripUseCase,
        _getNearbySharedTrips = getNearbySharedTrips,
        _getTripDetails = getTripDetails,
        _storage = storage,
        _mapService = mapService,
        super(PassengerAddSharedTripInitialState()) {
    _initDefaultDateTime();
  }

  void _initDefaultDateTime() {
    chooseTripDateTime(DateTime.now());
  }

  static PassengerAddSharedTripCubit get(BuildContext context) =>
      BlocProvider.of<PassengerAddSharedTripCubit>(context);

  bool isBottomSheetShown = false;

  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController destinationLocationController =
      TextEditingController();
  final TextEditingController notesController = TextEditingController();
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

  int numberOfSeats = 1;
  String gender = 'no_preference';

  // Proposed fare & Auto Accept
  double proposedFare = 15.0;
  bool isAutoAcceptEnabled = false;

  Set<Marker> userMarkers = {};
  LocationResult? currentLocationResult;

  LatLng? startLatLng;
  LatLng? destinationLatLng;
  LocationResult? startLocationResult;
  LocationResult? destinationLocationResult;

  int currentLocationChooseIndex = 0;

  /// Returns the trip datetime as a UTC ISO-8601 string.
  /// The server accepts this format and sanitizes Arabic digits server-side.
  String get formattedTripDateTime => selectedDateTime.toUtc().toIso8601String();

  void removeMarkers() {
    userMarkers.clear();
    startLatLng = null;
    destinationLatLng = null;
    currentLocationChooseIndex = 0;
    emit(PassengerAddSharedTripSetStartAndDestinationLocationState());
  }

  void changeBottomSheetShow([bool? show]) {
    isBottomSheetShown = show ?? !isBottomSheetShown;
    emit(PassengerAddSharedTripChangeBottomSheetShowState());
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

    emit(PassengerAddSharedTripChangeTripDateState());
  }

  void incrementSeats() {
    if (numberOfSeats < 6) {
      numberOfSeats++;
      _recalculateEstimatedFare();
      emit(PassengerAddSharedTripChangeTripTimeState());
    }
  }

  void decrementSeats() {
    if (numberOfSeats > 1) {
      numberOfSeats--;
      _recalculateEstimatedFare();
      emit(PassengerAddSharedTripChangeTripTimeState());
    }
  }

  void changeGender(String selectedGender) {
    gender = selectedGender;
    emit(PassengerAddSharedTripChangeTripTimeState());
  }

  void increaseProposedFare([double step = 1.0]) {
    proposedFare += step;
    emit(PassengerAddSharedTripChangeTripTimeState());
  }

  void decreaseProposedFare([double step = 1.0]) {
    if (proposedFare > step) {
      proposedFare -= step;
      emit(PassengerAddSharedTripChangeTripTimeState());
    }
  }

  void toggleAutoAccept(bool value) {
    isAutoAcceptEnabled = value;
    emit(PassengerAddSharedTripChangeTripTimeState());
  }

  void _recalculateEstimatedFare() {
    if (startLatLng != null && destinationLatLng != null) {
      final distanceInMeters = Geolocator.distanceBetween(
        startLatLng!.latitude,
        startLatLng!.longitude,
        destinationLatLng!.latitude,
        destinationLatLng!.longitude,
      );
      final distanceInKm = distanceInMeters / 1000.0;
      final estimate = FareEstimator.estimate(
        vehicleType: entity.VehicleType.car,
        distanceKm: distanceInKm,
        durationMinutes: (distanceInKm / 35.0) * 60.0,
      );
      proposedFare = (estimate.referencePrice * numberOfSeats)
          .roundToDouble()
          .clamp(5.0, 9999.0);
    }
  }

  Future<void> getAddressFromLatLng() async {
    final result = await _mapService.getAddressFromLatLng(destLocation);
    result.fold(
      (failure) => log(failure.message, name: 'getAddressFromLatLng'),
      (locationResult) {
        currentLocationResult = locationResult;
        emit(PassengerAddSharedTripSetStartAndDestinationLocationState());
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
          icon: await BitmapDescriptor.asset(
            const ImageConfiguration(size: Size(24, 24)),
            ImagesManager.mapMarker,
          ),
        ),
      );

      currentLocationChooseIndex = 1;
      _recalculateEstimatedFare();
      emit(PassengerAddSharedTripSetStartAndDestinationLocationState());
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
          icon: await BitmapDescriptor.asset(
            const ImageConfiguration(size: Size(24, 24)),
            ImagesManager.mapFlag,
          ),
        ),
      );

      currentLocationChooseIndex = 0;
      _recalculateEstimatedFare();
      emit(PassengerAddSharedTripSetStartAndDestinationLocationState());
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
    emit(PassengerAddSharedTripSetStartAndDestinationLocationState());
  }

  void editDestinationLocation() {
    if (destinationLatLng != null) {
      destLocation = destinationLatLng!;
    }
    destinationLatLng = null;
    currentLocationChooseIndex = 1;
    userMarkers.removeWhere(
        (marker) => marker.markerId.value == "sharedtripdestination");
    emit(PassengerAddSharedTripSetStartAndDestinationLocationState());
  }

  Future<void> createTrip(BuildContext context,
      {bool bypassSearch = false}) async {
    if (startLatLng == null || destinationLatLng == null) return;

    final distanceMeters = Geolocator.distanceBetween(
      startLatLng!.latitude,
      startLatLng!.longitude,
      destinationLatLng!.latitude,
      destinationLatLng!.longitude,
    );
    if (distanceMeters < 80) {
      emit(PassengerAddSharedTripErrorState(
        S.current.originAndDestinationCannotBeSame,
      ));
      return;
    }

    emit(PassengerAddSharedTripLoadingState());

    // ─── Step 1: Pre-search for existing matching trips ───────────────────────
    if (!bypassSearch) {
      try {
        final tripDatetimeUtc = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
            .format(selectedDateTime.toUtc());
        final searchResult = await _getNearbySharedTrips(
          fromLat: startLatLng!.latitude,
          fromLng: startLatLng!.longitude,
          toLat: destinationLatLng?.latitude,
          toLng: destinationLatLng?.longitude,
          tripDatetime: tripDatetimeUtc,
          originRadiusKm: 3.0,
          destinationRadiusKm: 3.0,
          timeWindowHours: 2.0,
        );

        final matchingTrips = searchResult.fold(
          (_) => <entity.Trip>[],
          (trips) => trips,
        );

        final validMatches = <entity.Trip>[];
        for (final trip in matchingTrips) {
          if (trip.status == entity.TripStatus.canceled ||
              trip.status == entity.TripStatus.completed) {
            continue;
          }
          final totalSeats = trip.totalSeats > 0 ? trip.totalSeats : 4;
          final reserved = trip.reservedSeats > 0
              ? trip.reservedSeats
              : (trip.passengers.isNotEmpty
                  ? trip.passengers
                      .fold<int>(0, (s, p) => s + (p.seats > 0 ? p.seats : 1))
                  : (trip.availableSeats >= 0 && totalSeats > trip.availableSeats
                      ? totalSeats - trip.availableSeats
                      : 0));
          final avail = trip.availableSeats >= 0
              ? trip.availableSeats
              : (totalSeats - reserved).clamp(0, totalSeats);

          if (avail >= numberOfSeats) {
            validMatches.add(trip);
          }
        }

        if (validMatches.isNotEmpty) {
          // Enrich top match
          entity.Trip bestMatch = validMatches.first;
          final detailRes = await _getTripDetails(bestMatch.id);
          detailRes.fold((_) {}, (enriched) => bestMatch = enriched);

          emit(PassengerAddSharedTripMatchingTripFoundState(
            matchingTrip: bestMatch,
            allMatchingTrips: validMatches,
          ));
          return;
        }
      } catch (e) {
        log('Error during pre-trip search check: $e',
            name: 'PassengerAddSharedTripCubit');
      }
    }

    // ─── Step 2: Create New Shared Trip ──────────────────────────────────────
    await _executeCreateTrip(context);
  }

  Future<void> _executeCreateTrip(BuildContext context) async {
    final startLocName = (startLocationResult?.displayName.isNotEmpty == true)
        ? startLocationResult!.displayName
        : (startLocationController.text.isNotEmpty
            ? startLocationController.text
            : S.current.currentLocationFallback);
    final destLocName =
        (destinationLocationResult?.displayName.isNotEmpty == true)
            ? destinationLocationResult!.displayName
            : (destinationLocationController.text.isNotEmpty
                ? destinationLocationController.text
                : S.current.specifiedDestinationFallback);

    final rawUserType = _storage.read(key: 'usertype')?.toString();
    final creationType = (rawUserType != null && rawUserType.isNotEmpty)
        ? rawUserType
        : 'passenger';
    final notes = notesController.text.trim();

    final payload = {
      "from_latitude": startLatLng?.latitude,
      "from_longitude": startLatLng?.longitude,
      "to_latitude": destinationLatLng?.latitude,
      "to_longitude": destinationLatLng?.longitude,
      "from_location_name": startLocName,
      "to_location_name": destLocName,
      "seats": numberOfSeats,
      "gender_preference": gender,
      "type": "shared",
      "creation_type": creationType,
      "trip_datetime": formattedTripDateTime,
      if (notes.isNotEmpty) "trip_details": notes,
    };

    log('PASSENGER ADD SHARED TRIP request data: $payload',
        name: 'createSharedTrip');

    final result = await _createTripUseCase(payload);

    result.fold(
      (failure) {
        emit(PassengerAddSharedTripErrorState(failure.message,
            errorCode: (failure as dynamic).errorCode));
      },
      (trip) {
        destinationLatLng = null;
        startLatLng = null;
        tripId = trip.id.toString();
        emit(PassengerAddSharedTripSuccessState(trip));
      },
    );
  }

  void userAddSharedTrip(BuildContext context) {
    createTrip(context);
  }

  void forceCreateTrip(BuildContext context) {
    createTrip(context, bypassSearch: true);
  }
}
