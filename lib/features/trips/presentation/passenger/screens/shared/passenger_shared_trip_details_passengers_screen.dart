import 'package:flutter/material.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/widgets/passenger_shared_trip_details_passengers_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Passenger Shared Trip Details Passengers Screen
// ─────────────────────────────────────────────────────────────────────────────
class PassengerSharedTripDetailsPassengersScreenClean extends StatelessWidget {
  final Trip? trip;
  final int? tripId;

  const PassengerSharedTripDetailsPassengersScreenClean({
    super.key,
    this.trip,
    this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return PassengerSharedTripDetailsPassengersView(
      trip: trip,
      tripId: tripId,
    );
  }
}
