import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';

import 'package:car_app/features/ratings/domain/entities/rating.dart';
import 'package:car_app/features/ratings/presentation/cubit/ratings_cubit.dart';
import 'package:car_app/features/ratings/presentation/cubit/ratings_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RatingsCubit>()..getMyRatings(),
      child: const _MyRatingsContent(),
    );
  }
}

class _MyRatingsContent extends StatelessWidget {
  const _MyRatingsContent();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          s.myRatingsTitle,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<RatingsCubit, RatingsState>(
        builder: (context, state) {
          if (state is RatingsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is RatingsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 56, color: Colors.red.shade300),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => RatingsCubit.get(context).getMyRatings(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(s.retryAction, style: GoogleFonts.cairo(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MyRatingsLoaded) {
            final ratings = state.page.ratings;
            if (ratings.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.08),
                        ),
                        child: const Icon(Icons.rate_review_outlined, size: 44, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.myRatingsEmpty,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => RatingsCubit.get(context).getMyRatings(),
              color: AppColors.primary,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: ratings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _MyRatingCard(rating: ratings[index]);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MyRatingCard extends StatelessWidget {
  final Rating rating;

  const _MyRatingCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final driver = rating.driver;
    final driverName = driver?.name.isNotEmpty == true ? driver!.name : s.driver;
    final photoUrl = ApiEndpoints.buildImageUrl(driver?.photo);
    final dateStr = rating.createdAt != null
        ? DateFormat('dd/MM/yyyy • hh:mm a').format(rating.createdAt!)
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Driver info + Date
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: appCachedImageProvider(photoUrl),
                child: photoUrl == null
                    ? const Icon(Icons.person, color: AppColors.primary, size: 22)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (dateStr.isNotEmpty)
                      Text(
                        dateStr,
                        style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ),
              // Stars Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (starIdx) {
                  return Icon(
                    starIdx < rating.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 20,
                    color: starIdx < rating.stars ? Colors.amber : Colors.grey.shade300,
                  );
                }),
              ),
            ],
          ),

          // Comment if available
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Text(
                rating.comment!,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Footer: Edit Affordance or Locked Badge
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      rating.isEditable
                          ? Icons.edit_calendar_rounded
                          : Icons.lock_clock_rounded,
                      size: 14,
                      color: rating.isEditable ? Colors.green.shade700 : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        rating.isEditable
                            ? s.ratingEditWindowNote
                            : s.ratingLockedNote,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: rating.isEditable ? Colors.green.shade800 : Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (rating.isEditable) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () async {
                    await context.push(
                      AppRoutes.tripRating,
                      extra: {
                        'trip_id': rating.tripId,
                        'target_user_id': rating.driverId,
                        'target_user_name': driverName,
                        'is_driver': false,
                        'initial_stars': rating.stars,
                        'initial_comment': rating.comment,
                        'is_edit': true,
                      },
                    );
                    if (context.mounted) {
                      RatingsCubit.get(context).getMyRatings();
                    }
                  },
                  icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
                  label: Text(
                    s.editRatingBtn,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
