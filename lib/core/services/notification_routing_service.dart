import 'dart:developer';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/usecases/get_driver_trips_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_passenger_trips_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_trip_details_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_trips_near_me_usecase.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Centralized service for deep-linking / routing when a notification is tapped.
/// Handles background FCM taps, cold-start taps, foreground banner taps,
/// and in-app notification screen taps.
class NotificationRoutingService {
  final GoRouter Function() _getRouter;
  final LocalStorage _storage;
  final GetTripDetailsUseCase? _getTripDetails;
  final GetPassengerTripsUseCase? _getPassengerTrips;
  final GetDriverTripsUseCase? _getDriverTrips;
  final GetTripsNearMeUseCase? _getTripsNearMe;

  NotificationRoutingService({
    required GoRouter Function() getRouter,
    required LocalStorage storage,
    GetTripDetailsUseCase? getTripDetails,
    GetPassengerTripsUseCase? getPassengerTrips,
    GetDriverTripsUseCase? getDriverTrips,
    GetTripsNearMeUseCase? getTripsNearMe,
  })  : _getRouter = getRouter,
        _storage = storage,
        _getTripDetails = getTripDetails,
        _getPassengerTrips = getPassengerTrips,
        _getDriverTrips = getDriverTrips,
        _getTripsNearMe = getTripsNearMe;

