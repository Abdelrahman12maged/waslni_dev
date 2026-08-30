import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/ratings/domain/entities/pending_rating_trip.dart';
import 'package:car_app/features/ratings/presentation/cubit/ratings_cubit.dart';
import 'package:car_app/features/ratings/presentation/cubit/ratings_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PendingRatingsScreen extends StatelessWidget {
  const PendingRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RatingsCubit>()..getPendingRatings(),
      child: const _PendingRatingsContent(),
    );
  }
}

class _PendingRatingsContent extends StatelessWidget {
  const _PendingRatingsContent();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          s.pendingRatingsTitle,
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
                      onPressed: () => RatingsCubit.get(context).getPendingRatings(),
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

          if (state is PendingRatingsEmpty) {
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
                      child: const Icon(Icons.star_rounded, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      s.pendingRatingsEmpty,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is PendingRatingsLoaded) {
            final trips = state.trips;
            return RefreshIndicator(
              onRefresh: () async => RatingsCubit.get(context).getPendingRatings(),
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.rate_review_outlined, color: AppColors.primary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.pendingRatingsSubtitle,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...trips.map((trip) => _PendingTripCard(trip: trip)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PendingTripCard extends StatelessWidget {
  final PendingRatingTrip trip;

  const _PendingTripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final driver = trip.driver;
    final photoUrl = ApiEndpoints.buildImageUrl(driver.photo);
    final dateStr = trip.tripDatetime != null
        ? DateFormat('dd/MM/yyyy • hh:mm a').format(trip.tripDatetime!)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Row
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: appCachedImageProvider(photoUrl),
                child: photoUrl == null
                    ? const Icon(Icons.person, color: AppColors.primary, size: 28)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name.isNotEmpty ? driver.name : s.driver,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (driver.ratingAvg != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            driver.ratingAvg!.toStringAsFixed(1),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          if (driver.ratingsCount != null && driver.ratingsCount! > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${driver.ratingsCount})',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (dateStr.isNotEmpty)
                Text(
                  dateStr,
                  style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey.shade500),
                ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),

          // Route Details
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 10, color: AppColors.primary),
                  Container(
                    width: 1.5,
                    height: 20,
                    color: Colors.grey.shade300,
                  ),
                  const Icon(Icons.location_on, size: 12, color: Colors.red),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.fromLocationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trip.toLocationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rate Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.push(
                  AppRoutes.tripRating,
                  extra: {
                    'trip_id': trip.tripId,
                    'target_user_id': driver.id,
                    'target_user_name': driver.name,
                    'is_driver': false,
                  },
                );
                if (context.mounted) {
                  RatingsCubit.get(context).getPendingRatings();
                }
              },
              icon: const Icon(Icons.star_rounded, size: 20, color: Colors.white),
              label: Text(
                s.rateTripAction,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
