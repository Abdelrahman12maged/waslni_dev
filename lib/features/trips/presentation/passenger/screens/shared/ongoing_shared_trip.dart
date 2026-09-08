import 'package:flutter/material.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/shared_ongoing/passenger_ongoing_shared_trip_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PassengerOngoingSharedTripScreenClean — Uber/InDriver style
// ─────────────────────────────────────────────────────────────────────────────
class PassengerOngoingSharedTripScreenClean extends StatelessWidget {
  final Trip? trip;
  final int? tripId;
  final dynamic tripDetails;
  final dynamic userData;

  const PassengerOngoingSharedTripScreenClean({
    super.key,
    this.trip,
    this.tripId,
    this.tripDetails,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return PassengerOngoingSharedTripView(
      trip: trip,
      tripId: tripId,
      tripDetails: tripDetails,
      userData: userData,
    );
  }
}
