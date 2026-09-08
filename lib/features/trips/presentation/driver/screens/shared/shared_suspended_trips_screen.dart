import 'package:flutter/material.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/driver_shared_suspended_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Shared Suspended Trips Screen
// ─────────────────────────────────────────────────────────────────────────────
class SharedSuspendedTripsScreenClean extends StatelessWidget {
  final Trip trip;

  const SharedSuspendedTripsScreenClean({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return DriverSharedSuspendedView(trip: trip);
  }
}
