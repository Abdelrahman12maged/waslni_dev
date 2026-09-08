import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/features/ratings/presentation/cubit/ratings_cubit.dart';
import 'package:car_app/features/ratings/presentation/widgets/my_ratings_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// My Ratings Screen
// ─────────────────────────────────────────────────────────────────────────────
class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RatingsCubit>()..getMyRatings(),
      child: const MyRatingsView(),
    );
  }
}
