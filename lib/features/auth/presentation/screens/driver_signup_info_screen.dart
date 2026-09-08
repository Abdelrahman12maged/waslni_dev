import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/features/auth/domain/entities/driver_signup_initial_data.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_app/features/auth/presentation/widgets/driver_signup_info_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Signup Info Screen
// ─────────────────────────────────────────────────────────────────────────────
class DriverSignupInfoScreen extends StatelessWidget {
  final DriverSignupInitialData initialData;

  const DriverSignupInfoScreen({super.key, required this.initialData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: DriverSignupInfoView(initialData: initialData),
    );
  }
}
