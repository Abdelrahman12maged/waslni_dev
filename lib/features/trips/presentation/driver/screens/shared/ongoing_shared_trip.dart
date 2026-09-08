import 'package:flutter/material.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/shared_ongoing/driver_ongoing_shared_trip_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Ongoing Shared Trip Tracking Screen
// ─────────────────────────────────────────────────────────────────────────────
class DriverOngoingSharedTripScreenClean extends StatelessWidget {
  /// Typed trip entity — provided when navigating from the trips list screen.
  final Trip? trip;

  /// Trip ID — provided when launched via FCM notification (cold start / app terminated).
  final int? tripId;

  const DriverOngoingSharedTripScreenClean({
    super.key,
    this.trip,
    this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return DriverOngoingSharedTripView(
      trip: trip,
      tripId: tripId,
    );
  }
}
