import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/widgets/passenger_trips_list_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Passenger Trips List Screen
// ─────────────────────────────────────────────────────────────────────────────
class PassengerTripsListScreenClean extends StatelessWidget {
  const PassengerTripsListScreenClean({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PassengerTripsCubit>(
      create: (context) => di.sl<PassengerTripsCubit>()..loadPassengerTrips(),
      child: const PassengerTripsListView(),
    );
  }
}
