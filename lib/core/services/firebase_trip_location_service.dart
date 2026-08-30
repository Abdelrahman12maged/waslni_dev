import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseTripLocationService {
  FirebaseTripLocationService._internal();
  static final FirebaseTripLocationService _instance =
      FirebaseTripLocationService._internal();
  factory FirebaseTripLocationService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection name in Firestore for temporary live tracking
  static const String _collectionName = 'active_trips';

  /// Updates or sets the current location and bearing of the driver for a specific trip.
  Future<void> updateDriverLocation({
    required String tripId,
    required double lat,
    required double lng,
    double bearing = 0.0,
  }) async {
    if (tripId.isEmpty) return;
    try {
      await _firestore.collection(_collectionName).doc(tripId).set({
        'latitude': lat,
        'longitude': lng,
        'bearing': bearing,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, stack) {
      debugPrint('Error updating driver location in Firestore: $e\n$stack');
    }
  }

  /// Updates ongoing_status for a trip in Firestore so passengers receive real-time status updates.
  Future<void> updateTripStatus({
    required String tripId,
    required String onGoingStatus,
  }) async {
    if (tripId.isEmpty) return;
    try {
      await _firestore.collection(_collectionName).doc(tripId).set({
        'on_going_status': onGoingStatus,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, stack) {
      debugPrint('Error updating trip status in Firestore: $e\n$stack');
    }
  }

  /// Streams real-time updates for a trip's driver location.
  /// Named [streamTripLocation] for direct use, aliased as [streamDriverLocation].
  Stream<Map<String, dynamic>?> streamTripLocation(String tripId) {
    if (tripId.isEmpty) return const Stream.empty();
    return _firestore
        .collection(_collectionName)
        .doc(tripId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data();
      }
      return null;
    });
  }

  /// Alias for [streamTripLocation] — matches the plan's naming convention.
  Stream<Map<String, dynamic>?> streamDriverLocation(String tripId) =>
      streamTripLocation(tripId);

  /// Removes the active trip document when the trip ends or is cancelled.
  Future<void> stopTripLocation(String tripId) async {
    if (tripId.isEmpty) return;
    try {
      await _firestore.collection(_collectionName).doc(tripId).delete();
    } catch (e) {
      debugPrint('Error deleting trip location in Firestore: $e');
    }
  }
}
