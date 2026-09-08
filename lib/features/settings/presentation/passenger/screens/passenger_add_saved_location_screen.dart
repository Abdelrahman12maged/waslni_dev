import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/features/settings/presentation/cubit/saved_locations_cubit.dart';
import 'package:car_app/features/settings/presentation/passenger/screens/widgets/passenger_add_saved_location_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Passenger Add Saved Location Screen
// ─────────────────────────────────────────────────────────────────────────────
class PassengerAddSavedLocationScreen extends StatelessWidget {
  const PassengerAddSavedLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SavedLocationsCubit>(
      create: (context) => di.sl<SavedLocationsCubit>(),
      child: const PassengerAddSavedLocationView(),
    );
  }
}
