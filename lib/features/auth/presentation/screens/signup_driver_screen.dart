import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_app/features/auth/presentation/widgets/signup_driver_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Signup Driver Screen
// ─────────────────────────────────────────────────────────────────────────────
class SignupDriverScreen extends StatelessWidget {
  const SignupDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: const SignupDriverView(),
    );
  }
}