  Future<void> handleNotificationTap(Map<String, dynamic> data) async {
    final router = _getRouter();

    final userType = _storage.read(key: 'usertype')?.toString().toLowerCase() ??
        _storage.read(key: 'user_type')?.toString().toLowerCase() ??
        '';
    final userToken = _storage.read(key: 'usertoken') as String?;

    if (userToken == null || userType.isEmpty) {
      if (kDebugMode) {
        log('User not authenticated, skipping notification deep-link.',
            name: 'NotificationRouting');
      }
      return;
    }

    final rawType =
        data['type'] ?? data['event'] ?? data['action'] ?? data['screen'] ?? '';
    final type = rawType.toString().toLowerCase().trim();

    final rawTripId = data['trip_id'] ??
        data['tripId'] ??
        data['id'] ??
        (data['trip'] is Map ? data['trip']['id'] : null);
    final tripId = int.tryParse(rawTripId?.toString() ?? '');

    final rawTripType = data['trip_type'] ?? data['type'] ?? '';
    final tripType = rawTripType.toString().toLowerCase();

    // Check if this is a chat message notification (case-insensitive in EN and AR)
    final String title = data['title']?.toString().trim() ?? '';
    final String body =
        (data['body'] ?? data['message'] ?? data['description'])?.toString().trim() ??
            '';
    final String titleLower = title.toLowerCase();
    final String bodyLower = body.toLowerCase();

    final bool isChatNotification = type == 'chat' ||
        type == 'message' ||
        type == 'new_message' ||
        type == 'trip_chat' ||
        titleLower.contains('رسالة') ||
        bodyLower.contains('رسالة') ||
        titleLower.contains('message') ||
        bodyLower.contains('message') ||
        titleLower.contains('chat') ||
        bodyLower.contains('chat');

    if (kDebugMode) {
      log('Routing notification — type: "$type", isChat: $isChatNotification, tripId: $tripId, tripType: "$tripType", userType: "$userType", title: "$title"',
          name: 'NotificationRouting');
    }

    // ── 1. If notification refers to a specific trip ID, validate with backend ────
    if (tripId != null && tripId > 0) {
      Trip? liveTrip;
      if (_getTripDetails != null) {
        try {
          final tripResult = await _getTripDetails!(tripId);
          tripResult.fold(
            (failure) {
              log('Failed to fetch trip details for notification tap: ${failure.message}',
                  name: 'NotificationRouting');
            },
            (t) {
              liveTrip = t;
            },
          );
        } catch (e) {
          log('Error fetching trip details for notification: $e',
              name: 'NotificationRouting');
        }
      }

      // ── Chat Notification with known Trip ID: Route directly to Chat screen ──
      if (isChatNotification && liveTrip != null) {
        _routeToChatForLiveTrip(
          trip: liveTrip!,
          userType: userType,
          rawData: data,
        );
        return;
      }

      // If backend call failed or trip is not found on server
      if (liveTrip == null) {
        showToast(
          text: S.current.tripUnavailableOrDeleted,
          state: ToastStates.WARNING,
        );
        return; // NEVER navigate blindly to an offer/trip screen when trip is missing!
      }

      // Check trip status
      final status = liveTrip!.status;
      if (status == TripStatus.canceled) {
        showToast(
          text: S.current.tripCancelledAlready,
          state: ToastStates.WARNING,
        );
        return; // Do NOT enter offers screen
      }

      if (status == TripStatus.completed || status == TripStatus.closed) {
        if (type == 'trip_completed' ||
            type == 'trip_ended' ||
            type == 'rating' ||
            type == 'rate') {
          if (userType == 'driver') {
            router.push(AppRoutes.driverRatings);
          } else {
            router.push(
              AppRoutes.tripRating,
              extra: {
                'trip_id': tripId,
                'target_user_id':
                    liveTrip!.driverId ?? liveTrip!.driver?.id ?? 0,
                'target_user_name':
                    liveTrip!.driver?.name ?? S.current.driverRole,
                'is_driver': false,
              },
            );
          }
        } else {
          showToast(
            text: S.current.tripCompletedAndFinished,
            state: ToastStates.WARNING,
          );
        }
        return; // Do NOT enter offers screen
      }

      // Active / accepted trip
      if (status == TripStatus.accepted) {
        if (userType == 'driver') {
          if (liveTrip!.type == TripType.shared) {
            router.push(AppRoutes.driverOngoingSharedTrip,
                extra: {'trip': liveTrip, 'trip_id': liveTrip!.id});
          } else {
            router.push(AppRoutes.driverOngoingPrivateTrip,
                extra: {'trip': liveTrip, 'trip_id': liveTrip!.id});
          }
        } else {
          if (liveTrip!.type == TripType.shared) {
            router.push(AppRoutes.passengerOngoingSharedTrip,
                extra: {'trip': liveTrip, 'trip_id': liveTrip!.id});
          } else {
            router.push(AppRoutes.passengerCurrentPrivateTrip,
                extra: {'trip': liveTrip, 'trip_id': liveTrip!.id});
          }
        }
        return;
      }

      // Open trip (offers phase / new trip request)
      if (status == TripStatus.open) {
        if (userType == 'driver') {
          router.push(AppRoutes.availableTrips,
              extra: {'trip': liveTrip, 'trip_id': liveTrip!.id});
        } else {
          if (liveTrip!.type == TripType.shared) {
            router.push(AppRoutes.passengerSharedCurrentTrip,
                extra: {'trip': liveTrip, 'trip_id': liveTrip!.id, ...data});
          } else {
            router.push(AppRoutes.passengerPrivateOffers,
                extra: {'trip': liveTrip, 'trip_id': liveTrip!.id, ...data});
          }
        }
        return;
      }

      // Suspended trip
      if (status == TripStatus.suspended) {
        if (userType == 'driver') {
          router.push(AppRoutes.driverTrips,
              extra: {'trip': liveTrip, 'trip_id': liveTrip!.id});
        } else {
          router.push(AppRoutes.passengerTrips,
              extra: {'trip': liveTrip, 'trip_id': liveTrip!.id});
        }
        return;
      }

      return;
    }

    // ── 2. Trip ID is null / missing ───────────────────────────────────
    if (isChatNotification) {
      final String chatIdPayload =
          data['chat_id']?.toString() ?? data['chatId']?.toString() ?? '';

      // A. Try extracting tripId from the chat_id payload if present
      if (chatIdPayload.isNotEmpty) {
        final tripIdFromChat = _extractTripIdFromChatId(chatIdPayload);
        if (tripIdFromChat != null && tripIdFromChat > 0 && _getTripDetails != null) {
          try {
            final res = await _getTripDetails!(tripIdFromChat);
            Trip? fetchedTrip;
            res.fold((_) {}, (t) => fetchedTrip = t);
            if (fetchedTrip != null) {
              if (kDebugMode) {
                log('Recovered trip #${fetchedTrip!.id} from chat_id "$chatIdPayload"',
                    name: 'NotificationRouting');
              }
              _routeToChatForLiveTrip(
                trip: fetchedTrip!,
                userType: userType,
                rawData: data,
              );
              return;
            }
          } catch (e) {
            log('Error fetching recovered trip from chat_id: $e',
                name: 'NotificationRouting');
          }
        }
      }

      // B. Try active ongoing trip from LocalStorage
      final storedTrip = TripSecurityService.getActiveTrip(_storage);
      if (storedTrip != null &&
          storedTrip.status != TripStatus.canceled &&
          storedTrip.status != TripStatus.completed &&
          storedTrip.status != TripStatus.closed) {
        if (kDebugMode) {
          log('Routing chat tap to active stored trip #${storedTrip.id}',
              name: 'NotificationRouting');
        }
        _routeToChatForLiveTrip(
          trip: storedTrip,
          userType: userType,
          rawData: data,
        );
        return;
      }

      // C. Smart search: Query user trips from API and match sender name
      final userId = int.tryParse(
              _storage.read(key: 'userid')?.toString() ??
              _storage.read(key: 'user_id')?.toString() ??
              '') ??
          0;

      final senderName = _extractSenderName(title, data);

      if (userId > 0) {
        List<Trip> activeUserTrips = [];
        try {
          if (userType == 'driver') {
            if (_getDriverTrips != null) {
              final res = await _getDriverTrips!(userId);
              res.fold((_) {}, (list) => activeUserTrips.addAll(list));
            }
            // For driver: also search open passenger trips where driver might have made an offer
            if (_getTripsNearMe != null) {
              final lastLat = double.tryParse(
                      _storage.read(key: 'driver_last_latitude')?.toString() ?? '') ??
                  31.9454;
              final lastLng = double.tryParse(
                      _storage.read(key: 'driver_last_longitude')?.toString() ?? '') ??
                  35.9284;
              final nearRes = await _getTripsNearMe!(
                lat: lastLat,
                lng: lastLng,
                creationType: 'passenger',
                radius: '200',
                status: 'open',
              );
              nearRes.fold((_) {}, (list) {
                for (final item in list) {
                  if (!activeUserTrips.any((x) => x.id == item.id)) {
                    activeUserTrips.add(item);
                  }
                }
              });
            }
          } else if (_getPassengerTrips != null) {
            final res = await _getPassengerTrips!(userId);
            res.fold((_) {}, (list) => activeUserTrips = list);
          }
        } catch (e) {
          log('Error fetching user trips for chat deep-link: $e',
              name: 'NotificationRouting');
        }

        // Filter for active or open trips
        final ongoingOrOpenTrips = activeUserTrips.where((t) =>
            t.status != TripStatus.canceled &&
            t.status != TripStatus.completed &&
            t.status != TripStatus.closed).toList();

        if (ongoingOrOpenTrips.isNotEmpty) {
          Trip? matchedTrip;
          int? matchedDriverId = userType == 'driver' ? userId : null;

          // 1. If sender name is available, find matching trip & driver
          if (senderName != null && senderName.isNotEmpty) {
            final sNameLower = senderName.toLowerCase();
            for (final t in ongoingOrOpenTrips) {
              // Check trip creator
              final tCreatorName = (t.creator?.name ?? '').toLowerCase();
              if (tCreatorName.isNotEmpty &&
                  (tCreatorName.contains(sNameLower) || sNameLower.contains(tCreatorName))) {
                matchedTrip = t;
                break;
              }

              // Check all passengers
              for (final p in t.passengers) {
                final pName = p.name.toLowerCase();
                if (pName.contains(sNameLower) || sNameLower.contains(pName)) {
                  matchedTrip = t;
                  break;
                }
              }
              if (matchedTrip != null) break;

              // Check offers for matching driver (if receiver is passenger)
              for (final off in t.offers) {
                final dName = (off.driver?.name ?? '').toLowerCase();
                if (dName.contains(sNameLower) || sNameLower.contains(dName)) {
                  matchedTrip = t;
                  matchedDriverId = off.driverId > 0 ? off.driverId : off.driver?.id;
                  break;
                }
              }
              if (matchedTrip != null) break;

              // Check trip driver
              final tDriverName = (t.driver?.name ?? '').toLowerCase();
              if (tDriverName.isNotEmpty &&
                  (tDriverName.contains(sNameLower) || sNameLower.contains(tDriverName))) {
                matchedTrip = t;
                matchedDriverId = t.driverId ?? t.driver?.id;
                break;
              }
            }
          }

          // 2. If no exact name match, fallback to the latest active or open trip
          matchedTrip ??= ongoingOrOpenTrips.firstWhere(
            (t) => t.status == TripStatus.accepted,
            orElse: () => ongoingOrOpenTrips.first,
          );

          if (kDebugMode) {
            log('Smart chat routing: Found trip #${matchedTrip.id} (matchedDriverId: $matchedDriverId, userType: $userType) for sender "$senderName"',
                name: 'NotificationRouting');
          }

          _routeToChatForLiveTrip(
            trip: matchedTrip,
            userType: userType,
            targetDriverId: matchedDriverId,
            rawData: data,
          );
          return;
        }
      }

      // Safe fallback if user has no trips at all
      if (userType == 'driver') {
        router.push(AppRoutes.driverHome);
      } else {
        router.push(AppRoutes.passengerTrips);
      }
      return;
    }

    // ── 3. Non-chat, no tripId: route by notification type ──────────────
    switch (type) {
      case 'new_offer':
      case 'offer':
      case 'offer_received':
      case 'driver_offer':
      case 'offers':
        if (userType == 'driver') {
          router.push(AppRoutes.driverTrips);
        } else {
          if (tripType == 'shared' ||
              data['type'] == 'shared' ||
              data['trip_type'] == 'shared') {
            router.push(AppRoutes.passengerSharedCurrentTrip, extra: data);
          } else {
            router.push(AppRoutes.passengerPrivateOffers, extra: data);
          }
        }
        break;

      case 'new_trip':
      case 'new_trip_request':
      case 'trip_created':
      case 'available_trips':
      case 'new_order':
      case 'request':
        if (userType == 'driver') {
          router.push(AppRoutes.availableTrips);
        } else {
          router.push(AppRoutes.passengerTrips);
        }
        break;

      case 'pending_ratings':
        router.push(AppRoutes.pendingRatings);
        break;

      case 'my_ratings':
        router.push(AppRoutes.myRatings);
        break;

      case 'new_rating':
      case 'driver_rated':
        final driverId = int.tryParse(data['driver_id']?.toString() ?? '') ?? 0;
        if (driverId > 0) {
          router.push(AppRoutes.driverRatings, extra: {'driver_id': driverId});
        } else {
          router.push(AppRoutes.driverRatings);
        }
        break;

      case 'driver_trips':
      case 'my_trips':
        if (userType == 'driver') {
          router.push(AppRoutes.driverTrips);
        } else {
          router.push(AppRoutes.passengerTrips);
        }
        break;

      default:
        // General system notification with no trip context — no navigation.
        break;
    }
  }

