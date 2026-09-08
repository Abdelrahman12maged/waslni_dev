import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:car_app/features/chat/presentation/widgets/trip_chat_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Clean Architecture Chat Screen connected to Firebase Firestore real-time.
// ─────────────────────────────────────────────────────────────────────────────
class TripChatScreenClean extends StatelessWidget {
  final String driverName;
  final String driverPhone;
  final String? driverPhoto;
  final String tripFrom;
  final String tripTo;
  final String tripDatetime;
  final double acceptedPrice;
  final int tripId;
  final int offerId;
  final int? driverId;
  final int? passengerId;
  final int? creatorId;
  final String? chatId;
  final List<dynamic>? members;
  final String? onPopGoRoute;
  final Map<String, dynamic>? onPopGoExtra;
  final VoidCallback? onPop;
  final String tripType;
  final bool isInquiry;
  final bool isOffersPhase;
  final bool isDm;

  const TripChatScreenClean({
    super.key,
    required this.driverName,
    required this.driverPhone,
    this.driverPhoto,
    required this.tripFrom,
    required this.tripTo,
    required this.tripDatetime,
    required this.acceptedPrice,
    required this.tripId,
    required this.offerId,
    this.driverId,
    this.passengerId,
    this.creatorId,
    this.chatId,
    this.members,
    this.onPopGoRoute,
    this.onPopGoExtra,
    this.onPop,
    this.tripType = 'private',
    this.isInquiry = false,
    this.isOffersPhase = false,
    this.isDm = false,
  });

  String get effectiveChatId {
    int? resolvedDriverId = driverId;
    if (resolvedDriverId == null || resolvedDriverId <= 0) {
      if (members != null) {
        for (final m in members!) {
          if (m is Map && (m['is_driver'] == true || m['role'] == 'driver')) {
            resolvedDriverId = int.tryParse(m['id']?.toString() ?? '');
            break;
          }
        }
      }
      if (resolvedDriverId == null || resolvedDriverId <= 0) {
        final userRole =
            sl<LocalStorage>().read(key: 'user_type')?.toString() ??
                sl<LocalStorage>().read(key: 'usertype')?.toString() ??
                '';
        if (userRole == 'driver') {
          final currentUid = int.tryParse(
              sl<LocalStorage>().read(key: 'userid')?.toString() ??
                  sl<LocalStorage>().read(key: 'user_id')?.toString() ??
                  '');
          if (currentUid != null && currentUid > 0) {
            resolvedDriverId = currentUid;
          }
        }
      }
    }

    return ChatChannelHelper.resolveChatId(
      explicitChatId: chatId,
      tripId: tripId,
      driverId: resolvedDriverId,
      passengerId: passengerId,
      tripType: tripType,
      isInquiry: isInquiry,
      isDm: isDm,
      isOffersPhase: isOffersPhase,
    );
  }

  @override
  Widget build(BuildContext context) {
    final channelId = effectiveChatId;
    return BlocProvider<ChatCubit>(
      create: (_) => sl<ChatCubit>()..listenToMessages(channelId),
      child: TripChatView(
        driverName: driverName,
        driverPhone: driverPhone,
        driverPhoto: driverPhoto,
        tripFrom: tripFrom,
        tripTo: tripTo,
        tripDatetime: tripDatetime,
        acceptedPrice: acceptedPrice,
        tripId: tripId.toString(),
        offerId: offerId.toString(),
        chatId: channelId,
        driverId: driverId,
        passengerId: passengerId,
        creatorId: creatorId,
        members: members,
        onPopGoRoute: onPopGoRoute,
        onPopGoExtra: onPopGoExtra,
        onPop: onPop,
        tripType: tripType,
        isInquiry: isInquiry,
        isOffersPhase: isOffersPhase,
        isDm: isDm,
      ),
    );
  }
}
