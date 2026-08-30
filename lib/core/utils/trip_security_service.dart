
import 'dart:convert';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/data/models/trip_model.dart';

/// Helper service for trip security: OTP verification, Geofencing & State persistence.
class TripSecurityService {
  TripSecurityService._();

  /// Generates a consistent 4-digit PIN/OTP code for a trip ID.
  static String generateTripOTP(dynamic tripId) {
    final id = int.tryParse(tripId?.toString() ?? '') ?? 1234;
    final pin = ((id * 37 + 1234) % 9000) + 1000;
    return pin.toString();
  }

  /// Validates if driver is within [maxDistanceMeters] (default 200m) from pickup location.
  static Map<String, dynamic> validateGeofence({
    required double driverLat,
    required double driverLng,
    required double pickupLat,
    required double pickupLng,
    double maxDistanceMeters = 200.0,
  }) {
    if (pickupLat == 0.0 || pickupLng == 0.0) {
      return {'isValid': true, 'distanceMeters': 0.0};
    }

    final distanceMeters = Geolocator.distanceBetween(
      driverLat,
      driverLng,
      pickupLat,
      pickupLng,
    );

    return {
      'isValid': distanceMeters <= maxDistanceMeters,
      'distanceMeters': distanceMeters,
    };
  }

  /// Persists current active trip details to local storage.
  static void saveActiveTrip(LocalStorage storage, [dynamic trip]) {
    if (trip == null) return;
    try {
      Map<String, dynamic> mapToSave;
      if (trip is Trip) {
        mapToSave = trip.toJson();
      } else if (trip is Map) {
        mapToSave = Map<String, dynamic>.from(trip);
      } else {
        return;
      }
      storage.saveString(
        key: 'active_trip_data',
        value: jsonEncode(mapToSave),
      );
      final tripType = mapToSave['type']?.toString() ?? 'private';
      storage.saveString(key: 'ongoing_trip', value: tripType);
    } catch (e) {
      log('Failed to save active trip to storage: $e', name: 'TripSecurityService');
    }
  }

  /// Retrieves active trip details from local storage if still valid.
  static Trip? getActiveTrip(LocalStorage storage) {
    try {
      final raw = storage.read(key: 'active_trip_data');
      if (raw == null) return null;
      Map<String, dynamic> map;
      if (raw is String && raw.trim().isNotEmpty) {
        map = jsonDecode(raw) as Map<String, dynamic>;
      } else if (raw is Map) {
        map = Map<String, dynamic>.from(raw);
      } else {
        return null;
      }
      final trip = TripModel.fromJson(map);
      if (isPreTripTrackingActive(trip)) {
        return trip;
      } else {
        clearActiveTrip(storage);
        return null;
      }
    } catch (e) {
      log('Failed to get active trip from storage: $e', name: 'TripSecurityService');
      return null;
    }
  }

  /// Clears active trip details when trip is finished or canceled.
  static void clearActiveTrip([LocalStorage? storage]) {
    final s = storage ?? di.sl<LocalStorage>();
    try {
      s.remove(key: 'active_trip_data');
      s.remove(key: 'active_trip');
      s.remove(key: 'ongoing_trip');
      s.remove(key: 'trip_id');
      s.remove(key: 'ongoing_trip_status');
    } catch (e) {
      log('Failed to clear active trip from storage: $e', name: 'TripSecurityService');
    }
  }

  /// Persists a pending trip (waiting for driver offers) to local storage.
  static void savePendingTrip(LocalStorage storage, [dynamic trip]) {
    if (trip == null) return;
    try {
      Map<String, dynamic> mapToSave;
      if (trip is Trip) {
        mapToSave = trip.toJson();
      } else if (trip is Map) {
        mapToSave = Map<String, dynamic>.from(trip);
      } else {
        return;
      }
      storage.saveString(
        key: 'pending_trip_data',
        value: jsonEncode(mapToSave),
      );
      final tripType = mapToSave['type']?.toString() ?? 'private';
      storage.saveString(key: 'pending_trip_type', value: tripType);
    } catch (e) {
      log('Failed to save pending trip to storage: $e', name: 'TripSecurityService');
    }
  }

  /// Retrieves pending trip details from local storage if available.
  static Trip? getPendingTrip(LocalStorage storage) {
    try {
      final raw = storage.read(key: 'pending_trip_data');
      if (raw == null) return null;
      Map<String, dynamic> map;
      if (raw is String && raw.trim().isNotEmpty) {
        map = jsonDecode(raw) as Map<String, dynamic>;
      } else if (raw is Map) {
        map = Map<String, dynamic>.from(raw);
      } else {
        return null;
      }
      return TripModel.fromJson(map);
    } catch (e) {
      log('Failed to get pending trip from storage: $e', name: 'TripSecurityService');
      return null;
    }
  }

  /// Clears pending trip details when offer is accepted or trip canceled.
  static void clearPendingTrip([LocalStorage? storage]) {
    final s = storage ?? di.sl<LocalStorage>();
    try {
      s.remove(key: 'pending_trip_data');
      s.remove(key: 'pending_trip_type');
    } catch (e) {
      log('Failed to clear pending trip from storage: $e', name: 'TripSecurityService');
    }
  }

  /// Checks if a trip is actively accepted/ongoing for driver location tracking.
  static bool isPreTripTrackingActive(Trip trip) {
    if (trip.status == TripStatus.completed ||
        trip.status == TripStatus.canceled ||
        trip.status == TripStatus.closed ||
        trip.status == TripStatus.open ||
        trip.status == TripStatus.suspended) {
      return false;
    }

    final onGoingStatus = trip.onGoingStatus?.toLowerCase() ?? '';
    if (onGoingStatus == 'end' ||
        onGoingStatus == 'completed' ||
        onGoingStatus == 'canceled' ||
        onGoingStatus == 'closed') {
      return false;
    }

    // For scheduled trips with a future tripDatetime:
    // If the trip date/time is more than 30 minutes in the future and ongoing_status is not yet actively started by driver,
    // pre-trip live GPS tracking remains dormant until the 30-minute activation window.
    if (onGoingStatus.isEmpty || onGoingStatus == 'pending') {
      if (trip.tripDatetime.isNotEmpty) {
        try {
          final scheduledDateTime = DateTime.tryParse(trip.tripDatetime);
          if (scheduledDateTime != null) {
            final diff = scheduledDateTime.difference(DateTime.now());
            // If scheduled trip is > 30 minutes in the future, tracking is dormant
            if (diff.inMinutes > 30) {
              return false;
            }
          }
        } catch (_) {}
      }
    }

    // Active ongoing statuses (driver is currently executing the trip journey)
    if (onGoingStatus == 'on_the_way' ||
        onGoingStatus == 'close_to_customer' ||
        onGoingStatus == 'arrive_customer' ||
        onGoingStatus == 'start' ||
        onGoingStatus == 'pending') {
      return true;
    }

    // If trip is accepted and has an assigned driver, it is an active ongoing trip
    if (trip.status == TripStatus.accepted && (trip.driverId != null || trip.driver != null)) {
      return true;
    }

    return false;
  }

  /// Syncs local active trip state with backend server truth (Disabled - active trip data is never cached).
  static Future<Map<String, dynamic>?> syncActiveTripWithServer(
    dynamic client,
    LocalStorage storage,
  ) async {
    clearActiveTrip(storage);
    return null;
  }
}

