import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_shared_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/add_trip/new_shared_trip_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Add Shared Trip Screen
// ─────────────────────────────────────────────────────────────────────────────
class AddNewSharedTripDriver extends StatelessWidget {
  const AddNewSharedTripDriver({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DriverAddSharedTripCubit>(
      create: (context) => di.sl<DriverAddSharedTripCubit>(),
      child: const NewSharedTripDriverView(),
    );
  }
}
