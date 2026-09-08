import 'package:flutter/material.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/widgets/passenger_shared_offers_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared Current Trips Screen (Passenger Offers Phase)
// ─────────────────────────────────────────────────────────────────────────────
class SharedCurrentTripsScreenClean extends StatelessWidget {
  final Trip? trip;
  final int? id;
  final double? proposed_fare;
  final bool? is_auto_accept;

  const SharedCurrentTripsScreenClean({
    super.key,
    this.trip,
    this.id,
    this.proposed_fare,
    this.is_auto_accept,
  });

  @override
  Widget build(BuildContext context) {
    return PassengerSharedOffersView(
      trip: trip,
      id: id,
      proposed_fare: proposed_fare,
      is_auto_accept: is_auto_accept,
    );
  }
}
