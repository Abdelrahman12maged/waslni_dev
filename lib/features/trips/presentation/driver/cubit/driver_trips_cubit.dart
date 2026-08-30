import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/generated/l10n.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:car_app/core/network/api_client.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/data/models/trip_model.dart';
import 'package:car_app/features/trips/domain/usecases/change_offer_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/change_trip_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/create_trip_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_driver_trips_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_trip_details_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_trips_near_me_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_offers_by_trip_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/make_offer_usecase.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:car_app/core/services/driver_location_tracker_service.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/features/chat/data/datasources/chat_remote_datasource.dart';

/// Manages all driver trip interactions.
class DriverTripsCubit extends Cubit<DriverTripsState> {
  final GetDriverTripsUseCase _getDriverTrips;
  final ChangeTripStatusUseCase _changeTripStatus;
  final ChangeOfferStatusUseCase? _changeOfferStatus;
  final GetTripDetailsUseCase _getTripDetails;
  final GetTripsNearMeUseCase _getTripsNearMe;
  final CreateTripUseCase _createTrip;
  final MakeOfferUseCase _makeOffer;
  final GetOffersByTripUseCase? _getOffersByTrip;
  final LocalStorage _storage;
  final ApiClient _client;

  DriverTripsCubit({
    required GetDriverTripsUseCase getDriverTrips,
    required ChangeTripStatusUseCase changeTripStatus,
    ChangeOfferStatusUseCase? changeOfferStatus,
    required GetTripDetailsUseCase getTripDetails,
    required GetTripsNearMeUseCase getTripsNearMe,
    required CreateTripUseCase createTrip,
    required MakeOfferUseCase makeOffer,
    GetOffersByTripUseCase? getOffersByTrip,
    required LocalStorage storage,
    required ApiClient client,
  })  : _getDriverTrips = getDriverTrips,
        _changeTripStatus = changeTripStatus,
        _changeOfferStatus = changeOfferStatus,
        _getTripDetails = getTripDetails,
        _getTripsNearMe = getTripsNearMe,
        _createTrip = createTrip,
        _makeOffer = makeOffer,
        _getOffersByTrip = getOffersByTrip,
        _storage = storage,
        _client = client,
        super(const DriverTripsInitial());

  static DriverTripsCubit of(BuildContext context) =>
      BlocProvider.of<DriverTripsCubit>(context);

  static DriverTripsCubit get(BuildContext context) => of(context);

  // ─── Legacy Compatibility Lists ──────────────────────────────────────────
  List<Trip> TripsListByTypePrivete = [];
  List<Trip> TripsListByTypeShared = [];

  List TripsListByTypeCurrentPrivete = [];
  List TripsListByTypeCompletedPrivete = [];
  List TripsListByTypeSuspendedPrivete = [];
  List TripsListByTypeCanceledPrivete = [];

  List TripsListByTypeCurrentShared = [];
  List TripsListByTypeCompletedShared = [];
  List TripsListByTypeSuspendedShared = [];
  List TripsListByTypeCanceledShared = [];

  Map TripsListByTypeTotals = {
    "open": 0,
    "closed": 0,
    "completed": 0,
    "accepted": 0,
    "canceled": 0,
    "suspended": 0
  };

  // ─── User ID helper ───────────────────────────────────────────────────────
  int get _userId {
    final raw = _storage.read(key: 'userid') ??
        _storage.read(key: 'user_id') ??
        _storage.read(key: 'id');
    final parsed = int.tryParse(raw?.toString() ?? '');
    if (parsed != null && parsed != 0) return parsed;
    try {
      if (Hive.isBoxOpen('hive_box')) {
        final box = Hive.box('hive_box');
        final userData = box.get('user_data');
        if (userData is Map) {
          final userObj = userData['user'] is Map ? userData['user'] : userData;
          if (userObj is Map) {
            final hiveId = int.tryParse(userObj['id']?.toString() ?? '');
            if (hiveId != null && hiveId != 0) return hiveId;
          }
        }
      }
    } catch (_) {}
    return 0;
  }

