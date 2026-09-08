import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/widgets/unread_badge.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/screens/private/ongoing_private_trip_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/shared/ongoing_shared_trip.dart';
import 'package:car_app/generated/l10n.dart';

/// Cleans location name by stripping plus codes, postal codes, and duplicates.
String cleanLocationName(String? raw) {
  if (raw == null) return '';
  var text = raw.trim();
  if (text.isEmpty) return '';

  text = text.replaceAll(
      RegExp(r'\b[A-Za-z0-9]{2,8}\+[A-Za-z0-9]{2,8}\b', caseSensitive: false),
      '');
  text = text.replaceAll(RegExp(r'\b\d+\b'), '');
  text = text.replaceAll('،', ',');
  final parts = text.split(',');

  final cleanedTokens = <String>[];
  for (var part in parts) {
    var p = part
        .replaceAll(RegExp(r'[#@$%^&*_+=\/\\|~<>{}\[\]\(\)]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (p.isNotEmpty && p.length > 1 && !cleanedTokens.contains(p)) {
      cleanedTokens.add(p);
    }
  }

  if (cleanedTokens.isEmpty) {
    final fallback = raw
        .replaceAll(
            RegExp(r'[A-Za-z0-9]{2,8}\+[A-Za-z0-9]{2,8}',
                caseSensitive: false),
            '')
        .trim();
    return fallback.isNotEmpty ? fallback : raw;
  }

  return cleanedTokens.join('، ');
}

/// Expandable and structured trip card for driver new trips feed.
class DriverTripCardItem extends StatelessWidget {
  final Trip trip;
  final Function(bool) setNewLoading;
  final VoidCallback onOfferTap;

  const DriverTripCardItem({
    super.key,
    required this.trip,
    required this.setNewLoading,
    required this.onOfferTap,
  });

  String _formatDepartureDateTime(BuildContext context, String rawDatetime) {
    final str = rawDatetime.trim();
    if (str.isEmpty) return S.of(context).notSpecified;
    try {
      final parsed =
          DateTime.parse(str.contains('T') ? str : str.replaceAll(' ', 'T'))
              .toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tripDay = DateTime(parsed.year, parsed.month, parsed.day);
      final diffDays = tripDay.difference(today).inDays;

      final timeStr = DateFormat('hh:mm a',
              Localizations.localeOf(context).languageCode)
          .format(parsed);
      if (diffDays == 0) {
        return S.of(context).timeTodayAt(timeStr);
      } else if (diffDays == 1) {
        return S.of(context).timeTomorrowAt(timeStr);
      } else {
        final dateStr = DateFormat('yyyy/MM/dd',
                Localizations.localeOf(context).languageCode)
            .format(parsed);
        return S.of(context).dateTimeAt(dateStr, timeStr);
      }
    } catch (_) {
      return str;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPrivate = trip.type == TripType.private;
    final creatorName = trip.creator?.name.isNotEmpty == true
        ? trip.creator!.name
        : S.of(context).passenger;
    final formattedDeparture =
        _formatDepartureDateTime(context, trip.tripDatetime);

    final cleanFrom = cleanLocationName(trip.fromLocationName).isNotEmpty
        ? cleanLocationName(trip.fromLocationName)
        : S.of(context).startingLocation;

    final cleanTo = cleanLocationName(trip.toLocationName).isNotEmpty
        ? cleanLocationName(trip.toLocationName)
        : S.of(context).destinationLocation;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: Creator Name & Trip Type Badge ───
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      isPrivate ? Colors.blue.shade50 : Colors.purple.shade50,
                  backgroundImage: appCachedImageProvider(
                      ApiEndpoints.buildImageUrl(trip.creator?.photo)),
                  child: (trip.creator?.photo == null ||
                          ApiEndpoints.buildImageUrl(trip.creator!.photo) ==
                              null)
                      ? Icon(
                          isPrivate
                              ? Icons.person_outline_rounded
                              : Icons.group_outlined,
                          color: isPrivate
                              ? Colors.blue.shade700
                              : Colors.purple.shade700,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    creatorName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Type Badge (خاصة / مشتركة)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color:
                        isPrivate ? Colors.blue.shade50 : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPrivate
                          ? Colors.blue.shade200
                          : Colors.purple.shade200,
                    ),
                  ),
                  child: Text(
                    isPrivate
                        ? '🚗 ${S.of(context).userlayouthomeprivatetrip}'
                        : '👥 ${S.of(context).userlayouthomesharedtrip}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPrivate
                          ? Colors.blue.shade800
                          : Colors.purple.shade800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ─── Departure Date & Time Banner ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.access_time_filled_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).departureDateTime,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDeparture,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─── Route: From → To ───
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle,
                          color: Color(0xFF05A357), size: 10),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cleanFrom,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 2,
                        height: 12,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: Color(0xFFE53E3E), size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cleanTo,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ─── Badges: Seats, Gender ───
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                // Seats
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_seat_rounded,
                          size: 14, color: Colors.teal.shade800),
                      const SizedBox(width: 4),
                      Text(
                        isPrivate
                            ? S.of(context).fullCarSeats
                            : '${trip.numberOfSeats} ${S.of(context).seatsRequestedCount}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                // Gender Preference
                if (trip.genderPreference != GenderPreference.noPreference)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: trip.genderPreference == GenderPreference.female
                          ? Colors.pink.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: trip.genderPreference == GenderPreference.female
                            ? Colors.pink.shade200
                            : Colors.blue.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trip.genderPreference == GenderPreference.female
                              ? Icons.female_rounded
                              : Icons.male_rounded,
                          size: 14,
                          color:
                              trip.genderPreference == GenderPreference.female
                                  ? Colors.pink.shade800
                                  : Colors.blue.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip.genderPreference == GenderPreference.female
                              ? S.of(context).womenOnly
                              : S.of(context).menOnly,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color:
                                trip.genderPreference == GenderPreference.female
                                    ? Colors.pink.shade800
                                    : Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // ─── Actions Bar: Reject, Chat with Badge & Pricing ───
            Builder(
              builder: (context) {
                final currentDriverId = int.tryParse(di.sl<LocalStorage>()
                            .read(key: 'userid')
                            ?.toString() ??
                        di.sl<LocalStorage>()
                            .read(key: 'user_id')
                            ?.toString() ??
                        di.sl<LocalStorage>().read(key: 'id')?.toString() ??
                        '') ??
                    0;
                final targetChatId = ChatChannelHelper.privateTripChatId(
                    tripId: trip.id, driverId: currentDriverId);

                return Row(
                  children: [
                    SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          RejectTripDialouge(
                            setNewLoading: setNewLoading,
                            context,
                            id: trip.id,
                          );
                        },
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: Text(
                          S.of(context).toReject,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    UnreadBadge(
                      chatId: targetChatId,
                      currentUserId: currentDriverId.toString(),
                      child: SizedBox(
                        height: 40,
                        width: 44,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                                color: AppColors.primary.withOpacity(0.4)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            navigateTo(
                              context,
                              TripChatScreenClean(
                                driverName: creatorName,
                                driverPhone: trip.creator?.phone ?? '',
                                tripFrom: cleanFrom,
                                tripTo: cleanTo,
                                tripDatetime: trip.tripDatetime,
                                acceptedPrice: trip.maximumPrice > 0
                                    ? trip.maximumPrice
                                    : trip.minimumPrice,
                                tripId: trip.id,
                                offerId: 0,
                                driverId: currentDriverId,
                                passengerId: trip.creator?.id ?? trip.createdBy,
                                chatId: targetChatId,
                                tripType: isPrivate ? 'private' : 'shared',
                                isInquiry: !isPrivate,
                                isOffersPhase: true,
                                members: [
                                  if (trip.creator != null)
                                    trip.creator!.toMap(),
                                ],
                              ),
                            );
                          },
                          child: const Icon(Icons.chat_outlined,
                              size: 20, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildOfferButton(
                        context,
                        trip,
                        onOfferTap,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferButton(
      BuildContext context, dynamic tripData, VoidCallback openPricingDialog) {
    final trip = tripData is Trip
        ? tripData
        : (tripData is Map<String, dynamic>
            ? Trip.fromMap(tripData)
            : Trip.fromMap({}));
    final cubit = DriverTripsCubit.get(context);
    final offerStatus = cubit.checkOfferStatus(trip);

    if (offerStatus == 'pending') {
      return defaultButton(
        onPressed: () {
          showToast(
            text: S.of(context).offerSentWaitingPassenger,
            state: ToastStates.WARNING,
          );
        },
        text: S.of(context).waitingAcceptance,
        background: Colors.amber.shade800,
        height: 40,
      );
    } else if (offerStatus == 'individual_rejected') {
      return defaultButton(
        onPressed: openPricingDialog,
        text: S.of(context).offerRejectedSendNew,
        background: Colors.deepOrange.shade700,
        height: 40,
      );
    } else if (offerStatus == 'accepted') {
      return defaultButton(
        onPressed: () {
          showToast(
            text: S.of(context).offerAcceptedTransitioning,
            state: ToastStates.SUCESS,
          );
          final isPrivate = trip.type != TripType.shared;
          navigateTo(
            context,
            BlocProvider(
              create: (_) => di.sl<DriverAddPrivateTripCubit>(),
              child: isPrivate
                  ? DriverOngoingPrivateTripScreenClean(
                      trip: trip,
                    )
                  : DriverOngoingSharedTripScreenClean(
                      trip: trip,
                    ),
            ),
          );
        },
        text: S.of(context).offerAcceptedSuccess,
        background: Colors.green.shade800,
        height: 40,
      );
    } else if (offerStatus == 'another_driver_accepted') {
      return defaultButton(
        onPressed: () {
          showToast(
            text: S.of(context).offersClosed,
            state: ToastStates.ERROR,
          );
        },
        text: S.of(context).anotherDriverSelected,
        background: Colors.grey.shade700,
        height: 40,
      );
    }

    return defaultButton(
      onPressed: openPricingDialog,
      text: S.of(context).pricing,
      background: AppColors.primary,
      height: 40,
    );
  }
}
