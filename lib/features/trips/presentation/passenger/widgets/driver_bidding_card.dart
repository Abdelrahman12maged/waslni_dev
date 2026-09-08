import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/formatters/plate_number_formatter.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/widgets/unread_badge.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/driver_details_modal.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

String _formatPrice(double price) {
  if (price == price.roundToDouble()) {
    return price.toStringAsFixed(0);
  }
  final s = price.toStringAsFixed(2);
  return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}

class DriverBiddingCard extends StatelessWidget {
  final Offer offer;
  final Trip? trip;
  final int index;
  final String currency;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const DriverBiddingCard({
    super.key,
    required this.offer,
    this.trip,
    required this.index,
    required this.currency,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final driver = offer.driver;
    final driverName = driver?.name.isNotEmpty == true
        ? driver!.name
        : S.of(context).driverDefaultName;
    final ratingStr = driver?.rating?.isNotEmpty == true
        ? driver!.rating!
        : (driver?.ratingAvg != null
            ? driver!.ratingAvg!.toStringAsFixed(1)
            : null);
    final car = driver?.car;
    final carParts = [
      if (car != null && car.type.isNotEmpty) car.type,
      if (car != null && car.model.isNotEmpty) car.model,
    ];
    final carModel = carParts.isNotEmpty
        ? carParts.join(' ')
        : (car?.plateNumber.isNotEmpty == true
            ? PlateNumberFormatter.format(car!.plateNumber)
            : S.of(context).driverCarLabel);
    final tripsCountStr =
        (driver?.tripsCount != null && driver!.tripsCount! > 0)
            ? S.of(context).tripsCountLabel(driver!.tripsCount!)
            : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showDriverDetailsModal(
            context,
            offer: offer,
            trip: trip,
            currency: currency,
            onAccept: onAccept,
            onReject: onReject,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.18), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top Header Row: Driver Avatar, Info, and Price Badge ────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                child: Row(
                  children: [
                    // Driver Avatar with Rating Badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: appCachedImageProvider(
                              ApiEndpoints.buildImageUrl(driver?.photo)),
                          child: (driver?.photo == null ||
                                  ApiEndpoints.buildImageUrl(driver!.photo) ==
                                      null)
                              ? const Icon(Icons.person,
                                  size: 22, color: Colors.grey)
                              : null,
                        ),
                        if (ratingStr != null)
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2235),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: Colors.amber, size: 10),
                                  const SizedBox(width: 1),
                                  Text(
                                    ratingStr,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),

                    // Driver Details & Car Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            driverName,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: const Color(0xFF1E2235),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$carModel$tripsCountStr',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Price Tag
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_formatPrice(offer.price)} $currency',
                          style: GoogleFonts.cairo(
                            color: AppColors.primary,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Action Buttons: Reject, Chat with Badge & Accept ───────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
                child: Row(
                  children: [
                    // Reject Button
                    Material(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: onReject,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          child: Text(
                            S.of(context).reject,
                            style: GoogleFonts.cairo(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Direct Chat Button with Unread Badge
                    Builder(
                      builder: (context) {
                        final targetChatId =
                            ChatChannelHelper.privateTripChatId(
                          tripId: trip?.id ?? offer.tripId,
                          driverId: offer.driverId > 0
                              ? offer.driverId
                              : (driver?.id ?? 0),
                        );
                        final currentUid = sl<LocalStorage>()
                                .read(key: 'userid')
                                ?.toString() ??
                            sl<LocalStorage>()
                                .read(key: 'user_id')
                                ?.toString() ??
                            '';
                        return UnreadBadge(
                          chatId: targetChatId,
                          currentUserId: currentUid,
                          child: Material(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
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
                                    driverId: offer.driverId > 0
                                        ? offer.driverId
                                        : (driver?.id ?? 0),
                                    isOffersPhase: true,
                                    tripType: 'private',
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
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 34,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                  ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),

                    // Accept Button with Green Accent
                    Expanded(
                      child: Material(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: onAccept,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 34,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  S.of(context).acceptOffer,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
