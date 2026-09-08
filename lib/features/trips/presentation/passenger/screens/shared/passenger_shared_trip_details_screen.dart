import 'package:flutter/material.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/widgets/passenger_shared_trip_details_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Passenger Shared Trip Details Screen (Offers / Joining)
// ─────────────────────────────────────────────────────────────────────────────
class PassengerSharedTripDetailsScreenClean extends StatelessWidget {
  final Trip? trip;
  final int? tripId;

  const PassengerSharedTripDetailsScreenClean({
    super.key,
    this.trip,
    this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return PassengerSharedTripDetailsView(
      trip: trip,
      tripId: tripId,
    );
  }
}
