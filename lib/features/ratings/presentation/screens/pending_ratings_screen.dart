import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/features/ratings/presentation/cubit/ratings_cubit.dart';
import 'package:car_app/features/ratings/presentation/widgets/pending_ratings_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pending Ratings Screen
// ─────────────────────────────────────────────────────────────────────────────
class PendingRatingsScreen extends StatelessWidget {
  const PendingRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RatingsCubit>()..getPendingRatings(),
      child: const PendingRatingsView(),
    );
  }
}
