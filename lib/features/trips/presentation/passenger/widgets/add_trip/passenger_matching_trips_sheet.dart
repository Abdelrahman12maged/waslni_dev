import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_shared_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/passenger_shared_trip_details_passengers_screen.dart';
import 'package:car_app/generated/l10n.dart';

/// Modal bottom sheet shown when matching shared trips already exist on the selected route.
void showMatchingTripFoundSheet(
  BuildContext parentCtx, {
  required PassengerAddSharedTripCubit cubit,
  required dynamic trip,
  required List<dynamic> allMatches,
}) {
  showModalBottomSheet(
    context: parentCtx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bCtx) {
      final driver = trip.driver;
      final driverName = driver?.name.isNotEmpty == true
          ? driver!.name
          : S.of(parentCtx).certifiedDriver;
      final driverPhoto = ApiEndpoints.buildImageUrl(driver?.photo);
      final totalSeats = trip.totalSeats > 0 ? trip.totalSeats : 4;
      final reservedSeats = trip.reservedSeats > 0
          ? trip.reservedSeats
          : (trip.passengers.isNotEmpty
              ? trip.passengers
                  .fold<int>(0, (sum, p) => sum + (p.seats > 0 ? p.seats : 1))
              : (trip.availableSeats >= 0 && totalSeats > trip.availableSeats
                  ? (totalSeats - trip.availableSeats)
                  : 0));
      final availSeats = trip.availableSeats >= 0
          ? trip.availableSeats
          : (totalSeats - reservedSeats).clamp(0, totalSeats);

      double totalAgreedPrice =
          (trip.approvedPrice != null && trip.approvedPrice! > 0)
              ? trip.approvedPrice!
              : 0.0;
      if (totalAgreedPrice <= 0 && trip.offers.isNotEmpty) {
        for (final o in trip.offers) {
          if (o.effectiveStatus == 'accepted' ||
              o.effectiveStatus == 'approved') {
            totalAgreedPrice = o.price;
            break;
          }
        }
      }
      if (totalAgreedPrice <= 0) {
        totalAgreedPrice =
            trip.maximumPrice > 0 ? trip.maximumPrice : trip.minimumPrice;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Badge & Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(parentCtx).foundNearbySharedTrip,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        S.of(parentCtx).foundNearbySharedTripDesc,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Trip preview card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // Driver & Seats
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: appCachedImageProvider(driverPhoto),
                        child: (driverPhoto == null || driverPhoto.isEmpty)
                            ? const Icon(Icons.person, color: Colors.grey)
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
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            if (trip.tripDatetime.isNotEmpty)
                              Text(
                                trip.tripDatetime,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          '$availSeats ${S.of(parentCtx).availableSeatsUnit}',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Locations
                  Row(
                    children: [
                      const Icon(Icons.radio_button_checked,
                          size: 14, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trip.fromLocationName,
                          style: GoogleFonts.cairo(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trip.toLocationName,
                          style: GoogleFonts.cairo(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (totalAgreedPrice > 0) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${totalAgreedPrice.toStringAsFixed(2)} ${S.of(parentCtx).jod} ${S.of(parentCtx).tripTotalLabel}',
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login, size: 18),
                label: Text(
                  S.of(parentCtx).joinTripAndViewDetails,
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(bCtx);
                  Navigator.push(
                    parentCtx,
                    MaterialPageRoute(
                      builder: (_) =>
                          PassengerSharedTripDetailsPassengersScreenClean(
                              trip: trip),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(bCtx);
                  cubit.forceCreateTrip(parentCtx);
                },
                child: Text(
                  S.of(parentCtx).continueCreatingMyNewTrip,
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