  // ─── Load Trips ───────────────────────────────────────────────────────────
  Future<void> loadDriverTrips() async {
    emit(const DriverTripsLoading());

    final result = await _getDriverTrips(_userId);
    result.fold(
      (failure) {
        log(failure.message, name: 'DriverTripsCubit.loadDriverTrips');
        emit(DriverTripsError(failure.message));
      },
      (trips) {
        TripsListByTypeCurrentPrivete = [];
        TripsListByTypeCompletedPrivete = [];
        TripsListByTypeSuspendedPrivete = [];
        TripsListByTypeCanceledPrivete = [];

        TripsListByTypeCurrentShared = [];
        TripsListByTypeCompletedShared = [];
        TripsListByTypeSuspendedShared = [];
        TripsListByTypeCanceledShared = [];

        Trip? activeAssignedTrip;

        for (final trip in trips) {
          final isPrivate = trip.type == TripType.private;

          switch (trip.status) {
            case TripStatus.open:
              final isDriverCreated = trip.createdBy == _userId;
              if (!isPrivate && isDriverCreated) {
                if (trip.isStale) {
                  TripsListByTypeCanceledShared.add(trip);
                } else {
                  TripsListByTypeCurrentShared.add(trip);
                }
              }
              break;

            case TripStatus.accepted:
              final isAssigned =
                  (trip.driverId == _userId || trip.driver?.id == _userId);
              if (isAssigned) {
                if (trip.isStale) {
                  isPrivate
                      ? TripsListByTypeCanceledPrivete.add(trip)
                      : TripsListByTypeCanceledShared.add(trip);
                } else {
                  if (activeAssignedTrip == null &&
                      TripSecurityService.isPreTripTrackingActive(trip)) {
                    activeAssignedTrip = trip;
                  }
                  isPrivate
                      ? TripsListByTypeCurrentPrivete.add(trip)
                      : TripsListByTypeCurrentShared.add(trip);
                }
              }
              break;

            case TripStatus.completed:
              isPrivate
                  ? TripsListByTypeCompletedPrivete.add(trip)
                  : TripsListByTypeCompletedShared.add(trip);
              break;
            case TripStatus.suspended:
              isPrivate
                  ? TripsListByTypeSuspendedPrivete.add(trip)
                  : TripsListByTypeSuspendedShared.add(trip);
              break;
            case TripStatus.canceled:
            case TripStatus.closed:
              isPrivate
                  ? TripsListByTypeCanceledPrivete.add(trip)
                  : TripsListByTypeCanceledShared.add(trip);
              break;
          }
        }

        if (activeAssignedTrip != null) {
          DriverLocationTrackerService.instance.startTracking(
            trip: activeAssignedTrip,
            storage: _storage,
          );
        } else {
          DriverLocationTrackerService.instance.stopTracking(_storage);
          TripSecurityService.clearActiveTrip(_storage);
        }
        emit(_categorize(trips));
      },
    );
  }

  /// Categorizes all trips.
  DriverTripsLoaded _categorize(List<Trip> trips) {
    final currentPrivate = <Trip>[];
    final completedPrivate = <Trip>[];
    final suspendedPrivate = <Trip>[];
    final canceledPrivate = <Trip>[];

    final currentShared = <Trip>[];
    final completedShared = <Trip>[];
    final suspendedShared = <Trip>[];
    final canceledShared = <Trip>[];

    for (final trip in trips) {
      final isPrivate = trip.type == TripType.private;
      final isStale = trip.isStale;
      final effectiveStatus = isStale ? TripStatus.closed : trip.status;

      switch (effectiveStatus) {
        case TripStatus.open:
          final isDriverCreated = trip.createdBy == _userId;
          if (!isPrivate && isDriverCreated) {
            currentShared.add(trip);
          }
          break;
        case TripStatus.accepted:
          final isAssigned =
              (trip.driverId == _userId || trip.driver?.id == _userId);
          if (isAssigned) {
            isPrivate ? currentPrivate.add(trip) : currentShared.add(trip);
          }
          break;
        case TripStatus.completed:
          isPrivate ? completedPrivate.add(trip) : completedShared.add(trip);
          break;
        case TripStatus.suspended:
          isPrivate ? suspendedPrivate.add(trip) : suspendedShared.add(trip);
          break;
        case TripStatus.canceled:
        case TripStatus.closed:
          isPrivate ? canceledPrivate.add(trip) : canceledShared.add(trip);
          break;
      }
    }

    return DriverTripsLoaded(
      currentPrivate: currentPrivate,
      completedPrivate: completedPrivate,
      suspendedPrivate: suspendedPrivate,
      canceledPrivate: canceledPrivate,
      currentShared: currentShared,
      completedShared: completedShared,
      suspendedShared: suspendedShared,
      canceledShared: canceledShared,
    );
  }

  // ─── Legacy Compatibility Methods ─────────────────────────────────────────
  void getDriverTrips(
      {Function? stoploading, bool isThisLoading = true}) async {
    await loadDriverTrips();
    if (stoploading != null) {
      stoploading();
    }
  }

  double? _cachedLat;
  double? _cachedLng;
  double _selectedRadius = 5;

  double get selectedRadius {
    final saved = _storage.read(key: 'driver_search_radius');
    if (saved != null) {
      final parsed = double.tryParse(saved.toString());
      if (parsed != null && parsed > 0) return parsed;
    }
    return _selectedRadius;
  }

