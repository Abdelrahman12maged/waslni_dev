import 'dart:developer';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/ratings/domain/entities/pending_rating_trip.dart';
import 'package:car_app/features/ratings/domain/usecases/get_pending_ratings_usecase.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:car_app/core/utils/trip_security_service.dart';

class RatingPromptHelper {
  static const String _kDismissedKey = 'dismissed_rating_trip_ids';

  /// Check if a specific trip has been dismissed or already rated by the passenger
  static bool isTripDismissed(int tripId) {
    if (tripId <= 0) return true;
    try {
      final storage = sl<LocalStorage>();
      final isRated = storage.read(key: 'rated_trip_$tripId');
      if (isRated == true || isRated == 'true') return true;

      final isDismissed = storage.read(key: 'dismissed_rating_$tripId');
      if (isDismissed == true || isDismissed == 'true') return true;

      final list = storage.readStringList(key: _kDismissedKey) ?? [];
      return list.contains(tripId.toString());
    } catch (_) {
      return false;
    }
  }

  /// Mark a trip as completely rated so the passenger is never asked again
  static Future<void> markTripRated(int tripId) async {
    if (tripId <= 0) return;
    try {
      final storage = sl<LocalStorage>();
      await storage.saveBool(key: 'rated_trip_$tripId', value: true);
      await storage.saveBool(key: 'dismissed_rating_$tripId', value: true);
      await dismissTripRating(tripId);
      log('RatingPromptHelper: marked trip $tripId as rated', name: 'RatingPrompt');
    } catch (e) {
      log('RatingPromptHelper: error marking trip rated: $e', name: 'RatingPrompt');
    }
  }

  /// Mark a trip as dismissed so the passenger is not asked again for this trip
  static Future<void> dismissTripRating(int tripId) async {
    if (tripId <= 0) return;
    try {
      final storage = sl<LocalStorage>();
      await storage.saveBool(key: 'dismissed_rating_$tripId', value: true);
      final rawList = storage.readStringList(key: _kDismissedKey) ?? [];
      final list = List<String>.from(rawList);
      final idStr = tripId.toString();
      if (!list.contains(idStr)) {
        list.add(idStr);
        await storage.saveStringList(key: _kDismissedKey, value: list);
        log('RatingPromptHelper: dismissed rating for trip $tripId', name: 'RatingPrompt');
      }
    } catch (e) {
      log('RatingPromptHelper: error dismissing rating: $e', name: 'RatingPrompt');
    }
  }

  /// Check for any pending unrated trip and show rating dialog on passenger home launch
  static Future<void> checkAndShowPendingRating(BuildContext context) async {
    try {
      if (!context.mounted) return;

      final storage = sl<LocalStorage>();
      final userType = storage.read(key: 'user_type')?.toString() ??
          storage.read(key: 'usertype')?.toString() ??
          '';
      if (userType != 'passenger') return;

      // ── Safety Guard 1: Never interrupt active ongoing trip with rating dialog ──
      final activeTrip = TripSecurityService.getActiveTrip(storage);
      if (activeTrip != null && TripSecurityService.isPreTripTrackingActive(activeTrip)) {
        log('RatingPromptHelper: active trip in progress, skipping rating check', name: 'RatingPrompt');
        return;
      }

      final ongoingTrip = storage.read(key: 'ongoing_trip')?.toString();
      if (ongoingTrip != null && ongoingTrip.isNotEmpty && ongoingTrip != 'none') {
        log('RatingPromptHelper: ongoing trip flag active, skipping rating check', name: 'RatingPrompt');
        return;
      }

      final token = storage.read(key: 'usertoken')?.toString() ?? '';
      if (token.isEmpty) return;

      // ── Safety Guard 2: Only show rating dialog when on Passenger Home Screen ──
      try {
        final currentPath = GoRouterState.of(context).matchedLocation;
        if (currentPath != AppRoutes.passengerHome) {
          log('RatingPromptHelper: current path is $currentPath, skipping rating dialog', name: 'RatingPrompt');
          return;
        }
      } catch (_) {}

      final getPending = sl<GetPendingRatingsUseCase>();
      final result = await getPending();

      result.fold(
        (_) => null,
        (pendingTrips) {
          if (!context.mounted || pendingTrips.isEmpty) return;

          // Re-check route right before showing dialog
          try {
            final currentPath = GoRouterState.of(context).matchedLocation;
            if (currentPath != AppRoutes.passengerHome) return;
          } catch (_) {}

          // Find the first trip that hasn't been dismissed by the passenger
          PendingRatingTrip? targetTrip;
          for (final trip in pendingTrips) {
            if (!isTripDismissed(trip.tripId)) {
              targetTrip = trip;
              break;
            }
          }

          if (targetTrip != null && context.mounted) {
            _showRatingDialog(context, targetTrip);
          }
        },
      );
    } catch (e) {
      log('RatingPromptHelper: checkAndShowPendingRating error: $e', name: 'RatingPrompt');
    }
  }

  static void _showRatingDialog(BuildContext context, PendingRatingTrip trip) {
    final s = S.of(context);
    final driverName = trip.driver.name.isNotEmpty ? trip.driver.name : s.driver;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                s.ratingScreenTitle,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.rateYourExperienceWith(driverName),
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            if (trip.fromLocationName.isNotEmpty && trip.toLocationName.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.route_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${trip.fromLocationName} ➔ ${trip.toLocationName}',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: const Color(0xFF475569),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              dismissTripRating(trip.tripId);
            },
            child: Text(
              s.cancel,
              style: GoogleFonts.cairo(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              dismissTripRating(trip.tripId);
              context.push(
                AppRoutes.tripRating,
                extra: {
                  'trip_id': trip.tripId,
                  'target_user_id': trip.driver.id,
                  'target_user_name': trip.driver.name,
                  'is_driver': false,
                },
              );
            },
            child: Text(
              s.ratingScreenTitle,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
