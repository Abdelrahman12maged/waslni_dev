import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_shared_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/add_trip/passenger_add_shared_trip_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Passenger Add Shared Trip Screen
// ─────────────────────────────────────────────────────────────────────────────
class PassengerAddSharedTripScreenClean extends StatelessWidget {
  const PassengerAddSharedTripScreenClean({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PassengerAddSharedTripCubit>(
      create: (_) => di.sl<PassengerAddSharedTripCubit>(),
      child: const PassengerAddSharedTripView(),
    );
  }
}
