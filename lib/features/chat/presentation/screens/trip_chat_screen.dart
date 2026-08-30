import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/features/chat/domain/entities/chat_message_entity.dart';
import 'package:car_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:car_app/features/chat/presentation/cubit/chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:go_router/go_router.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/utils/fcm_notification_service.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/usecases/get_trip_details_usecase.dart';

const Color _navyColor = Color(0xFF1B2570);
const Color _yellowSendColor = Color(0xFFF1C40F);
const Color _lightBubbleBg = Color(0xFFF3F4F6);

/// Clean Architecture Chat Screen connected to Firebase Firestore real-time collection.
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
        final userRole = sl<LocalStorage>().read(key: 'user_type')?.toString() ??
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
      child: _TripChatView(
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

class _TripChatView extends StatefulWidget {
  final String driverName;
  final String driverPhone;
  final String? driverPhoto;
  final String tripFrom;
  final String tripTo;
  final String tripDatetime;
  final double acceptedPrice;
  final String tripId;
  final String offerId;
  final String chatId;
  final int? driverId;
  final int? passengerId;
  final int? creatorId;
  final List<dynamic>? members;
  final String? onPopGoRoute;
  final Map<String, dynamic>? onPopGoExtra;
  final VoidCallback? onPop;
  final String tripType;
  final bool isInquiry;
  final bool isOffersPhase;
  final bool isDm;

  const _TripChatView({
    required this.driverName,
    required this.driverPhone,
    this.driverPhoto,
    required this.tripFrom,
    required this.tripTo,
    required this.tripDatetime,
    required this.acceptedPrice,
    required this.tripId,
    required this.offerId,
    required this.chatId,
    this.driverId,
    this.passengerId,
    this.creatorId,
    this.members,
    this.onPopGoRoute,
    this.onPopGoExtra,
    this.onPop,
    this.tripType = 'private',
    this.isInquiry = false,
    this.isOffersPhase = false,
    this.isDm = false,
  });

  @override
  State<_TripChatView> createState() => _TripChatViewState();
}

class _TripChatViewState extends State<_TripChatView> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  StreamSubscription? _tripStatusSub;
  bool _isTripEnded = false;
  Trip? _loadedTrip;
  String? _resolvedAvatarUrl;

  @override
  void initState() {
    super.initState();
    _listenToTripStatus();
    _loadAvatarAndTripInfo();
  }

  Future<void> _loadAvatarAndTripInfo() async {
    final tripIdInt = int.tryParse(widget.tripId) ?? 0;
    if (tripIdInt <= 0) return;

    try {
      final tripRes = await sl<GetTripDetailsUseCase>().call(tripIdInt);
      tripRes.fold((_) {}, (trip) {
        if (!mounted) return;
        final determined = _determineAvatarUrl(trip);
        setState(() {
          _loadedTrip = trip;
          if (determined != null && determined.trim().isNotEmpty && determined != 'null') {
            _resolvedAvatarUrl = determined;
          }
        });
        log('[TripChat Debug] Loaded trip #${trip.id}, determined avatar: $_resolvedAvatarUrl',
            name: 'TripChat');
      });
    } catch (e) {
      log('[TripChat Debug] Error loading trip details for avatar: $e',
          name: 'TripChat');
    }
  }

  String? _determineAvatarUrl(Trip trip) {
    if (widget.tripType == 'shared') {
      final isDriverCreatedTrip =
          (trip.driver != null && trip.driver?.id == trip.createdBy);

      if (isDriverCreatedTrip) {
        // If driver created shared trip, show first joined passenger's avatar
        for (final p in trip.passengers) {
          if (p.photo != null && p.photo!.trim().isNotEmpty && p.photo != 'null') {
            return ApiEndpoints.buildImageUrl(p.photo);
          }
        }
      } else {
        // If passenger created shared trip, show creator's avatar
        if (trip.creator?.photo != null &&
            trip.creator!.photo!.trim().isNotEmpty &&
            trip.creator!.photo != 'null') {
          return ApiEndpoints.buildImageUrl(trip.creator!.photo);
        }
      }
      // Fallback options
      if (trip.creator?.photo != null &&
          trip.creator!.photo!.trim().isNotEmpty &&
          trip.creator!.photo != 'null') {
        return ApiEndpoints.buildImageUrl(trip.creator!.photo);
      }
      if (trip.driver?.photo != null &&
          trip.driver!.photo!.trim().isNotEmpty &&
          trip.driver!.photo != 'null') {
        return ApiEndpoints.buildImageUrl(trip.driver!.photo);
      }
    } else {
      // Private Trip
      if (_isDriver) {
        // Current user is driver: show passenger / creator photo
        if (trip.creator?.photo != null &&
            trip.creator!.photo!.trim().isNotEmpty &&
            trip.creator!.photo != 'null') {
          return ApiEndpoints.buildImageUrl(trip.creator!.photo);
        }
        for (final p in trip.passengers) {
          if (p.photo != null && p.photo!.trim().isNotEmpty && p.photo != 'null') {
            return ApiEndpoints.buildImageUrl(p.photo);
          }
        }
      } else {
        // Current user is passenger: show driver photo
        if (trip.driver?.photo != null &&
            trip.driver!.photo!.trim().isNotEmpty &&
            trip.driver!.photo != 'null') {
          return ApiEndpoints.buildImageUrl(trip.driver!.photo);
        }
        for (final off in trip.offers) {
          if (off.driver?.photo != null &&
              off.driver!.photo!.trim().isNotEmpty &&
              off.driver!.photo != 'null') {
            final oDriverId = off.driverId > 0 ? off.driverId : off.driver?.id;
            final dName = off.driver?.name.trim().toLowerCase() ?? '';
            final targetName = widget.driverName.trim().toLowerCase();
            final nameMatches = dName.isNotEmpty &&
                targetName.isNotEmpty &&
                (dName == targetName ||
                    dName.contains(targetName) ||
                    targetName.contains(dName));

            if (widget.driverId == null ||
                widget.driverId == 0 ||
                oDriverId == widget.driverId ||
                nameMatches ||
                off.isAccepted) {
              return ApiEndpoints.buildImageUrl(off.driver!.photo);
            }
          }
        }
        // If still not matched, check if any offer has a valid driver photo
        final firstOfferWithPhoto = trip.offers
            .where((o) =>
                o.driver?.photo != null &&
                o.driver!.photo!.trim().isNotEmpty &&
                o.driver!.photo != 'null')
            .firstOrNull;
        if (firstOfferWithPhoto != null) {
          return ApiEndpoints.buildImageUrl(firstOfferWithPhoto.driver!.photo);
        }
      }
    }
    return null;
  }

  String? get _avatarUrl {
    // 1. If widget.driverPhoto is provided and valid, keep it permanently
    if (widget.driverPhoto != null &&
        widget.driverPhoto!.trim().isNotEmpty &&
        widget.driverPhoto != 'null' &&
        widget.driverPhoto != 'undefined') {
      final built = ApiEndpoints.buildImageUrl(widget.driverPhoto);
      if (built != null && built.trim().isNotEmpty) return built;
    }
    // 2. If resolved from API reload
    if (_resolvedAvatarUrl != null &&
        _resolvedAvatarUrl!.trim().isNotEmpty &&
        _resolvedAvatarUrl != 'null') {
      return _resolvedAvatarUrl;
    }
    // 3. Fallback from members list
    if (widget.members != null) {
      for (final m in widget.members!) {
        if (m is Map) {
          final isD = m['is_driver'] == true || m['role'] == 'driver';
          if ((_isDriver && !isD) || (!_isDriver && isD)) {
            final p = m['photo']?.toString() ??
                m['image']?.toString() ??
                m['avatar']?.toString() ??
                m['profile_picture']?.toString() ??
                m['profile_picture_url']?.toString();
            if (p != null && p.trim().isNotEmpty && p != 'null' && p != 'undefined') {
              final built = ApiEndpoints.buildImageUrl(p);
              if (built != null && built.trim().isNotEmpty) return built;
            }
          }
        }
      }
    }
    return null;
  }

  void _listenToTripStatus() {
    _tripStatusSub = FirebaseFirestore.instance
        .collection('trip_locations')
        .doc(widget.tripId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data();
        final status =
            data?['on_going_status']?.toString() ?? data?['status']?.toString();
        if (status == 'end' ||
            status == 'completed' ||
            status == 'canceled' ||
            status == 'closed') {
          if (mounted && !_isTripEnded) {
            setState(() {
              _isTripEnded = true;
            });
            showToast(
              text: S.of(context).chatClosedTripEnded,
              state: ToastStates.WARNING,
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _tripStatusSub?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onPop != null) {
      widget.onPop!();
      return;
    }
    if (widget.onPopGoRoute != null && widget.onPopGoRoute!.isNotEmpty) {
      context.go(widget.onPopGoRoute!, extra: widget.onPopGoExtra);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    final userType = sl<LocalStorage>().read(key: 'user_type')?.toString() ??
        sl<LocalStorage>().read(key: 'usertype')?.toString() ??
        'user';
    if (userType == 'driver') {
      context.go(AppRoutes.driverHome);
    } else {
      context.go(AppRoutes.passengerHome);
    }
  }

  void _sendMessage() {
    if (_isTripEnded) {
      showToast(text: S.of(context).chatClosedToast, state: ToastStates.ERROR);
      return;
    }
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    final cubit = context.read<ChatCubit>();
    cubit.sendMessage(
      tripId: widget.chatId,
      text: text,
    );
    _notifyChatRecipients(text, cubit.currentUserName);
  }

  Future<void> _notifyChatRecipients(
      String messageText, String senderName) async {
    try {
      final tripIdInt = int.tryParse(widget.tripId) ?? 0;
      if (tripIdInt <= 0) return;

      final fcmService = sl<FcmNotificationService>();
      final currentUid = sl<LocalStorage>().read(key: 'userid')?.toString() ??
          sl<LocalStorage>().read(key: 'user_id')?.toString() ??
          '';

      log('[TripChat FCM Debug] Preparing push notifications for trip #$tripIdInt from sender "$senderName" (uid: $currentUid)',
          name: 'TripChat');

      final Map<String, int> targetRecipients = {};

      // 1. Check passed members list
      if (widget.members != null && widget.members!.isNotEmpty) {
        for (final member in widget.members!) {
          if (member is Map) {
            final mId =
                member['id']?.toString() ?? member['user_id']?.toString() ?? '';
            final fcmToken = member['fcm_token']?.toString() ??
                member['device_token']?.toString() ??
                member['token']?.toString();

            if (mId != currentUid && fcmToken != null && fcmToken.isNotEmpty) {
              targetRecipients[fcmToken] = int.tryParse(mId) ?? 0;
              log('[TripChat FCM Debug] Added token from members list: $fcmToken (memberId: $mId)',
                  name: 'TripChat');
            }
          }
        }
      }

      // 2. Fetch live trip details to ensure all participants receive push notifications
      try {
        final tripRes = await sl<GetTripDetailsUseCase>().call(tripIdInt);
        tripRes.fold((failure) {
          log('[TripChat FCM Debug] Could not fetch live trip details: ${failure.message}',
              name: 'TripChat');
        }, (trip) {
          // Driver token
          final dId = trip.driver?.id ?? trip.driverId;
          final dToken = trip.driver?.fcmToken;
          if (dId != null &&
              dId.toString() != currentUid &&
              dToken != null &&
              dToken.isNotEmpty) {
            targetRecipients[dToken] = dId;
            log('[TripChat FCM Debug] Added trip.driver token: $dToken (driverId: $dId)',
                name: 'TripChat');
          }

          // Creator token
          final cId = trip.creator?.id ?? trip.createdBy;
          final cToken = trip.creator?.fcmToken;
          if (cId.toString() != currentUid &&
              cToken != null &&
              cToken.isNotEmpty) {
            targetRecipients[cToken] = cId;
            log('[TripChat FCM Debug] Added trip.creator token: $cToken (creatorId: $cId)',
                name: 'TripChat');
          }

          // All passengers tokens (for shared trips)
          for (final p in trip.passengers) {
            final pId = p.id;
            final pToken = p.fcmToken;
            if (pId.toString() != currentUid &&
                pToken != null &&
                pToken.isNotEmpty) {
              targetRecipients[pToken] = pId;
              log('[TripChat FCM Debug] Added trip passenger token: $pToken (passengerId: $pId)',
                  name: 'TripChat');
            }
          }

          // Offers driver tokens (both accepted and targeted inquiry drivers)
          for (final off in trip.offers) {
            final offDriverId =
                off.driverId > 0 ? off.driverId : (off.driver?.id ?? 0);
            final offToken = off.driver?.fcmToken;
            final isTargetedDriver = widget.driverId != null &&
                (off.driverId == widget.driverId ||
                    off.driver?.id == widget.driverId);
            if ((off.isAccepted ||
                    isTargetedDriver ||
                    widget.isOffersPhase ||
                    widget.isInquiry) &&
                offDriverId.toString() != currentUid &&
                offToken != null &&
                offToken.isNotEmpty) {
              targetRecipients[offToken] = offDriverId;
              log('[TripChat FCM Debug] Added offer driver token: $offToken (driverId: $offDriverId)',
                  name: 'TripChat');
            }
          }
        });
      } catch (e) {
        log('[TripChat FCM Debug] Exception in live trip details fetch: $e',
            name: 'TripChat');
      }

      // 3. Fallback: Query Firestore users/{userId} if targetRecipients is still empty
      if (targetRecipients.isEmpty) {
        final List<int> candidateUserIds = [
          if (widget.passengerId != null && widget.passengerId! > 0)
            widget.passengerId!,
          if (widget.driverId != null && widget.driverId! > 0) widget.driverId!,
        ];
        for (final uId in candidateUserIds) {
          if (uId.toString() != currentUid) {
            try {
              final doc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uId.toString())
                  .get();
              final t = doc.data()?['fcm_token']?.toString() ??
                  doc.data()?['device_token']?.toString();
              if (t != null && t.isNotEmpty) {
                targetRecipients[t] = uId;
                log('[TripChat FCM Debug] Fetched FCM token from Firestore users/$uId: $t',
                    name: 'TripChat');
              }
            } catch (e) {
              log('[TripChat FCM Debug] Could not fetch Firestore user doc: $e',
                  name: 'TripChat');
            }
          }
        }
      }

      if (targetRecipients.isEmpty) {
        log('[TripChat FCM Debug] ⚠️ No target FCM tokens found for trip #$tripIdInt! Notification will not be sent.',
            name: 'TripChat');
        return;
      }

      log('[TripChat FCM Debug] 🚀 Dispatching FCM notifications to ${targetRecipients.length} recipients: $targetRecipients',
          name: 'TripChat');

      // 4. Dispatch FCM push notification to all recipients
      for (final entry in targetRecipients.entries) {
        await fcmService.notifyChatMessage(
          targetFcmToken: entry.key,
          targetUserId: entry.value > 0 ? entry.value : null,
          senderName: senderName,
          messageText: messageText,
          tripId: tripIdInt,
          chatId: widget.chatId,           // exact Firestore channel id
          tripType: widget.tripType,       // 'private' | 'shared'
          isInquiry: widget.isInquiry,     // pre-join inquiry
          isOffersPhase: widget.isOffersPhase, // bidding phase
          isDm: widget.isDm,               // private DM inside shared trip
          passengerId: widget.passengerId,
          driverId: widget.driverId,
        );
      }
    } catch (e, stack) {
      log('[TripChat FCM Debug] ❌ Error in _notifyChatRecipients: $e\n$stack',
          name: 'TripChat');
    }
  }

  bool get _isDriver {
    final type = sl<LocalStorage>().read(key: 'user_type')?.toString() ??
        sl<LocalStorage>().read(key: 'usertype')?.toString() ??
        'user';
    return type == 'driver';
  }

  bool get _isSharedTrip => widget.tripType == 'shared';

  String get _currentUserId =>
      sl<LocalStorage>().read(key: 'userid')?.toString() ??
      sl<LocalStorage>().read(key: 'user_id')?.toString() ??
      '';

  List<dynamic> get _passengerMembers {
    final members = widget.members ?? [];
    return members.where((m) {
      if (m is Map) {
        final isD = m['is_driver'] == true || m['role'] == 'driver';
        return !isD;
      }
      return true;
    }).toList();
  }

  bool get _isJoinedPassenger {
    if (_isDriver) return false;
    final members = widget.members ?? [];
    return members.any((m) {
      if (m is Map) {
        final mId = m['id']?.toString() ?? m['user_id']?.toString() ?? '';
        final isD = m['is_driver'] == true || m['role'] == 'driver';
        return !isD && mId.isNotEmpty && mId == _currentUserId;
      }
      return false;
    });
  }

  bool get _isCreator {
    if (widget.isOffersPhase || widget.isInquiry) return false;
    if (!_isSharedTrip) return !_isDriver;
    if (widget.creatorId != null &&
        widget.creatorId.toString() == _currentUserId) {
      return true;
    }
    if (_loadedTrip?.createdBy.toString() == _currentUserId ||
        _loadedTrip?.creator?.id.toString() == _currentUserId) {
      return true;
    }
    final members = widget.members ?? [];
    for (final m in members) {
      if (m is Map) {
        final mId = m['id']?.toString() ?? m['user_id']?.toString() ?? '';
        if (mId.isNotEmpty && mId == _currentUserId) {
          if (m['is_creator'] == true ||
              m['is_owner'] == true ||
              m['is_passenger_creator'] == true) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool get _canShowActions {
    if (widget.isOffersPhase || widget.isInquiry) return false;
    if (_isDriver) return true;
    if (!_isSharedTrip) return true;
    return false;
  }

  void _showActionsSheet() {
    if (!_canShowActions) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _navyColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: _navyColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    S.of(context).tripOptions,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── 1. Private Trip Options ──
              if (!_isSharedTrip) ...[
                if (!_isDriver) ...[
                  // Passenger Private: Change Driver
                  _buildActionTile(
                    icon: Icons.person_search_rounded,
                    iconColor: AppColors.primary,
                    bgColor: AppColors.primary.withOpacity(0.1),
                    title: S.of(context).changeDriverAndSearchOffers,
                    subtitle: S.of(context).changeDriverAndSearchOffersDesc,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      _confirmAction(
                        title: S.of(context).changeDriverConfirmTitle,
                        message: S.of(context).changeDriverConfirmMessage,
                        confirmText: S.of(context).yesSearchOffers,
                        confirmColor: AppColors.primary,
                        onConfirmed: () async {
                          final tId = int.tryParse(widget.tripId) ?? 0;
                          final offId = int.tryParse(widget.offerId);
                          final ok = await sl<PassengerTripsCubit>()
                              .cancelAcceptedOfferAndReopen(
                            tripId: tId,
                            offerId: offId,
                          );
                          if (ok && mounted) {
                            showToast(
                              text:
                                  S.of(context).driverCancelledReceivingOffers,
                              state: ToastStates.SUCESS,
                            );
                            Navigator.of(context, rootNavigator: true)
                                .popUntil((route) => route.isFirst);
                            context.go(
                              AppRoutes.passengerPrivateOffers,
                              extra: {'trip_id': tId, 'id': tId},
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  // Passenger Private: Cancel Trip
                  _buildActionTile(
                    icon: Icons.cancel_outlined,
                    iconColor: Colors.red[700]!,
                    bgColor: Colors.red.withOpacity(0.1),
                    title: S.of(context).cancelTripPermanently,
                    subtitle: S.of(context).cancelTripPermanentlyDesc,
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      _confirmAction(
                        title: S.of(context).cancelTripPermanently,
                        message: S.of(context).cancelTripConfirmMessage,
                        confirmText: S.of(context).confirmCancelTrip,
                        confirmColor: Colors.red[700]!,
                        hasReasonField: true,
                        onConfirmedWithReason: (reason) async {
                          final tId = int.tryParse(widget.tripId) ?? 0;
                          final ok = await sl<PassengerTripsCubit>()
                              .cancelEntireTrip(tId, reason: reason);
                          if (ok && mounted) {
                            showToast(
                              text: S.of(context).tripEndedSuccessfully,
                              state: ToastStates.SUCESS,
                            );
                            Navigator.of(context, rootNavigator: true)
                                .popUntil((route) => route.isFirst);
                            context.go(AppRoutes.passengerHome);
                          }
                        },
                      );
                    },
                  ),
                ] else ...[
                  // Driver Private: Cancel acceptance
                  _buildActionTile(
                    icon: Icons.cancel_outlined,
                    iconColor: Colors.red[700]!,
                    bgColor: Colors.red.withOpacity(0.1),
                    title: S.of(context).cancelTripAcceptance,
                    subtitle: S.of(context).cancelTripAcceptanceDesc,
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      _confirmAction(
                        title: S.of(context).cancelTripAcceptance,
                        message: S.of(context).cancelTripAcceptanceConfirm,
                        confirmText: S.of(context).cancelAcceptance,
                        confirmColor: Colors.red[700]!,
                        hasReasonField: true,
                        onConfirmedWithReason: (reason) async {
                          final tId = int.tryParse(widget.tripId) ?? 0;
                          final ok =
                              await sl<DriverTripsCubit>().driverCancelTrip(
                            tripId: tId,
                            isSharedCreator: false,
                            reason: reason,
                          );
                          if (ok && mounted) {
                            showToast(
                              text: S.of(context).tripEndedSuccessfully,
                              state: ToastStates.SUCESS,
                            );
                            Navigator.of(context, rootNavigator: true)
                                .popUntil((route) => route.isFirst);
                            context.go(AppRoutes.driverHome);
                          }
                        },
                      );
                    },
                  ),
                ],
              ],

              // ── 2. Shared Trip Options ──
              if (_isSharedTrip) ...[
                if (_isDriver) ...[
                  // Driver Shared: Cancel shared trip for all
                  _buildActionTile(
                    icon: Icons.cancel_outlined,
                    iconColor: Colors.red[700]!,
                    bgColor: Colors.red.withOpacity(0.1),
                    title: S.of(context).cancelSharedTripCompletely,
                    subtitle: S.of(context).cancelSharedTripEjectAll,
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      _confirmAction(
                        title: S.of(context).cancelSharedTripCompletely,
                        message: S
                            .of(context)
                            .cancelSharedTripEjectAllConfirmMessage,
                        confirmText: S.of(context).cancelTripEntirely,
                        confirmColor: Colors.red[700]!,
                        hasReasonField: true,
                        onConfirmedWithReason: (reason) async {
                          final tId = int.tryParse(widget.tripId) ?? 0;
                          final ok =
                              await sl<DriverTripsCubit>().driverCancelTrip(
                            tripId: tId,
                            isSharedCreator: true,
                            reason: reason,
                          );
                          if (ok && mounted) {
                            showToast(
                              text: S.of(context).sharedTripEndedSuccessfully,
                              state: ToastStates.SUCESS,
                            );
                            Navigator.of(context, rootNavigator: true)
                                .popUntil((route) => route.isFirst);
                            context.go(AppRoutes.driverHome);
                          }
                        },
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
                color:
                    isDestructive ? Colors.red.shade100 : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDestructive
                            ? Colors.red[800]
                            : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded,
                  color: Colors.grey[400], size: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmAction({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    Future<void> Function()? onConfirmed,
    Future<void> Function(String? reason)? onConfirmedWithReason,
    bool hasReasonField = false,
  }) {
    final reasonCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: confirmColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.help_outline_rounded,
                          color: confirmColor, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    if (hasReasonField) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: reasonCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: S.of(context).cancellationReasonOptional,
                          hintStyle: GoogleFonts.cairo(
                              color: Colors.grey[400], fontSize: 13),
                          contentPadding: const EdgeInsets.all(12),
                          filled: true,
                          fillColor: Colors.grey[50],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: confirmColor, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(dialogCtx),
                            child: Text(
                              S.of(context).backOrDismiss,
                              style: GoogleFonts.cairo(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: confirmColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    setDialogState(() => isSubmitting = true);
                                    Navigator.pop(dialogCtx);
                                    if (onConfirmedWithReason != null) {
                                      await onConfirmedWithReason(
                                          reasonCtrl.text.trim());
                                    } else if (onConfirmed != null) {
                                      await onConfirmed();
                                    }
                                  },
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    confirmText,
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
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
          },
        );
      },
    );
  }

  void _showMembersBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        final realMembers = widget.members ?? [];
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).tripMembers,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _navyColor,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _navyColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${realMembers.isEmpty ? 1 : realMembers.length} ${S.of(context).membersCount}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _navyColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (realMembers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFE0E7FF),
                        child: Icon(Icons.person, color: _navyColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.driverName.isNotEmpty
                            ? widget.driverName
                            : S.of(context).tripMember,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...realMembers.map((member) {
                  final String name = member is Map
                      ? (member['name'] ??
                              member['username'] ??
                              S.of(context).tripMember)
                          .toString()
                      : member.toString();
                  final bool isCreator = member is Map &&
                      (member['is_creator'] == true ||
                          member['is_owner'] == true ||
                          member['is_passenger_creator'] == true);
                  final bool isDriver = member is Map &&
                      (member['is_driver'] == true ||
                          member['role'] == 'driver');

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isCreator
                              ? const Color(0xFFFEF3C7)
                              : isDriver
                                  ? const Color(0xFFE0E7FF)
                                  : const Color(0xFFF3F4F6),
                          child: Icon(
                            isCreator
                                ? Icons.workspace_premium_rounded
                                : isDriver
                                    ? Icons.directions_car_rounded
                                    : Icons.person_rounded,
                            color: isCreator
                                ? const Color(0xFFD97706)
                                : isDriver
                                    ? _navyColor
                                    : Colors.grey[700],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[850],
                            ),
                          ),
                        ),
                        if (isCreator)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.workspace_premium_rounded,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  S.of(context).tripOwner,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (!isCreator && isDriver)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _navyColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              S.of(context).driver,
                              style: GoogleFonts.cairo(
                                color: _navyColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  List<String> get _quickResponses => [
        S.current.chatQuickOnMyWay,
        S.current.chatQuickArrivedPickup,
        S.current.chatQuickTwoMinutes,
        S.current.chatQuickSameMapLocation,
        S.current.chatQuickTraffic,
        S.current.chatQuickThanks,
      ];

  void _sendPreset(String text) {
    if (_isTripEnded) {
      showToast(text: S.of(context).chatClosedToast, state: ToastStates.ERROR);
      return;
    }
    final cubit = context.read<ChatCubit>();
    cubit.sendMessage(
      tripId: widget.chatId,
      text: text,
    );
    _notifyChatRecipients(text, cubit.currentUserName);
  }

  Widget _buildAppBarAvatar(String dName) {
    final url = _avatarUrl;
    final hasValidUrl = url != null &&
        url.trim().isNotEmpty &&
        url != 'null' &&
        (url.startsWith('http://') || url.startsWith('https://'));

    final letter = dName.trim().isNotEmpty
        ? dName.trim().characters.first.toUpperCase()
        : (_isDriver ? 'P' : 'D');

    final fallbackWidget = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.18),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
    );

    if (!hasValidUrl) {
      return fallbackWidget;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url!.trim(),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          placeholder: (_, __) => fallbackWidget,
          errorWidget: (_, __, ___) => fallbackWidget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dName = widget.driverName.isNotEmpty
        ? widget.driverName
        : S.of(context).logindialogdriver;
    final dTime = widget.tripDatetime.isNotEmpty
        ? widget.tripDatetime
        : '8:50 am - 22/7/2023';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 12,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              color: _navyColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      onPressed: _handleBack,
                    ),
                    const SizedBox(width: 4),
                    _buildAppBarAvatar(dName),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dName,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  color: Colors.white70, size: 13),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  dTime,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_canShowActions ||
                        (_isSharedTrip &&
                            !widget.isInquiry &&
                            !widget.isOffersPhase &&
                            (_isJoinedPassenger || _isDriver || _isCreator)))
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded,
                            color: Colors.white),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        onSelected: (val) {
                          if (val == 'actions') {
                            _showActionsSheet();
                          } else if (val == 'members') {
                            _showMembersBottomSheet();
                          }
                        },
                        itemBuilder: (ctx) => [
                          if (_canShowActions)
                            PopupMenuItem(
                              value: 'actions',
                              child: Row(
                                children: [
                                  const Icon(Icons.tune_rounded,
                                      color: _navyColor, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    S.of(context).tripOptions,
                                    style: GoogleFonts.cairo(
                                      color: _navyColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_isSharedTrip &&
                              !widget.isInquiry &&
                              !widget.isOffersPhase &&
                              (_isJoinedPassenger || _isDriver || _isCreator))
                            PopupMenuItem(
                              value: 'members',
                              child: Row(
                                children: [
                                  const Icon(Icons.people_alt_outlined,
                                      color: _navyColor, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    S.of(context).tripMembers,
                                    style: GoogleFonts.cairo(
                                      color: _navyColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            // ── Top Mini Trip Info Card ──
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _navyColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_car_rounded,
                        color: _navyColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.tripFrom.isNotEmpty ? widget.tripFrom : S.of(context).chatFrom} ⬅️ ${widget.tripTo.isNotEmpty ? widget.tripTo : S.of(context).chatTo}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.acceptedPrice > 0)
                          Text(
                            '${S.of(context).acceptedPriceLabel} ${widget.acceptedPrice.toStringAsFixed(1)} ${S.of(context).jod}',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF059669),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _handleBack,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _navyColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            S.of(context).mapLabel,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Messages List ──
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: _navyColor),
                    );
                  } else if (state is ChatLoaded) {
                    final messages = state.messages;
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          S.of(context).today,
                          style: GoogleFonts.cairo(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    final isGroup =
                        (widget.members != null && widget.members!.length > 2);

                    return ListView.builder(
                      controller: _scrollCtrl,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return _MessageBubble(
                          message: msg,
                          isGroup: isGroup,
                          driverName: widget.driverName,
                        );
                      },
                    );
                  } else if (state is ChatError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: GoogleFonts.cairo(color: Colors.red),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // ── Quick Driver Presets Bar (Driver Only) ──
            if (_isDriver)
              Container(
                height: 38,
                margin: const EdgeInsets.only(bottom: 6),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _quickResponses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final preset = _quickResponses[index];
                    return InkWell(
                      onTap: () => _sendPreset(preset),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Center(
                          child: Text(
                            preset,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // ── Bottom Message Input Bar ──
            SafeArea(
              top: false,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Send Button
                    InkWell(
                      onTap: _sendMessage,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: _yellowSendColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: _navyColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Input Field Container
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sentiment_satisfied_alt_rounded,
                              color: Colors.grey[400],
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _msgCtrl,
                                style: GoogleFonts.cairo(fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: S.of(context).writeMessageHint,
                                  hintStyle: GoogleFonts.cairo(
                                    color: Colors.grey[400],
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isGroup;
  final String driverName;

  const _MessageBubble({
    required this.message,
    this.isGroup = false,
    this.driverName = '',
  });

  Color _getSenderColor(String name) {
    final colors = [
      Colors.blue.shade700,
      Colors.purple.shade700,
      Colors.teal.shade700,
      Colors.orange.shade800,
      Colors.indigo.shade700,
      Colors.deepOrange.shade700,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);

    // Identify if sender is a driver strictly from message metadata
    final bool isDriver = message.isDriver || message.senderType == 'driver';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.80,
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(
            color: isMe
                ? (isDriver ? const Color(0xFF1E3A8A) : _navyColor)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            border: isMe
                ? null
                : Border.all(
                    color: isDriver
                        ? const Color(0xFFF59E0B).withOpacity(0.5)
                        : const Color(0xFFE2E8F0),
                    width: isDriver ? 1.5 : 1.0,
                  ),
            boxShadow: [
              BoxShadow(
                color: isDriver && !isMe
                    ? const Color(0xFFF59E0B).withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // ── Sender Name & Driver Badge Header ──
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isDriver) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFF59E0B),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.drive_eta_rounded,
                              size: 11,
                              color: Color(0xFFB45309),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              S.of(context).tripCaptain,
                              style: GoogleFonts.cairo(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      isMe
                          ? (isDriver
                              ? S.of(context).youCaptain
                              : S.of(context).youLabel)
                          : (message.senderName.isNotEmpty
                              ? message.senderName
                              : (isDriver
                                  ? S.of(context).driver
                                  : S.of(context).passenger)),
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isMe
                            ? (isDriver
                                ? const Color(0xFFFCD34D)
                                : Colors.white70)
                            : (isDriver
                                ? const Color(0xFFB45309)
                                : _getSenderColor(message.senderName)),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Message Text ──
              Text(
                message.text,
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  color: isMe ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 3),

              // ── Time & Status ──
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.done_all_rounded,
                      size: 12,
                      color: Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
