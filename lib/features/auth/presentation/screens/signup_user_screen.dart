import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_app/features/auth/presentation/widgets/signup_user_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Signup User Screen
// ─────────────────────────────────────────────────────────────────────────────
class SignupUserScreen extends StatelessWidget {
  const SignupUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: const SignupUserView(),
    );
  }
}
