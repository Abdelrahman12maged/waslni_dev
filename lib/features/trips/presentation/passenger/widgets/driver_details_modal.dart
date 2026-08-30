import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/formatters/plate_number_formatter.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/entities/trip_driver.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows a comprehensive, interactive Driver Details Modal Bottom Sheet.
/// Displays driver photo, rating, vehicle details, trips count, direct Chat button,
/// and Accept/Reject offer actions.
void showDriverDetailsModal(
  BuildContext context, {
  required Offer offer,
  required Trip? trip,
  required String currency,
  required VoidCallback onAccept,
  required VoidCallback onReject,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _DriverDetailsModalContent(
      offer: offer,
      trip: trip,
      currency: currency,
      onAccept: onAccept,
      onReject: onReject,
    ),
  );
}

class _DriverDetailsModalContent extends StatelessWidget {
  final Offer offer;
  final Trip? trip;
  final String currency;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _DriverDetailsModalContent({
    required this.offer,
    required this.trip,
    required this.currency,
    required this.onAccept,
    required this.onReject,
  });

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toStringAsFixed(0);
    }
    final s = price.toStringAsFixed(2);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final TripDriver? driver = offer.driver;
    final driverName = driver?.name.isNotEmpty == true
        ? driver!.name
        : S.of(context).driverDefaultName;
    final String? photoUrl = ApiEndpoints.buildImageUrl(driver?.photo);
    final ratingAvg = driver?.ratingAvg ??
        (driver?.rating != null ? double.tryParse(driver!.rating!) : null);
    final ratingsCount = driver?.ratingsCount ?? 0;
    final car = driver?.car;
    final String carType = car?.type.isNotEmpty == true ? car!.type : '';
    final String carModel = car?.model.isNotEmpty == true ? car!.model : '';
    final String carColor = car?.color?.isNotEmpty == true ? car!.color! : '';
    final String carPlate = car?.plateNumber.isNotEmpty == true ? car!.plateNumber : '';
    final tripsCount = driver?.tripsCount ?? 0;
    final formattedPrice = _formatPrice(offer.price);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
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

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).captainDetails,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E2235),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Driver Card Profile Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Large Driver Avatar with Glowing border
                    AppCachedNetworkImage(
                      imageUrl: photoUrl,
                      width: 60,
                      height: 60,
                      isCircle: true,
                      fallbackIcon: Icons.person,
                    ),
                  const SizedBox(width: 14),

                  // Name, Trips, Ratings
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E2235),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Rating & Reviews Clickable link
                        InkWell(
                          onTap: () {
                            if (driver != null && driver.id != 0) {
                              Navigator.pop(context);
                              context.push(
                                AppRoutes.driverRatings,
                                extra: {
                                  'driver_id': driver.id,
                                  'driver_name': driver.name,
                                },
                              );
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Colors.amber.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: Colors.amber, size: 14),
                                    const SizedBox(width: 3),
                                    Text(
                                      ratingAvg != null
                                          ? ratingAvg.toStringAsFixed(1)
                                          : '--',
                                      style: GoogleFonts.cairo(
                                        color: Colors.amber.shade900,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (ratingsCount > 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  S.of(context).ratingsCountLabel(ratingsCount),
                                  style: GoogleFonts.cairo(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                              if (tripsCount > 0) ...[
                                const SizedBox(width: 8),
                                Text(
                                  S.of(context).tripsCountLabel(tripsCount),
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Vehicle Details Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.directions_car_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        S.of(context).vehicleDetails,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E2235),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Car Model
                      Expanded(
                        child: _DetailTile(
                          label: S.of(context).carModelLabel,
                          value: (carType.isNotEmpty || carModel.isNotEmpty)
                              ? '$carType $carModel'.trim()
                              : S.of(context).notSpecified,
                          icon: Icons.car_repair_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Plate Number
                      Expanded(
                        child: _DetailTile(
                          label: S.of(context).plateNumberLabel,
                          value: carPlate.isNotEmpty ? PlateNumberFormatter.format(carPlate) : S.of(context).notSpecified,
                          icon: Icons.confirmation_number_outlined,
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                    ],
                  ),
                  if (carColor.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _DetailTile(
                      label: S.of(context).carColorLabel,
                      value: carColor,
                      icon: Icons.palette_outlined,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Offer Price Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.06),
                    AppColors.primary.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.primary.withOpacity(0.18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).offeredPriceByCaptain,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$formattedPrice $currency',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action Buttons: Chat with Driver + Accept / Reject
            Row(
              children: [
                // Direct Chat Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      final tripId = trip?.id ?? offer.tripId;
                      navigateTo(
                        context,
                        TripChatScreenClean(
                          driverName: driverName,
                          driverPhone: driver?.phone ?? '',
                          driverPhoto: driver?.photo,
                          tripFrom: trip?.fromLocationName ?? '',
                          tripTo: trip?.toLocationName ?? '',
                          tripDatetime: trip?.tripDatetime ?? '',
                          acceptedPrice: offer.price,
                          tripId: tripId,
                          offerId: offer.id,
                          driverId: driver?.id ?? offer.driverId,
                          isOffersPhase: true,
                          tripType: trip?.type == TripType.shared
                              ? 'shared'
                              : 'private',
                          members: [
                            if (driver != null)
                              {
                                'id': driver.id,
                                'name': driver.name,
                                'phone': driver.phone,
                                'photo': driver.photo,
                                'fcm_token': driver.fcmToken,
                                'is_driver': true,
                              },
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 16, color: AppColors.primary),
                    label: Text(
                      S.of(context).chatAction,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (driver?.phone != null && driver!.phone!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  // Phone Call Button
                  IconButton(
                    onPressed: () async {
                      final uri = Uri.parse('tel:${driver.phone}');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const Icon(Icons.phone_rounded,
                        color: AppColors.success, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.success.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),

                // Reject Button
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onReject();
                  },
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.red, size: 20),
                  tooltip: S.of(context).reject,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Accept Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onAccept();
                    },
                    icon: const Icon(Icons.check_circle_rounded,
                        size: 18, color: Colors.white),
                    label: Text(
                      S.of(context).acceptOffer,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final TextDirection? textDirection;

  const _DetailTile({
    required this.label,
    required this.value,
    required this.icon,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  textDirection: textDirection,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E2235),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