  /// Dedicated helper to construct the full extra map and push AppRoutes.tripChat
  void _routeToChatForLiveTrip({
    required Trip trip,
    required String userType,
    int? targetDriverId,
    int? targetPassengerId,
    Map<String, dynamic>? rawData,
  }) {
    final router = _getRouter();
    final data = rawData ?? {};

    final acceptedOffer =
        trip.offers.where((o) => o.isAccepted).firstOrNull;

    final String explicitChatId =
        data['chat_id']?.toString() ?? data['chatId']?.toString() ?? '';
    final bool payloadIsInquiry = data['is_inquiry']?.toString() == 'true';
    final bool payloadIsOffersPhase =
        data['is_offers_phase']?.toString() == 'true';
    final bool payloadIsDm = data['is_dm']?.toString() == 'true';

    final bool isOffersPhase = payloadIsOffersPhase ||
        (trip.status == TripStatus.open && acceptedOffer == null);

    final currentLoggedInUserId = int.tryParse(
            _storage.read(key: 'userid')?.toString() ??
            _storage.read(key: 'user_id')?.toString() ??
            '') ??
        0;

    final String? senderNameFromTitle =
        _extractSenderName(data['title']?.toString() ?? '', data);

    Offer? matchingOffer;
    if (targetDriverId != null && targetDriverId > 0) {
      matchingOffer = trip.offers
          .where((o) =>
              o.driverId == targetDriverId || o.driver?.id == targetDriverId)
          .firstOrNull;
    }
    // If not matched by ID, try matching offer by driver's name against senderNameFromTitle
    if (matchingOffer == null &&
        senderNameFromTitle != null &&
        senderNameFromTitle.trim().isNotEmpty) {
      final sNorm = senderNameFromTitle.trim().toLowerCase();
      matchingOffer = trip.offers.where((o) {
        final dName = o.driver?.name.trim().toLowerCase() ?? '';
        return dName.isNotEmpty &&
            (dName == sNorm || dName.contains(sNorm) || sNorm.contains(dName));
      }).firstOrNull;
    }
    // Fallback to accepted offer or single offer
    matchingOffer ??= acceptedOffer ?? (trip.offers.length == 1 ? trip.offers.first : null);

    final int? resolvedDriverId = userType == 'driver'
        ? (currentLoggedInUserId > 0
            ? currentLoggedInUserId
            : (targetDriverId ?? trip.driverId ?? trip.driver?.id))
        : (matchingOffer?.driverId != null && matchingOffer!.driverId > 0
            ? matchingOffer.driverId
            : (matchingOffer?.driver?.id != null && matchingOffer!.driver!.id > 0
                ? matchingOffer.driver!.id
                : (targetDriverId ??
                    acceptedOffer?.driverId ??
                    trip.driverId ??
                    trip.driver?.id ??
                    int.tryParse(data['driver_id']?.toString() ?? ''))));

    final String displayName = userType == 'driver'
        ? (trip.creator?.name.isNotEmpty == true
            ? trip.creator!.name
            : (trip.passengers.isNotEmpty == true
                ? trip.passengers.first.name
                : (data['sender_name']?.toString() ??
                    senderNameFromTitle ??
                    S.current.passengerRole)))
        : (matchingOffer?.driver?.name.isNotEmpty == true
            ? matchingOffer!.driver!.name
            : (trip.driver?.name.isNotEmpty == true
                ? trip.driver!.name
                : (acceptedOffer?.driver?.name.isNotEmpty == true
                    ? acceptedOffer!.driver!.name
                    : (data['sender_name']?.toString() ??
                        senderNameFromTitle ??
                        S.current.driverRole))));

    final String displayPhone = userType == 'driver'
        ? (trip.creator?.phone ??
            (trip.passengers.isNotEmpty == true
                ? (trip.passengers.first.phone ?? '')
                : ''))
        : (matchingOffer?.driver?.phone ??
            trip.driver?.phone ??
            acceptedOffer?.driver?.phone ??
            '');

    final String? displayPhoto = userType == 'driver'
        ? (trip.creator?.photo ??
            (trip.passengers
                .where((p) => p.photo != null && p.photo!.trim().isNotEmpty)
                .firstOrNull
                ?.photo))
        : (matchingOffer?.driver?.photo ??
            trip.driver?.photo ??
            acceptedOffer?.driver?.photo);

    final int? resolvedPassengerId = targetPassengerId ??
        trip.creator?.id ??
        trip.createdBy ??
        (trip.passengers.isNotEmpty == true
            ? trip.passengers.first.id
            : null) ??
        int.tryParse(data['passenger_id']?.toString() ?? '');

    final bool isTripShared = trip.type == TripType.shared ||
        data['trip_type']?.toString() == 'shared' ||
        data['tripType']?.toString() == 'shared';

    final String effectiveChatId = explicitChatId.isNotEmpty
        ? explicitChatId
        : ChatChannelHelper.resolveChatId(
            tripId: trip.id,
            driverId: resolvedDriverId,
            passengerId: resolvedPassengerId,
            tripType: isTripShared ? 'shared' : 'private',
            isInquiry: payloadIsInquiry,
            isDm: payloadIsDm,
            isOffersPhase: isOffersPhase,
          );

    final membersList = [
      ...trip.passengers.map((p) => p.toMap()),
      if (trip.driver != null) trip.driver!.toMap(),
      if (trip.creator != null) trip.creator!.toMap(),
      if (matchingOffer?.driver != null) matchingOffer!.driver!.toMap(),
    ];

    if (kDebugMode) {
      log('Navigating to TripChat → tripId: ${trip.id}, chatId: "$effectiveChatId", isOffersPhase: $isOffersPhase, driverId: $resolvedDriverId, passengerId: $resolvedPassengerId, displayName: "$displayName"',
          name: 'NotificationRouting');
    }

    router.push(
      AppRoutes.tripChat,
      extra: {
        'tripId': trip.id,
        'trip_id': trip.id,
        'offerId': matchingOffer?.id ??
            acceptedOffer?.id ??
            int.tryParse(data['offer_id']?.toString() ?? '0') ??
            0,
        'offer_id': matchingOffer?.id ??
            acceptedOffer?.id ??
            int.tryParse(data['offer_id']?.toString() ?? '0') ??
            0,
        'driverId': resolvedDriverId,
        'passengerId': resolvedPassengerId,
        'creatorId': trip.creator?.id ?? trip.createdBy,
        'chatId': effectiveChatId,
        'driverName': displayName,
        'driverPhone': displayPhone,
        'driverPhoto': displayPhoto,
        'tripFrom': trip.fromLocationName.isNotEmpty
            ? trip.fromLocationName
            : (data['tripFrom']?.toString() ?? data['from']?.toString() ?? ''),
        'tripTo': trip.toLocationName.isNotEmpty
            ? trip.toLocationName
            : (data['tripTo']?.toString() ?? data['to']?.toString() ?? ''),
        'tripDatetime': trip.tripDatetime.isNotEmpty
            ? trip.tripDatetime
            : (data['tripDatetime']?.toString() ?? ''),
        'acceptedPrice': trip.approvedPrice ??
            matchingOffer?.price ??
            acceptedOffer?.price ??
            double.tryParse(data['acceptedPrice']?.toString() ?? '0') ??
            0.0,
        'tripType': isTripShared ? 'shared' : 'private',
        'members': membersList.isNotEmpty ? membersList : data['members'],
        'isInquiry': payloadIsInquiry,
        'isOffersPhase': isOffersPhase,
        'isDm': payloadIsDm,
      },
    );
  }

