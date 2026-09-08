import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/features/map/presentation/cubit/map_cubit.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/private_current/passenger_private_current_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PassengerCurrentPrivateTripScreenClean — Uber/InDriver style
// ─────────────────────────────────────────────────────────────────────────────
class PassengerCurrentPrivateTripScreenClean extends StatelessWidget {
  final Trip? trip;
  final int? tripId;
  final dynamic tripDetails;
  final dynamic userData;

  const PassengerCurrentPrivateTripScreenClean({
    super.key,
    this.trip,
    this.tripId,
    this.tripDetails,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapCubit>(
      create: (_) => sl<MapCubit>()..loadCurrentLocation(),
      child: PassengerCurrentPrivateTripView(
        trip: trip,
        tripId: tripId,
        tripDetails: tripDetails,
        userData: userData,
      ),
    );
  }
}
