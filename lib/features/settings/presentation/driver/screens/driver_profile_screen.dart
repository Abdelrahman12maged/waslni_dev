import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:car_app/features/settings/presentation/driver/screens/widgets/driver_profile_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Profile Screen
// ─────────────────────────────────────────────────────────────────────────────
class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) => di.sl<ProfileCubit>()..getUserMyProfile(),
      child: const DriverProfileView(),
    );
  }
}
