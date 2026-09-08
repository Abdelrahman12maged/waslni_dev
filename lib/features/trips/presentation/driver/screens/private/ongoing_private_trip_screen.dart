import 'package:flutter/material.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/private_ongoing/driver_private_ongoing_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Ongoing Private Trip Tracking Screen
// ─────────────────────────────────────────────────────────────────────────────
class DriverOngoingPrivateTripScreenClean extends StatelessWidget {
  final Trip? trip;
  final int? tripId;

  const DriverOngoingPrivateTripScreenClean({
    super.key,
    this.trip,
    this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return DriverPrivateOngoingView(
      trip: trip,
      tripId: tripId,
    );
  }
}