  set selectedRadius(double val) {
    _selectedRadius = val;
    _storage.saveString(
        key: 'driver_search_radius', value: val.toInt().toString());
  }

  DateTime? selectedDate;

  void updateSearchFilters({
    double? radius,
    DateTime? date,
    bool clearDate = false,
    Function? stoploading,
  }) {
    if (radius != null) selectedRadius = radius;
    if (clearDate) {
      selectedDate = null;
    } else if (date != null) {
      selectedDate = date;
    }
    getDriverTripsByTypes(stoploading: stoploading);
  }

  bool _isFetchingTripsByTypes = false;

  void getDriverTripsByTypes({
    Function? stoploading,
    bool? isLoading,
    double? customRadius,
    DateTime? customDate,
  }) async {
    if (_isFetchingTripsByTypes) return;
    _isFetchingTripsByTypes = true;

    try {
      if (customRadius != null) selectedRadius = customRadius;
      if (customDate != null) selectedDate = customDate;

      if (isLoading != false) {
        emit(const DriverTripsLoading());
      }

      // Attempt to get real driver location with cached/default fallback
      double lat = _cachedLat ?? 31.9454;
      double lng = _cachedLng ?? 35.9284;

      final lastLat = _storage.read(key: 'driver_last_latitude');
      final lastLng = _storage.read(key: 'driver_last_longitude');
      if (_cachedLat == null && lastLat != null && lastLng != null) {
        lat = double.tryParse(lastLat.toString()) ?? lat;
        lng = double.tryParse(lastLng.toString()) ?? lng;
        _cachedLat = lat;
        _cachedLng = lng;
      }

      try {
        final pos = await _getCurrentPosition();
        if (pos != null) {
          log("posssssssssssssss == ${pos.latitude} ${pos.longitude}");
          lat = pos.latitude;
          lng = pos.longitude;
          _cachedLat = lat;
          _cachedLng = lng;
          _storage.saveString(
              key: 'driver_last_latitude', value: lat.toString());
          _storage.saveString(
              key: 'driver_last_longitude', value: lng.toString());
        }
      } catch (e) {
        log('Failed to get GPS location for nearby trips: $e',
            name: 'DriverTripsCubit');
      }

      final dateStr = selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
          : null;

      final activeRadius = selectedRadius;

      // Get new open trips created by passengers with selected radius and date
      final result = await _getTripsNearMe(
        lat: lat,
        lng: lng,
        creationType: 'passenger',
        radius: activeRadius.toInt().toString(),
        status: 'open',
        date: dateStr,
      );

      result.fold(
        (failure) {
          log(failure.message, name: 'DriverTripsCubit.getDriverTripsByTypes');
          emit(DriverTripsError(failure.message));
          if (stoploading != null) stoploading();
        },
        (trips) {
          log("selected radius for near trips = $selectedRadius --- $lat --- $lng");

          _populateLegacyLists(trips);
          emit(_categorize(trips));
          if (stoploading != null) stoploading();
          _fetchOffersForTrips(trips);
        },
      );
    } finally {
      _isFetchingTripsByTypes = false;
    }
  }

  Future<void> _fetchOffersForTrips(List<Trip> trips) async {
    if (_getOffersByTrip == null) return;
    final currentUid = _userId;
    if (currentUid == 0) return;
    bool hasUpdates = false;
    for (final trip in trips) {
      if (trip.status != TripStatus.open) continue;
      try {
        final res = await _getOffersByTrip!(trip.id);
        res.fold((_) {}, (offers) {
          Offer? driverBestOffer;
          for (final offer in offers) {
            final oDriverId =
                offer.driverId != 0 ? offer.driverId : (offer.driver?.id ?? 0);
            if (oDriverId != 0 && oDriverId == currentUid) {
              if (offer.isAccepted) {
                driverBestOffer = offer;
                break;
              } else if (offer.isPending) {
                driverBestOffer = offer;
              } else if (driverBestOffer == null ||
                  !driverBestOffer!.isPending) {
                driverBestOffer = offer;
              }
            }
          }
          if (driverBestOffer != null) {
            _driverOffersByTripId[trip.id] = driverBestOffer!;
            hasUpdates = true;
          } else {
            if (_driverOffersByTripId.containsKey(trip.id)) {
              _driverOffersByTripId.remove(trip.id);
              hasUpdates = true;
            }
          }
        });
      } catch (_) {}
    }
    if (hasUpdates) {
      emit(_categorize(trips));
    }
  }

