import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/generated/l10n.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:car_app/core/services/firebase_trip_location_service.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/utils/trip_security_service.dart';

import 'package:car_app/features/trips/domain/entities/trip.dart';

/// Global persistent driver location tracking service.
/// Keeps broadcasting real-time driver coordinates to Firestore
/// as long as a trip is active, whether app is in foreground or background.
class DriverLocationTrackerService {
  DriverLocationTrackerService._internal();
  static final DriverLocationTrackerService _instance =
      DriverLocationTrackerService._internal();
  static DriverLocationTrackerService get instance => _instance;

  final FirebaseTripLocationService _locationService =
      FirebaseTripLocationService();

  StreamSubscription<Position>? _positionStreamSub;
  String? _activeTripId;
  Map<String, dynamic>? _activeTripDetails;
  LatLng? _prevLatLng;
  Position? _currentPosition;
  double _lastBearing = 0.0;

  bool get isTracking => _positionStreamSub != null && _activeTripId != null;
  String? get activeTripId => _activeTripId;
  Map<String, dynamic>? get activeTripDetails => _activeTripDetails;
  Position? get currentPosition => _currentPosition;
  double get currentBearing => _lastBearing;

  final StreamController<Map<String, dynamic>> _locationController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onLocationUpdate => _locationController.stream;

