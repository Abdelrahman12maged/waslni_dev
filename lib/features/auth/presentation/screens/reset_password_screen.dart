import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_app/features/auth/presentation/widgets/reset_password_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Reset Password Screen
// ─────────────────────────────────────────────────────────────────────────────
class ResetPasswordScreen extends StatelessWidget {
  final String mobile;

  const ResetPasswordScreen({super.key, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: ResetPasswordView(mobile: mobile),
    );
  }
}
