import 'package:flutter/material.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/driver_private_suspended_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Private Suspended Screen
// ─────────────────────────────────────────────────────────────────────────────
class DriverPrivateSuspendedScreenClean extends StatelessWidget {
  final Trip trip;

  const DriverPrivateSuspendedScreenClean({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return DriverPrivateSuspendedView(trip: trip);
  }
}