  /// Extracts the sender's display name from notification title or data payload.
  ///
  /// Examples:
  ///   "رسالة جديدة من محمد حميد" -> "محمد حميد"
  ///   "رسالة من محمد حميد"       -> "محمد حميد"
  ///   "New message from مروان ماجد" -> "مروان ماجد"
  static String? _extractSenderName(String title, Map<String, dynamic> data) {
    if (data['sender_name'] != null &&
        data['sender_name'].toString().trim().isNotEmpty) {
      return data['sender_name'].toString().trim();
    }
    final t = title.trim();
    if (t.isEmpty) return null;

    // 1. Arabic patterns
    if (t.contains('رسالة جديدة من ')) {
      final name = t.split('رسالة جديدة من ').last.trim();
      if (name.isNotEmpty) return name;
    }
    if (t.contains('رسالة من ')) {
      final name = t.split('رسالة من ').last.trim();
      if (name.isNotEmpty) return name;
    }

    // 2. English patterns (case-insensitive)
    final lower = t.toLowerCase();
    const englishPrefixes = [
      'new message from ',
      'new msg from ',
      'message from ',
      'msg from ',
      'chat from ',
    ];
    for (final prefix in englishPrefixes) {
      final idx = lower.indexOf(prefix);
      if (idx != -1) {
        final name = t.substring(idx + prefix.length).trim();
        if (name.isNotEmpty) return name;
      }
    }
    return null;
  }

  /// Parses the numeric trip ID embedded in a Firestore chat channel ID.
  ///
  /// Examples:
  ///   "private_trip_5_driver_3"   → 5
  ///   "shared_trip_7"             → 7
  ///   "shared_trip_7_inquiry_12"  → 7
  ///   "shared_trip_7_dm_12"       → 7
  static int? _extractTripIdFromChatId(String chatId) {
    final match = RegExp(r'trip_(\d+)').firstMatch(chatId);
    return match != null ? int.tryParse(match.group(1) ?? '') : null;
  }
}
