import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:car_app/features/trips/domain/usecases/change_passenger_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/create_trip_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_trip_details_usecase.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/widgets/components.dart';
import 'dart:developer';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_private_trip_state.dart';
import 'package:car_app/core/resources/images_manager.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class PassengerAddPrivateTripCubit extends Cubit<PassengerAddPrivateTripState> {
  final LocalStorage _storage;
  final MapService _mapService;
  final CreateTripUseCase _createTripUseCase;
  final GetTripDetailsUseCase _getTripDetailsUseCase;
  final ChangePassengerStatusUseCase _changePassengerStatusUseCase;

  PassengerAddPrivateTripCubit({
    required LocalStorage storage,
    required MapService mapService,
    required CreateTripUseCase createTripUseCase,
    required GetTripDetailsUseCase getTripDetailsUseCase,
    required ChangePassengerStatusUseCase changePassengerStatusUseCase,
  })  : _storage = storage,
        _mapService = mapService,
        _createTripUseCase = createTripUseCase,
        _getTripDetailsUseCase = getTripDetailsUseCase,
        _changePassengerStatusUseCase = changePassengerStatusUseCase,
        super(PassengerAddPrivateTripInitialState()) {
    _initDefaultDateTime();
  }

  void _initDefaultDateTime() {
    chooseTripDateTime(DateTime.now());
  }

  static PassengerAddPrivateTripCubit get(context) => BlocProvider.of(context);

  bool isBottomSheetShown = false;
  bool isPassengersIn = false;
  int PassengersCountIn = 0;

  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController destinationLocationController =
      TextEditingController();
  final TextEditingController hourController = TextEditingController();
  final TextEditingController minutesController = TextEditingController();
  final TextEditingController periodController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String gender = 'no_preference';
  int numberOfSeats = 1;
  double proposedFare = 15.0;
  bool isAutoAcceptEnabled = false;

  void setProposedFare(double fare) {
    if (fare > 0) {
      proposedFare = fare;
      emit(PassengerAddPrivateTripChangeFareState());
    }
  }

  void incrementFare([double step = 1.0]) {
    proposedFare += step;
    emit(PassengerAddPrivateTripChangeFareState());
  }

  void decrementFare([double step = 1.0]) {
    if (proposedFare > step) {
      proposedFare -= step;
      emit(PassengerAddPrivateTripChangeFareState());
    }
  }

  void toggleAutoAccept(bool val) {
    isAutoAcceptEnabled = val;
    emit(PassengerAddPrivateTripToggleAutoAcceptState());
  }

  LatLng destLocation = const LatLng(31.963158, 35.930359);
  LatLng destLocationOngoingStart = const LatLng(31.963158, 35.930359);
  LatLng destLocationOngoingEnd = const LatLng(31.963158, 35.930359);

  String OnGoingTripStatus = 'start';
  DateTime selectedDateTime = DateTime.now();
  String selectedDay = DateFormat('EEEE').format(DateTime.now());
  String selecteddate = DateFormat.yMd().format(DateTime.now());
  String tripFullDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String tripFullTime = DateFormat('HH:mm:ss').format(DateTime.now());
  String tripId = '';
  String tripStatus = 'open';

  /// Returns the trip datetime as a UTC ISO-8601 string.
  /// The server accepts this format and sanitizes Arabic digits server-side.
  String get formattedTripDateTime => selectedDateTime.toUtc().toIso8601String();

  Set<Marker> userMarkers = {};
  LocationResult? currentLocationResult;

  LatLng? startLatLng;
  LatLng? destinationLatLng;

  LocationResult? startLocationResult;
  LocationResult? destinationLocationResult;

  int currentLocationChooseIndex = 0;

  void changeBottomSheetShow() {
    isBottomSheetShown = !isBottomSheetShown;
    emit(PassengerAddPrivateTripChangeBottomSheetShowState());
  }

  void removeMarkers() {
    userMarkers.clear();
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

    emit(PassengerAddPrivateTripChangeTripDateState());
  }

  void chooseTripDate(
      String userSelectedDay, String userSelectedDate, String userFullDate) {
    selectedDay = userSelectedDay;
    selecteddate = userSelectedDate;
    tripFullDate = userFullDate;
    emit(PassengerAddPrivateTripChangeTripDateState());
  }

  void chooseTripTime(String hour, String minute, String period) {
    final lowerPeriod = period.toLowerCase();
    final hourInt = int.tryParse(hour) ?? 0;
    int hour24 = hourInt;
    if (lowerPeriod == 'am' && hourInt == 12) hour24 = 0;
    if (lowerPeriod == 'pm' && hourInt != 12) hour24 = hourInt + 12;

    final minStr = minute.padLeft(2, '0');
    final hourStr = hour24.toString().padLeft(2, '0');

    hourController.text = hourInt < 10 ? '0$hourInt' : '$hourInt';
    minutesController.text = minStr;
    periodController.text = period.toUpperCase();
    tripFullTime = '$hourStr:$minStr:00';

    // Rebuild selectedDateTime from the new time components and the existing date
    final parts = tripFullDate.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]) ?? selectedDateTime.year;
      final m = int.tryParse(parts[1]) ?? selectedDateTime.month;
      final d = int.tryParse(parts[2]) ?? selectedDateTime.day;
      selectedDateTime = DateTime(y, m, d, hour24, int.tryParse(minStr) ?? 0);
    }

    emit(PassengerAddPrivateTripChangeTripTimeState());
  }

  void changeGender(String newGender) {
    gender = newGender;
    emit(PassengerAddPrivateTripChangeGenderState());
  }

  void incrementSeats() {
    if (numberOfSeats < 6) {
      numberOfSeats++;
      emit(PassengerAddPrivateTripChangeSeatsState());
    }
  }

  void decrementSeats() {
    if (numberOfSeats > 1) {
      numberOfSeats--;
      emit(PassengerAddPrivateTripChangeSeatsState());
    }
  }

  Future<void> getAddressFromLatLng() async {
    final result = await _mapService.getAddressFromLatLng(destLocation);
    result.fold(
      (failure) => log(failure.message, name: 'getAddressFromLatLng'),
      (locationResult) {
        currentLocationResult = locationResult;
        emit(PassengerAddPrivateTripSetStartAndDestinationLocationState());
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
          .removeWhere((marker) => marker.markerId.value == "privatetripstart");

      userMarkers.add(
        Marker(
          markerId: const MarkerId("privatetripstart"),
          position: destLocation,
          icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(24, 24)),
            ImagesManager.mapMarker,
          ),
        ),
      );

      currentLocationChooseIndex = 1;
      emit(PassengerAddPrivateTripSetStartAndDestinationLocationState());
    } else {
      destinationLatLng = destLocation;
      destinationLocationResult = currentLocationResult;
      destinationLocationController.text =
          destinationLocationResult?.displayName ?? 'Unknown Location';
      userMarkers.removeWhere(
          (marker) => marker.markerId.value == "privatetripdestination");
      userMarkers.add(
        Marker(
          markerId: const MarkerId("privatetripdestination"),
          position: destLocation,
          icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(24, 24)),
            ImagesManager.mapFlag,
          ),
        ),
      );

      currentLocationChooseIndex = 0;
      emit(PassengerAddPrivateTripSetStartAndDestinationLocationState());
    }
  }

  void editStartLocation() {
    if (startLatLng != null) {
      destLocation = startLatLng!;
    }
    startLatLng = null;
    currentLocationChooseIndex = 0;
    userMarkers
        .removeWhere((marker) => marker.markerId.value == "privatetripstart");
    emit(PassengerAddPrivateTripSetStartAndDestinationLocationState());
  }

  void editDestinationLocation() {
    if (destinationLatLng != null) {
      destLocation = destinationLatLng!;
    }
    destinationLatLng = null;
    currentLocationChooseIndex = 1;
    userMarkers.removeWhere(
        (marker) => marker.markerId.value == "privatetripdestination");
    emit(PassengerAddPrivateTripSetStartAndDestinationLocationState());
  }

  Future<void> setPresetDestination({
    required String name,
    required double lat,
    required double lng,
  }) async {
    final targetLatLng = LatLng(lat, lng);
    destinationLatLng = targetLatLng;
    destinationLocationResult = LocationResult(
      address: name,
      latitude: lat,
      longitude: lng,
    );
    destinationLocationController.text = name;

    userMarkers.removeWhere(
        (marker) => marker.markerId.value == "privatetripdestination");
    userMarkers.add(
      Marker(
        markerId: const MarkerId("privatetripdestination"),
        position: targetLatLng,
        icon: await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(24, 24)),
          ImagesManager.mapFlag,
        ),
      ),
    );

    currentLocationChooseIndex = 0;
    emit(PassengerAddPrivateTripSetStartAndDestinationLocationState());
  }

  Future<void> setupTripWithPresetDestination({
    required String destinationName,
    required double destinationLat,
    required double destinationLng,
  }) async {
    // 1. Set Destination Point
    final destTarget = LatLng(destinationLat, destinationLng);
    destinationLatLng = destTarget;
    destinationLocationResult = LocationResult(
      address: destinationName,
      latitude: destinationLat,
      longitude: destinationLng,
    );
    destinationLocationController.text = destinationName;

    userMarkers.removeWhere(
        (marker) => marker.markerId.value == "privatetripdestination");
    userMarkers.add(
      Marker(
        markerId: const MarkerId("privatetripdestination"),
        position: destTarget,
        icon: await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(24, 24)),
          ImagesManager.mapFlag,
        ),
      ),
    );

    // 2. Set Current Location as Start Point automatically
    final currentPos = await getCurrentLocation();
    if (currentPos != null) {
      startLatLng = currentPos;
      destLocation = currentPos;

      final geoResult = await _mapService.getAddressFromLatLng(currentPos);
      String startName = S.current.currentLocationFallback;
      geoResult.fold(
        (_) {},
        (res) {
          startLocationResult = res;
          startName = res.displayName;
        },
      );
      startLocationResult ??= LocationResult(
        address: startName,
        latitude: currentPos.latitude,
        longitude: currentPos.longitude,
      );
      startLocationController.text = startName;

      userMarkers.removeWhere(
          (marker) => marker.markerId.value == "privatetripstart");
      userMarkers.add(
        Marker(
          markerId: const MarkerId("privatetripstart"),
          position: currentPos,
          icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(24, 24)),
            ImagesManager.mapMarker,
          ),
        ),
      );
    }

    currentLocationChooseIndex = 0;
    emit(PassengerAddPrivateTripSetStartAndDestinationLocationState());
  }

  Future<void> createTrip(BuildContext context) async {
    if (startLatLng == null || destinationLatLng == null) return;

    final distanceMeters = Geolocator.distanceBetween(
      startLatLng!.latitude,
      startLatLng!.longitude,
      destinationLatLng!.latitude,
      destinationLatLng!.longitude,
    );
    if (distanceMeters < 80) {
      emit(PassengerAddPrivateTripErrorState(
        S.current.originAndDestinationCannotBeSame,
      ));
      return;
    }

    emit(PassengerAddPrivateTripLoadingState());

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

    final payload = {
      "from_latitude": startLatLng?.latitude,
      "from_longitude": startLatLng?.longitude,
      "to_latitude": destinationLatLng?.latitude,
      "to_longitude": destinationLatLng?.longitude,
      "from_location_name": startLocName,
      "to_location_name": destLocName,
      "number_of_seats": "1",
      "gender_preference": gender,
      "type": "private",
      "creation_type": creationType,
      "trip_datetime": formattedTripDateTime,
    
      if (notesController.text.isNotEmpty)
        "trip_details": notesController.text,
    };

    log('PASSENGER ADD PRIVATE TRIP request data: $payload', name: 'createTrip');

    final result = await _createTripUseCase(payload);

    result.fold(
      (failure) {
        emit(PassengerAddPrivateTripErrorState(failure.message,
            errorCode: (failure as dynamic).errorCode));
      },
      (trip) {
        destinationLatLng = null;
        startLatLng = null;
        tripId = trip.id.toString();
        emit(PassengerAddPrivateTripSuccessState(trip));
      },
    );
  }

  static const emptyFunction = null;

  void setStartAndDestinationLocationOnGoingTripShared({
    dynamic tripDetails,
    dynamic updateTripDetails = emptyFunction,
    bool isTripUpdate = false,
  }) async {
    if (tripDetails == null) return;
    final Trip? trip = tripDetails is Trip
        ? tripDetails
        : (tripDetails is Map ? Trip.fromMap(Map<String, dynamic>.from(tripDetails)) : null);
    if (trip == null) return;

    startLocationController.text = trip.fromLocationName;
    destinationLocationController.text = trip.toLocationName;
    removeMarkers();
    userMarkers.add(
      Marker(
        markerId: const MarkerId("privatetripstart"),
        position: LatLng(trip.fromLatitude, trip.fromLongitude),
      ),
    );
    userMarkers.add(
      Marker(
        markerId: const MarkerId("privatetripdestination"),
        position: LatLng(trip.toLatitude, trip.toLongitude),
      ),
    );
    emit(PassengerAddPrivateTripSetStartAndDestinationLocationState());
  }

  void setStartAndDestinationLocationOnGoingTrip({
    dynamic tripDetails,
    dynamic updateTripDetails = emptyFunction,
    bool isTripUpdate = false,
  }) async {
    setStartAndDestinationLocationOnGoingTripShared(
      tripDetails: tripDetails,
      updateTripDetails: updateTripDetails,
      isTripUpdate: isTripUpdate,
    );
  }

  Future<void> getTripsDetails({
    dynamic stoploading = emptyFunction,
    bool? isThisLoading,
    dynamic tripId,
  }) async {
    if (tripId == null) return;
    final idInt = int.tryParse(tripId.toString());
    if (idInt == null) return;
    try {
      final res = await _getTripDetailsUseCase(idInt);
      res.fold(
        (failure) => emit(PassengerAddPrivateTripErrorState(failure.message)),
        (trip) {
          tripStatus = trip.status.name;
          if (stoploading is Function) stoploading(trip);
          setStartAndDestinationLocationOnGoingTrip(tripDetails: trip);
        },
      );
    } catch (e) {
      log(e.toString(), name: 'getTripsDetails');
    }
  }

  void userAddPrivateTrip(Map details, {BuildContext? context}) {
    if (context != null) {
      createTrip(context);
    }
  }

  Future<void> changePassengerStatus({
    dynamic context,
    dynamic id,
    dynamic trip_id,
    dynamic PassState,
    dynamic in_car,
  }) async {
    final resolvedTripId = trip_id ?? int.tryParse(id?.toString() ?? '') ?? 0;
    final resolvedInCar = in_car ?? 0;
    final resolvedPassState = PassState?.toString();
    try {
      final res = await _changePassengerStatusUseCase(
        tripId: resolvedTripId,
        inCar: resolvedInCar,
        passState: resolvedPassState,
      );
      res.fold(
        (failure) => emit(PassengerAddPrivateTripErrorState(failure.message)),
        (_) {
          if (context is BuildContext) {
            successDialoug(context, S.of(context).updatedSuccessfully);
          }
        },
      );
    } catch (e) {
      log(e.toString(), name: 'changePassengerStatus');
    }
  }
}