  void _populateLegacyLists(List<Trip> trips) {
    TripsListByTypePrivete = [];
    TripsListByTypeShared = [];

    final rejectedList =
        _storage.readStringList(key: 'driver_rejected_trips') ?? [];

    for (final trip in trips) {
      // Filter out server-confirmed stale trips, trips that are not open, or rejected trips
      if (trip.isStale ||
          trip.status != TripStatus.open ||
          rejectedList.contains(trip.id.toString())) {
        log('Filtering out trip #${trip.id} (status: ${trip.status.name}, isStale: ${trip.isStale})',
            name: 'DriverTripsCubit');
        continue;
      }

      final offerStatus = checkOfferStatus(trip);
      if (offerStatus == 'accepted' ||
          offerStatus == 'another_driver_accepted') {
        log('Filtering out trip #${trip.id} with accepted offer ($offerStatus)',
            name: 'DriverTripsCubit');
        continue;
      }

      // If a specific date is selected, filter matching trips
      if (selectedDate != null) {
        final matches =
            _isMatchingSelectedDate(trip.tripDatetime, selectedDate!);
        if (!matches) {
          log('Trip #${trip.id} filtered out because datetime "${trip.tripDatetime}" does not match selected date "$selectedDate"',
              name: 'DriverTripsCubit');
          continue;
        }
      }

      final isPrivate = trip.type == TripType.private;
      if (isPrivate) {
        TripsListByTypePrivete.add(trip);
      } else {
        TripsListByTypeShared.add(trip);
      }
    }
  }

  /// Bulletproof matching helper that supports ISO strings, UTC offsets, and multiple format representations
  bool _isMatchingSelectedDate(String rawDateTime, DateTime targetDate) {
    final str = rawDateTime.trim();
    if (str.isEmpty) return false;

    // 1. Direct formatted string checks (e.g. "2026-08-15", "15-08-2026", "2026/08/15", "15/08/2026")
    final y = targetDate.year.toString();
    final m = targetDate.month.toString().padLeft(2, '0');
    final d = targetDate.day.toString().padLeft(2, '0');
    final dNoPad = targetDate.day.toString();
    final mNoPad = targetDate.month.toString();

    if (str.contains('$y-$m-$d') ||
        str.contains('$d-$m-$y') ||
        str.contains('$y/$m/$d') ||
        str.contains('$d/$m/$y') ||
        str.contains('$y-$mNoPad-$dNoPad') ||
        str.contains('$dNoPad-$mNoPad-$y')) {
      return true;
    }

    // 2. Strict / Standard DateTime.tryParse (handles ISO 8601 like "2026-08-15T14:30:00Z" or "2026-08-15 14:30:00")
    try {
      final parsed = DateTime.tryParse(str);
      if (parsed != null) {
        // Compare both local and UTC representations
        final localMatch = parsed.toLocal().year == targetDate.year &&
            parsed.toLocal().month == targetDate.month &&
            parsed.toLocal().day == targetDate.day;
        final utcMatch = parsed.year == targetDate.year &&
            parsed.month == targetDate.month &&
            parsed.day == targetDate.day;
        if (localMatch || utcMatch) return true;
      }
    } catch (_) {}

    // 3. Fallback: Check regex for year, month, day anywhere in the string
    final ymPattern = RegExp('(^|[^0-9])$y[-/]?0?$m[-/]?0?$d([^0-9]|\$)');
    final myPattern = RegExp('(^|[^0-9])0?$d[-/]?0?$m[-/]?$y([^0-9]|\$)');
    if (ymPattern.hasMatch(str) || myPattern.hasMatch(str)) {
      return true;
    }

    return false;
  }

