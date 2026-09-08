import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:car_app/features/settings/presentation/passenger/screens/widgets/passenger_profile_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Passenger Profile Screen
// ─────────────────────────────────────────────────────────────────────────────
class PassengerProfileScreen extends StatelessWidget {
  const PassengerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) => di.sl<ProfileCubit>()..getUserMyProfile(),
      child: const PassengerProfileView(),
    );
  }
}
