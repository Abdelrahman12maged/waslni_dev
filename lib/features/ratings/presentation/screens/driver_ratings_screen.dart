import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/ratings/domain/entities/driver_ratings_page.dart';
import 'package:car_app/features/ratings/domain/entities/rating.dart';
import 'package:car_app/features/ratings/domain/entities/rating_summary.dart';
import 'package:car_app/features/ratings/presentation/cubit/ratings_cubit.dart';
import 'package:car_app/features/ratings/presentation/cubit/ratings_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DriverRatingsScreen extends StatelessWidget {
  final int driverId;
  final String? driverName;

  const DriverRatingsScreen({
    super.key,
    required this.driverId,
    this.driverName,
  });

  int get _effectiveDriverId {
    if (driverId > 0) return driverId;
    try {
      final storage = di.sl<LocalStorage>();
      return int.tryParse(
            storage.read(key: 'userid')?.toString() ??
            storage.read(key: 'user_id')?.toString() ??
            storage.read(key: 'driver_id')?.toString() ??
            '',
          ) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveId = _effectiveDriverId;
    return BlocProvider(
      create: (_) => di.sl<RatingsCubit>()..getDriverRatings(driverId: effectiveId),
      child: _DriverRatingsContent(
        driverId: effectiveId,
        driverName: driverName,
      ),
    );
  }
}

class _DriverRatingsContent extends StatelessWidget {
  final int driverId;
  final String? driverName;

  const _DriverRatingsContent({
    required this.driverId,
    this.driverName,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final title = driverName != null && driverName!.isNotEmpty
        ? '${s.driverRatingsTitle} - $driverName'
        : s.driverRatingsTitle;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          title,
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
                      onPressed: () => RatingsCubit.get(context).getDriverRatings(driverId: driverId),
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

          if (state is DriverRatingsLoaded) {
            final page = state.page;
            return RefreshIndicator(
              onRefresh: () async => RatingsCubit.get(context).getDriverRatings(driverId: driverId),
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary & Breakdown Card
                  _DriverRatingSummaryCard(summary: page.summary),
                  const SizedBox(height: 16),

                  if (page.ratings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          s.driverRatingsEmpty,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    )
                  else
                    ...page.ratings.map((r) => _DriverReviewItem(rating: r)),
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

class _DriverRatingSummaryCard extends StatelessWidget {
  final RatingSummary summary;

  const _DriverRatingSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final totalCount = summary.count;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Big Rating Number & Stars
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  summary.average.toStringAsFixed(1),
                  style: GoogleFonts.cairo(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1.1,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (idx) {
                    return Icon(
                      idx < summary.average.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 18,
                      color: idx < summary.average.round() ? Colors.amber : Colors.grey.shade300,
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  s.ratingCountLabel(totalCount),
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 1,
            height: 110,
            color: const Color(0xFFEEEEEE),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Right: Star Breakdown Progress Bars (5 down to 1)
          Expanded(
            flex: 6,
            child: Column(
              children: [5, 4, 3, 2, 1].map((stars) {
                final count = summary.breakdown[stars] ?? 0;
                final fraction = totalCount > 0 ? (count / totalCount) : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    children: [
                      Text(
                        '$stars',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFF0F0F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 24,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverReviewItem extends StatelessWidget {
  final Rating rating;

  const _DriverReviewItem({required this.rating});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final passengerName = rating.passengerName?.isNotEmpty == true
        ? rating.passengerName!
        : s.passenger;
    final dateStr = rating.createdAt != null
        ? DateFormat('dd/MM/yyyy').format(rating.createdAt!)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.08),
                child: Text(
                  passengerName.isNotEmpty ? passengerName[0] : 'P',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passengerName,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (starIdx) {
                  return Icon(
                    starIdx < rating.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 16,
                    color: starIdx < rating.stars ? Colors.amber : Colors.grey.shade300,
                  );
                }),
              ),
            ],
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              rating.comment!,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
