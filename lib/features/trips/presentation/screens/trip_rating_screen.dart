import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/features/ratings/presentation/cubit/ratings_cubit.dart';
import 'package:car_app/features/ratings/presentation/widgets/trip_rating_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Trip Rating Screen
// ─────────────────────────────────────────────────────────────────────────────
class TripRatingScreen extends StatelessWidget {
  final int tripId;
  final int targetUserId;
  final String targetUserName;
  final bool isDriverRatingPassenger;
  final int? initialStars;
  final String? initialComment;
  final bool isEdit;

  const TripRatingScreen({
    super.key,
    required this.tripId,
    required this.targetUserId,
    this.targetUserName = '',
    this.isDriverRatingPassenger = false,
    this.initialStars,
    this.initialComment,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RatingsCubit>(),
      child: TripRatingView(
        tripId: tripId,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        isDriverRatingPassenger: isDriverRatingPassenger,
        initialStars: initialStars,
        initialComment: initialComment,
        isEdit: isEdit,
      ),
    );
  }
}