  /// Starts background & foreground driver location tracking for an active trip.
  Future<void> startTracking({
    int? tripId,
    Trip? trip,
    Map<String, dynamic>? tripDetails,
    required LocalStorage storage,
  }) async {
    final effectiveId = tripId?.toString() ??
        trip?.id.toString() ??
        tripDetails?['id']?.toString() ??
        tripDetails?['trip_id']?.toString() ??
        tripDetails?['trip']?['id']?.toString() ??
        tripDetails?['tripId']?.toString() ??
        '';

    if (effectiveId.isEmpty || effectiveId == '0') {
      log('startTracking ignored: empty tripId',
          name: 'DriverLocationTrackerService');
      return;
    }

    final bool isNewTrip = _activeTripId != effectiveId;
    _activeTripId = effectiveId;
    if (tripDetails != null) {
      _activeTripDetails = Map<String, dynamic>.from(tripDetails);
    } else if (trip != null) {
      _activeTripDetails = {
        'id': trip.id,
        'from_latitude': trip.fromLatitude,
        'from_longitude': trip.fromLongitude,
        'to_latitude': trip.toLatitude,
        'to_longitude': trip.toLongitude,
        'from_location_name': trip.fromLocationName,
        'to_location_name': trip.toLocationName,
        'on_going_status': trip.onGoingStatus ?? 'on_the_way',
      };
    }
    // Also merge trip coordinates if missing or zero in tripDetails
    if (trip != null && _activeTripDetails != null) {
      final pLat = double.tryParse(_activeTripDetails!['from_latitude']?.toString() ?? '') ?? 0.0;
      if (pLat == 0.0 && trip.fromLatitude != 0.0) {
        _activeTripDetails!['from_latitude'] = trip.fromLatitude;
        _activeTripDetails!['from_longitude'] = trip.fromLongitude;
      }
      final dLat = double.tryParse(_activeTripDetails!['to_latitude']?.toString() ?? '') ?? 0.0;
      if (dLat == 0.0 && trip.toLatitude != 0.0) {
        _activeTripDetails!['to_latitude'] = trip.toLatitude;
        _activeTripDetails!['to_longitude'] = trip.toLongitude;
      }
    }

    // Save to persistent storage so tracking survives app restart
    TripSecurityService.saveActiveTrip(storage, trip ?? tripDetails);

    // If already tracking this exact trip, don't restart stream unnecessarily
    if (_positionStreamSub != null && !isNewTrip) return;

    // Check & request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // Configure foreground & background location settings
    LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 4, // 4 meters
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 3),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: S.current.driverTrackingLiveNotificationTitle,
          notificationText: S.current.driverTrackingLiveNotificationText,
          notificationIcon: const AndroidResource(name: 'ic_launcher'),
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 4,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 4,
      );
    }

    log('Starting persistent driver location tracking for trip #$tripId',
        name: 'DriverLocationTrackerService');

    await _positionStreamSub?.cancel();
    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _onPositionReceived(position);
      },
      onError: (e) {
        log('Error in location stream: $e', name: 'DriverLocationTrackerService');
      },
    );

    // Send initial position immediately without waiting for device movement
    try {
      Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      ).then((Position position) {
        _onPositionReceived(position);
      }).catchError((e) {
        log('Could not get initial current position: $e', name: 'DriverLocationTrackerService');
      });
    } catch (_) {}
  }

  void _onPositionReceived(Position position) {
    if (_activeTripId == null || _activeTripId!.isEmpty) return;

    _currentPosition = position;
    final newLatLng = LatLng(position.latitude, position.longitude);

    double bearing = position.heading;
    if (bearing == 0.0 && _prevLatLng != null) {
      bearing = _calcBearing(_prevLatLng!, newLatLng);
    }
    _prevLatLng = newLatLng;
    _lastBearing = bearing;

    // 1. Broadcast to Firestore live collection
    _locationService.updateDriverLocation(
      tripId: _activeTripId!,
      lat: position.latitude,
      lng: position.longitude,
      bearing: bearing,
    );

    // 2. Broadcast locally for active UI screens
    _locationController.add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'bearing': bearing,
      'position': position,
      'on_going_status': _activeTripDetails?['on_going_status'],
    });

    // 3. Geofence distance auto-transition for pickup arrival & auto-start
    if (_activeTripDetails != null) {
      final onGoingStatus =
          _activeTripDetails!['on_going_status']?.toString().toLowerCase() ?? '';
      final pickupLat = double.tryParse(
              _activeTripDetails!['from_latitude']?.toString() ?? '') ??
          0.0;
      final pickupLng = double.tryParse(
              _activeTripDetails!['from_longitude']?.toString() ?? '') ??
          0.0;
      final destLat = double.tryParse(
              _activeTripDetails!['to_latitude']?.toString() ?? '') ??
          0.0;
      final destLng = double.tryParse(
              _activeTripDetails!['to_longitude']?.toString() ?? '') ??
          0.0;

      // Phase A: Approaching pickup (on_the_way / pending / close_to_customer)
      if (onGoingStatus == 'on_the_way' ||
          onGoingStatus == 'pending' ||
          onGoingStatus == 'close_to_customer') {
        if (pickupLat != 0.0 && pickupLng != 0.0) {
          final distToPickup = Geolocator.distanceBetween(
              position.latitude, position.longitude, pickupLat, pickupLng);
          if (distToPickup < 50 && onGoingStatus != 'arrive_customer') {
            log('Driver within 50m of pickup ($distToPickup m). Auto-transitioning to arrive_customer.',
                name: 'DriverLocationTrackerService');
            _updateTripStatus('arrive_customer');
          } else if (distToPickup <= 500 && onGoingStatus == 'on_the_way') {
            log('Driver within 500m of pickup ($distToPickup m). Auto-transitioning to close_to_customer.',
                name: 'DriverLocationTrackerService');
            _updateTripStatus('close_to_customer');
          }
        }
      }

      // Phase B: Auto-start when driver departs pickup towards destination
      if (onGoingStatus == 'arrive_customer') {
        if (pickupLat != 0.0 && pickupLng != 0.0) {
          final distFromPickup = Geolocator.distanceBetween(
              position.latitude, position.longitude, pickupLat, pickupLng);
          if (distFromPickup > 80) {
            log('Driver departed pickup ($distFromPickup m away). Auto-starting trip.',
                name: 'DriverLocationTrackerService');
            _updateTripStatus('start');
          }
        }
      }

      // Phase C: Geofence destination arrival auto-complete (GPS proof of completion)
      if (destLat != 0.0 && destLng != 0.0) {
        final distToDest = Geolocator.distanceBetween(
            position.latitude, position.longitude, destLat, destLng);
        if (distToDest <= 150 && onGoingStatus == 'start') {
          log('Driver reached destination ($distToDest m). Auto-completing trip.',
              name: 'DriverLocationTrackerService');
          _updateTripStatus('end');
        }
      }
    }
  }

  void _updateTripStatus(String newStatus) {
    if (_activeTripId == null) return;
    _activeTripDetails?['on_going_status'] = newStatus;
    _locationService.updateTripStatus(
      tripId: _activeTripId!,
      onGoingStatus: newStatus,
    );
    _locationController.add({
      if (_currentPosition != null) 'latitude': _currentPosition!.latitude,
      if (_currentPosition != null) 'longitude': _currentPosition!.longitude,
      'bearing': _lastBearing,
      'on_going_status': newStatus,
    });
    final tripIdInt = int.tryParse(_activeTripId!) ?? 0;
    if (tripIdInt > 0) {
      try {
        sl<DriverTripsCubit>().changeTripStatusOnGoingTrip(
          tripId: tripIdInt,
          status: newStatus == 'end' ? 'completed' : 'accepted',
          onGoingStatus: newStatus,
        );
      } catch (e) {
        log('Error updating API status in tracker service: $e',
            name: 'DriverLocationTrackerService');
      }
    }
  }

  /// Stops tracking and clears active trip.
  Future<void> stopTracking([LocalStorage? storage]) async {
    log('Stopping driver location tracking', name: 'DriverLocationTrackerService');
    await _positionStreamSub?.cancel();
    _positionStreamSub = null;
    if (_activeTripId != null && _activeTripId!.isNotEmpty) {
      try {
        await _locationService.stopTripLocation(_activeTripId!);
      } catch (_) {}
    }
    _activeTripId = null;
    _activeTripDetails = null;
    _prevLatLng = null;
    final resolvedStorage = storage ?? (sl.isRegistered<LocalStorage>() ? sl<LocalStorage>() : null);
    if (resolvedStorage != null) {
      TripSecurityService.clearActiveTrip(resolvedStorage);
    }
  }

  /// Automatically resumes tracking on app launch or resume if an active trip exists.
  Future<void> checkAndResumeTracking(LocalStorage storage) async {
    final activeTrip = TripSecurityService.getActiveTrip(storage);
    if (activeTrip != null) {
      if (TripSecurityService.isPreTripTrackingActive(activeTrip)) {
        await startTracking(trip: activeTrip, storage: storage);
      }
    }
  }

  double _calcBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * (math.pi / 180.0);
    final lng1 = from.longitude * (math.pi / 180.0);
    final lat2 = to.latitude * (math.pi / 180.0);
    final lng2 = to.longitude * (math.pi / 180.0);
    final dLng = lng2 - lng1;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (math.atan2(y, x) * (180.0 / math.pi) + 360.0) % 360.0;
  }
}