  /// Checks if a date string is in the past (before today 00:00:00)
  bool _isPastDate(String rawDateTime) {
    final str = rawDateTime.trim();
    if (str.isEmpty) return false;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    try {
      final parsed = DateTime.tryParse(str);
      if (parsed != null) {
        final tripDay = DateTime(parsed.year, parsed.month, parsed.day);
        return tripDay.isBefore(todayStart);
      }
    } catch (_) {}

    final datePattern = RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})');
    final match = datePattern.firstMatch(str);
    if (match != null) {
      try {
        final year = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        final day = int.parse(match.group(3)!);
        final tripDay = DateTime(year, month, day);
        return tripDay.isBefore(todayStart);
      } catch (_) {}
    }

    return false;
  }

  Future<void> changeTripStatusOnGoingTrip({
    required int tripId,
    String? status,
    String? onGoingStatus,
    String? on_going_status,
  }) async {
    final subStatus = onGoingStatus ?? on_going_status ?? 'pending';
    // Main status must be an explicit valid status or defaults based on subStatus phase ('end' -> 'completed', otherwise 'accepted')
    final mainStatus =
        status ?? (subStatus == 'end' ? 'completed' : 'accepted');

    // Persist sub-status locally so driver recovers state on app restart
    await _storage.saveString(
      key: 'ongoing_trip_${tripId}_status',
      value: subStatus,
    );

    // Optimistically update in-memory lists if ending or canceling
    if (mainStatus == 'completed' ||
        mainStatus == 'canceled' ||
        mainStatus == 'closed') {
      final currentTrip =
          TripsListByTypeCurrentPrivete.cast<dynamic>().firstWhere(
        (t) => (t is Trip ? t.id : t['id']) == tripId,
        orElse: () => TripsListByTypeCurrentShared.cast<dynamic>().firstWhere(
          (t) => (t is Trip ? t.id : t['id']) == tripId,
          orElse: () => null,
        ),
      );

      TripsListByTypeCurrentPrivete.removeWhere(
          (t) => (t is Trip ? t.id : t['id']) == tripId);
      TripsListByTypeCurrentShared.removeWhere(
          (t) => (t is Trip ? t.id : t['id']) == tripId);

      if (currentTrip != null) {
        final isPriv = (currentTrip is Trip
            ? currentTrip.type == TripType.private
            : (currentTrip['type'] == 'private' ||
                currentTrip['type'] == 'private_trip'));
        if (mainStatus == 'completed') {
          if (isPriv) {
            if (!TripsListByTypeCompletedPrivete.any(
                (t) => (t is Trip ? t.id : t['id']) == tripId)) {
              TripsListByTypeCompletedPrivete.insert(0, currentTrip);
            }
          } else {
            if (!TripsListByTypeCompletedShared.any(
                (t) => (t is Trip ? t.id : t['id']) == tripId)) {
              TripsListByTypeCompletedShared.insert(0, currentTrip);
            }
          }
        } else if (mainStatus == 'canceled' || mainStatus == 'closed') {
          if (isPriv) {
            if (!TripsListByTypeCanceledPrivete.any(
                (t) => (t is Trip ? t.id : t['id']) == tripId)) {
              TripsListByTypeCanceledPrivete.insert(0, currentTrip);
            }
          } else {
            if (!TripsListByTypeCanceledShared.any(
                (t) => (t is Trip ? t.id : t['id']) == tripId)) {
              TripsListByTypeCanceledShared.insert(0, currentTrip);
            }
          }
        }
      }
      emit(const DriverTripStatusChanged());
    }

    final result = await _changeTripStatus(
      tripId: tripId,
      status: mainStatus,
      onGoingStatus: subStatus,
    );

    result.fold(
      (failure) {
        log('Failed to update trip status: ${failure.message}',
            name: 'DriverTripsCubit.changeTripStatusOnGoingTrip');
        emit(DriverTripsError(failure.message));
      },
      (_) async {
        log('Successfully updated trip #$tripId to status: $mainStatus, subStatus: $subStatus',
            name: 'DriverTripsCubit.changeTripStatusOnGoingTrip');
        if (mainStatus == 'completed' ||
            mainStatus == 'canceled' ||
            mainStatus == 'closed') {
          await _storage.remove(key: 'ongoing_trip_${tripId}_status');
          await DriverLocationTrackerService.instance.stopTracking(_storage);
        }
        await loadDriverTrips();
      },
    );
  }

  final Map<int, Offer> _driverOffersByTripId = {};

  Future<void> createOffer(
    BuildContext context, {
    Function? stoploading,
    required int trip_id,
    String? note,
    required double price,
    double? percentage_added,
    required Trip trip,
  }) async {
    // 1. Single offer constraint check
    final currentStatus = checkOfferStatus(trip);
    if (currentStatus == 'pending') {
      if (context.mounted) {
        showToast(
          text: S.of(context).offerSentWaitingPassenger,
          state: ToastStates.WARNING,
        );
      }
      if (stoploading != null) stoploading();
      return;
    }
    if (currentStatus == 'accepted') {
      if (context.mounted) {
        showToast(
          text: S.of(context).offerAcceptedSuccess,
          state: ToastStates.SUCESS,
        );
      }
      if (stoploading != null) stoploading();
      return;
    }
    if (currentStatus == 'another_driver_accepted') {
      if (context.mounted) {
        showToast(
          text: S.of(context).anotherDriverSelected,
          state: ToastStates.WARNING,
        );
      }
      if (stoploading != null) stoploading();
      return;
    }

    final driverId =
        _userId != 0 ? _userId : (trip.driverId ?? trip.driver?.id ?? 0);

    if (driverId == 0) {
      if (context.mounted) {
        showToast(
            text: S.of(context).driverIdentityFailed, state: ToastStates.ERROR);
      }
      if (stoploading != null) stoploading();
      return;
    }

    // If server rejects with business error, surface the error_code
    try {
      final result = await _makeOffer(
        offerData: {
          "driver_id": driverId,
          "trip_id": trip_id,
          "note": note ?? '',
          "price": price,
          "percentage": percentage_added ?? 0.0,
        },
      );

      result.fold((failure) {
        showToast(text: failure.message, state: ToastStates.ERROR);
        emit(DriverTripsError(failure.message));
      }, (_) async {
        // Record pending offer state immediately on successful API call
        _driverOffersByTripId[trip_id] = Offer(
          id: 0,
          tripId: trip_id,
          driverId: driverId,
          price: price,
          status: OfferStatus.pending,
          effectiveStatus: 'pending',
        );

        // Persist submitted offer trip IDs locally for this driver
        final userSpecificKey = 'driver_${driverId}_submitted_offers';
        final submittedList =
            _storage.readStringList(key: userSpecificKey) ?? [];
        if (!submittedList.contains(trip_id.toString())) {
          submittedList.add(trip_id.toString());
          await _storage.saveStringList(
              key: userSpecificKey, value: submittedList);
        }

        if (context.mounted) {
          successDialoug(context, S.of(context).SuccessfullySent);
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
        }
        // Refresh trips directly from API to get updated offer state
        getDriverTripsByTypes(isLoading: false);
        emit(const DriverOfferSubmitted());
      });
    } catch (e) {
      log(e.toString(), name: "DriverTripsCubit.createOffer");
      showToast(
          text: '${S.current.errorOccurred}: $e', state: ToastStates.ERROR);
    } finally {
      if (stoploading != null) stoploading();
    }
  }

  /// Checks status of driver's offer for a specific trip directly from API data.
  String checkOfferStatus(Trip trip) {
    return checkSubmittedOffer(_userId, trip.id, trip);
  }

  /// Checks if current driver has already submitted an offer for a given trip from API data.
  String checkSubmittedOffer(int driverId, dynamic tripId, Trip trip) {
    final currentUid = driverId != 0 ? driverId : _userId;
    final isTripAccepted = trip.status == TripStatus.accepted;
    final assignedDriverId = trip.driverId ?? trip.driver?.id ?? 0;

    // 0. Check if driver created this trip or saved offer status is accepted
    final savedOfferStatus =
        _storage.read(key: 'offer_status_${trip.id}')?.toString();
    if (savedOfferStatus == 'accepted' &&
        (isTripAccepted ||
            (currentUid != 0 &&
                (trip.creator?.id == currentUid ||
                    assignedDriverId == currentUid)))) {
      return 'accepted';
    }

    // 1. Check if this driver is assigned to the trip by backend AND trip is currently accepted
    if (isTripAccepted &&
        currentUid != 0 &&
        (assignedDriverId == currentUid || trip.creator?.id == currentUid)) {
      return 'accepted';
    }

    // 2. Check if another driver was accepted on this trip by backend
    final tripStatus = trip.status.name.toLowerCase();
    if ((isTripAccepted ||
            tripStatus == 'closed' ||
            tripStatus == 'completed') &&
        assignedDriverId != 0 &&
        currentUid != 0 &&
        assignedDriverId != currentUid) {
      return 'another_driver_accepted';
    }

    // 3. Check tracked driver offer fetched from API or submitted in this session (strictly for current driver)
    final trackedOffer = _driverOffersByTripId[trip.id];
    if (trackedOffer != null) {
      final trackedDriverId = trackedOffer.driverId != 0
          ? trackedOffer.driverId
          : (trackedOffer.driver?.id ?? 0);
      if (currentUid != 0 &&
          (trackedDriverId == 0 || trackedDriverId == currentUid)) {
        final effective =
            (trackedOffer.effectiveStatus ?? trackedOffer.status.name)
                .toLowerCase();
        if ((effective == 'accepted' || effective == '1') && isTripAccepted) {
          return 'accepted';
        }
        if (effective == 'pending' ||
            effective == '0' ||
            effective == 'waiting') {
          return 'pending';
        }
        if (effective == 'rejected' ||
            effective == '2' ||
            effective == 'refused' ||
            effective == 'passengers_rejected' ||
            effective == 'canceled' ||
            (effective == 'accepted' && !isTripAccepted)) {
          return 'individual_rejected';
        }
      }
    }

    // 4. Check typed offers list from API on trip entity (strictly for this driver)
    if (trip.offers.isNotEmpty && currentUid != 0) {
      bool hasPending = false;
      bool hasAccepted = false;
      bool hasRejected = false;

      for (final offer in trip.offers) {
        final oDriverId =
            offer.driverId != 0 ? offer.driverId : (offer.driver?.id ?? 0);
        if (oDriverId != 0 && oDriverId == currentUid) {
          final effective =
              (offer.effectiveStatus ?? offer.status.name).toLowerCase();
          if (effective == 'accepted' || effective == '1') {
            if (isTripAccepted) {
              hasAccepted = true;
            } else {
              hasRejected = true;
            }
          } else if (effective == 'pending' ||
              effective == '0' ||
              effective == 'waiting') {
            hasPending = true;
          } else if (effective == 'rejected' ||
              effective == '2' ||
              effective == 'refused' ||
              effective == 'passengers_rejected' ||
              effective == 'canceled') {
            hasRejected = true;
          }
        }
      }

      if (hasAccepted) return 'accepted';
      if (hasPending) return 'pending';
      if (hasRejected) return 'individual_rejected';
    }

    // 5. Check local submitted offer cache (persisted across restarts for this driver)
    if (currentUid != 0) {
      final userSpecificKey = 'driver_${currentUid}_submitted_offers';
      final submittedList = _storage.readStringList(key: userSpecificKey) ??
          _storage.readStringList(key: 'driver_submitted_offers') ??
          [];
      if (submittedList.contains(trip.id.toString())) {
        return 'pending';
      }
    }

    return 'none';
  }

  /// H-10: Allows driver to cancel pickup en-route and reverts trip status to 'open'
  Future<void> cancelPickup(int tripId, {String? reason}) async {
    final result =
        await _changeTripStatus(tripId: tripId, status: 'open', reason: reason);
    result.fold(
      (failure) => emit(DriverTripsError(failure.message)),
      (_) async {
        await _storage.remove(key: 'ongoing_trip_${tripId}_status');
        await DriverLocationTrackerService.instance.stopTracking(_storage);
        TripSecurityService.clearActiveTrip(_storage);
        TripsListByTypeCurrentPrivete.removeWhere(
            (t) => (t is Trip ? t.id : t['id']) == tripId);
        TripsListByTypeCurrentShared.removeWhere(
            (t) => (t is Trip ? t.id : t['id']) == tripId);
        _driverOffersByTripId.remove(tripId);
        log('Driver cancelled pickup for trip $tripId (reason: $reason). Reverted to open.',
            name: 'DriverTripsCubit.cancelPickup');
        emit(const DriverTripStatusChanged());
        await loadDriverTrips();
      },
    );
  }

  Future<bool> driverCancelTrip({
    required int tripId,
    required bool isSharedCreator,
    String? reason,
  }) async {
    emit(const DriverTripsLoading());
    final status = isSharedCreator ? 'canceled' : 'open';
    final result =
        await _changeTripStatus(tripId: tripId, status: status, reason: reason);
    return result.fold(
      (failure) {
        emit(DriverTripsError(failure.message));
        return false;
      },
      (_) async {
        await _storage.remove(key: 'ongoing_trip_${tripId}_status');
        await DriverLocationTrackerService.instance.stopTracking(_storage);
        TripSecurityService.clearActiveTrip(_storage);

        // Delete driver chat channel from Firestore so reopening starts completely clean
        try {
          final currentDriverId = _userId;
          final chatId = ChatChannelHelper.privateTripChatId(
              tripId: tripId, driverId: currentDriverId);
          sl<ChatRemoteDataSource>().deleteChat(chatId: chatId);
        } catch (_) {}

        TripsListByTypeCurrentPrivete.removeWhere(
            (t) => (t is Trip ? t.id : t['id']) == tripId);
        TripsListByTypeCurrentShared.removeWhere(
            (t) => (t is Trip ? t.id : t['id']) == tripId);
        _driverOffersByTripId.remove(tripId);
        emit(const DriverTripStatusChanged());
        await loadDriverTrips();
        return true;
      },
    );
  }

  Future<void> userAddPrivateTrip(Map tripDetails,
      {required BuildContext context}) async {
    // Send UTC ISO-8601 — server accepts this format
    final tripDatetime = DateTime.now().toUtc().toIso8601String();

    try {
      final result = await _createTrip(
        {
          "from_latitude": tripDetails['from_latitude'],
          "from_longitude": tripDetails['from_longitude'],
          "to_latitude": tripDetails['to_latitude'],
          "to_longitude": tripDetails['to_longitude'],
          "from_location_name": tripDetails['from_location_name'],
          "to_location_name": tripDetails['to_location_name'],
          "number_of_seats": tripDetails['number_of_seats'],
          "gender_preference": (tripDetails['gender_preference'] == 'female' ||
                  tripDetails['gender_preference'] == 'male' ||
                  tripDetails['gender_preference'] == 'no_preference')
              ? tripDetails['gender_preference']
              : 'no_preference',
          "type": tripDetails['type'],
          "percentage": tripDetails['percentage'],
          "trip_datetime": tripDatetime,
        },
      );

      result.fold((failure) {
        if (context.mounted) {
          showToast(text: failure.message, state: ToastStates.ERROR);
        }
      }, (_) {
        if (context.mounted) {
          showToast(
              text: S.of(context).SuccessfullySent, state: ToastStates.SUCESS);
          Navigator.pop(context);
        }
      });
    } catch (e) {
      log(e.toString(), name: "DriverTripsCubit.userAddPrivateTrip");
      if (context.mounted) {
        showToast(
            text: '${S.of(context).errorOccurred}: $e',
            state: ToastStates.ERROR);
      }
    }
  }

  // ─── Trip Status ──────────────────────────────────────────────────────────
  Future<void> changeStatus(int tripId, String status) async {
    await changeTripStatusOnGoingTrip(
      tripId: tripId,
      status: (status == 'end' || status == 'completed') ? 'completed' : status,
      onGoingStatus: status == 'completed' ? 'end' : status,
    );
  }

  // ─── Trip Details ─────────────────────────────────────────────────────────
  Future<void> refreshTripDetails(int tripId) async {
    final result = await _getTripDetails(tripId);
    result.fold(
      (failure) => emit(DriverTripsError(failure.message)),
      (trip) => emit(DriverTripDetailsLoaded(trip)),
    );
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        try {
          return await Geolocator.getLastKnownPosition();
        } catch (_) {
          return null;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }
      }

      // 1. Android / Emulator specific fast location fix with forceLocationManager
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          final current = await Geolocator.getCurrentPosition(
            locationSettings: AndroidSettings(
              accuracy: LocationAccuracy.high,
              forceLocationManager: true,
              timeLimit: const Duration(seconds: 4),
            ),
          );
          return current;
        } catch (e) {
          log('forceLocationManager attempt timed out / failed: $e',
              name: 'DriverTripsCubit._getCurrentPosition');
        }
      }

      // 2. Standard Google Fused Location attempt
      try {
        final current = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 4),
          ),
        );
        return current;
      } catch (e) {
        log('Standard getCurrentPosition attempt timed out / failed: $e',
            name: 'DriverTripsCubit._getCurrentPosition');
      }

      // 3. Last Known fallback
      Position? lastKnown;
      try {
        lastKnown = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      return lastKnown;
    } catch (e) {
      log('Error getting position: $e',
          name: 'DriverTripsCubit._getCurrentPosition');
      return null;
    }
  }

  List OfferListUser = [];

  Future<void> getOffersByTripId({
    int? tripId,
    dynamic id,
    dynamic stoploading,
    dynamic isLoading,
    dynamic forceRefresh,
  }) async {
    final resolvedTripId = tripId ?? int.tryParse(id?.toString() ?? '') ?? 0;
    if (resolvedTripId > 0) {
      try {
        final res = await _getTripDetails(resolvedTripId);
        res.fold((_) {}, (trip) {
          // Use TripModel.toJson() to get a map (stays in data layer, not entity).
          // The offers/passengers are already embedded in the trip map from the server.
          final tripMap = trip is TripModel
              ? trip.toJson()
              : {'offers': trip.passengers ?? []};
          OfferListUser = (tripMap['offers'] ??
              tripMap['driver_offers'] ??
              tripMap['user_offers'] ??
              []) as List;
        });
      } catch (_) {}
    }
    if (stoploading is Function) {
      try {
        stoploading(OfferListUser, null);
      } catch (_) {
        try {
          stoploading(OfferListUser);
        } catch (_) {
          stoploading();
        }
      }
    }
  }

  Future<void> changeTripStatus({
    dynamic id,
    required String status,
    dynamic stoploading,
    dynamic PassState,
  }) async {
    final tripId = int.tryParse(id?.toString() ?? '') ?? 0;
    if (tripId > 0) {
      await _changeTripStatus(tripId: tripId, status: status);
    }
    if (stoploading is Function) {
      try {
        stoploading();
      } catch (_) {}
    }
  }

  Future<void> changeOfferStatus({
    dynamic id,
    required String status,
    dynamic stoploading,
    dynamic PassState,
  }) async {
    final offerId = int.tryParse(id?.toString() ?? '') ?? 0;
    if (offerId > 0) {
      try {
        final userIdStr = _storage.read(key: 'user_id')?.toString() ?? '0';
        final userId = int.tryParse(userIdStr) ?? 0;
        if (_changeOfferStatus != null) {
          await _changeOfferStatus!(
            offerId: offerId,
            status: status,
            userId: userId,
          );
        } else {
          final token = _storage.read(key: 'token') ?? '';
          await _client.put(
            url: '${ApiEndpoints.changeOfferStatus}$offerId',
            token: token,
            data: {'status': status},
          );
        }
      } catch (_) {}
    }
    if (stoploading is Function) {
      try {
        stoploading();
      } catch (_) {}
    }
  }
}
