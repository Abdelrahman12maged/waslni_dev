import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_search_shared_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/widgets/passenger_search_shared_trips_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Passenger Search Shared Trips Screen
// ─────────────────────────────────────────────────────────────────────────────
class PassengerSearchSharedTripsScreen extends StatelessWidget {
  const PassengerSearchSharedTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PassengerSearchSharedTripsCubit>(
      create: (context) => sl<PassengerSearchSharedTripsCubit>()..init(),
      child: const PassengerSearchSharedTripsView(),
    );
  }
}
