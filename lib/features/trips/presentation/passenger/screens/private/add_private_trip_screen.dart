import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/add_trip/passenger_add_private_trip_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Passenger Add Private Trip Screen
// ─────────────────────────────────────────────────────────────────────────────
class AddPrivateTripScreenClean extends StatelessWidget {
  final String? presetDestinationName;
  final double? presetDestinationLat;
  final double? presetDestinationLng;

  const AddPrivateTripScreenClean({
    super.key,
    this.presetDestinationName,
    this.presetDestinationLat,
    this.presetDestinationLng,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PassengerAddPrivateTripCubit>(
      create: (_) => di.sl<PassengerAddPrivateTripCubit>(),
      child: PassengerAddPrivateTripView(
        presetDestinationName: presetDestinationName,
        presetDestinationLat: presetDestinationLat,
        presetDestinationLng: presetDestinationLng,
      ),
    );
  }
}
