import 'dart:developer';
import 'package:car_app/core/network/api_client.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/generated/l10n.dart';

/// Helper utility for sending FCM push notification triggers during the trip lifecycle.
class FcmNotificationService {
  final ApiClient _client;
  final LocalStorage _storage;

  FcmNotificationService({
    required ApiClient client,
    required LocalStorage storage,
  })  : _client = client,
        _storage = storage;

  /// Sends a push notification to a target FCM token.
  Future<void> sendNotification({
    required String targetFcmToken,
    required String title,
    required String body,
    int? targetUserId,
    Map<String, dynamic>? data,
  }) async {
    if (targetFcmToken.isEmpty) return;

    try {
      final token = _storage.read(key: 'usertoken') ?? '';

      final int resolvedUserId = targetUserId ??
          (data != null && data['user_id'] != null
              ? int.tryParse(data['user_id'].toString())
              : null) ??
          (data != null && data['receiver_id'] != null
              ? int.tryParse(data['receiver_id'].toString())
              : null) ??
          0;

      final passengerItem = {
        'id': resolvedUserId,
        'fcm_token': targetFcmToken,
        'device_token': targetFcmToken,
        'token': targetFcmToken,
      };

      final payload = {
        "title": title,
        "body": body,
        "message": body,
        "fcm_token": targetFcmToken,
        "device_token": targetFcmToken,
        "token": targetFcmToken,
        "passengers": (data != null &&
                data['passengers'] is List &&
                (data['passengers'] as List).isNotEmpty)
            ? data['passengers']
            : [passengerItem],
        if (data != null) ...data,
        if (data != null) "data": data,
        if (data != null && data['trip_id'] != null) "trip_id": data['trip_id'],
        if (data != null && data['type'] != null) "type": data['type'],
      };

      final response = await _client.post(
        url: ApiEndpoints.sendFcmNotification,
        token: token,
        data: payload,
      );

      log('[FCM Debug] Sending notification payload to ${ApiEndpoints.sendFcmNotification}: $payload',
          name: 'FcmNotificationService');

      response.fold(
        (failure) => log(
            '[FCM Debug] ❌ Failed to send FCM notification to $targetFcmToken: ${failure.message}',
            name: 'FcmNotificationService'),
        (res) => log(
            '[FCM Debug] ✅ FCM Notification successfully sent to $targetFcmToken: $title | Result: $res',
            name: 'FcmNotificationService'),
      );
    } catch (e, stack) {
      log('[FCM Debug] ❌ Exception sending FCM notification: $e\n$stack',
          name: 'FcmNotificationService');
    }
  }

  /// Triggered when a new Firestore chat message is sent.
  /// Carries full chat context so the receiver can deep-link to the exact
  /// chat channel (inquiry / DM / group / private) without guessing.
  Future<void> notifyChatMessage({
    required String targetFcmToken,
    required String senderName,
    required String messageText,
    required int tripId,
    int? targetUserId,
    String? chatId,
    // ── Chat channel context ──────────────────────────────────────
    String tripType = 'private',    // 'private' | 'shared'
    bool isInquiry = false,         // pre-join inquiry in shared trip search
    bool isOffersPhase = false,     // during the offers/bidding phase
    bool isDm = false,              // private DM inside a shared trip
    int? passengerId,
    int? driverId,
  }) async {
    await sendNotification(
      targetFcmToken: targetFcmToken,
      targetUserId: targetUserId,
      title: S.current.newMsgFrom(senderName),
      body: messageText,
      data: {
        'type': 'chat',
        'trip_id': tripId.toString(),
        'trip_type': tripType,
        'is_inquiry': isInquiry.toString(),
        'is_offers_phase': isOffersPhase.toString(),
        'is_dm': isDm.toString(),
        if (targetUserId != null) 'user_id': targetUserId.toString(),
        if (chatId != null && chatId.isNotEmpty) 'chat_id': chatId,
        if (passengerId != null) 'passenger_id': passengerId.toString(),
        if (driverId != null) 'driver_id': driverId.toString(),
        'sender_name': senderName,
      },
    );
  }

  // // ── Lifecycle notifications are managed automatically by backend ──────────
  // // The methods below are kept as safe no-ops to avoid duplicate notifications.

  // Future<void> notifyOfferSubmitted({
  //   required String passengerFcmToken,
  //   required String driverName,
  //   required double offerPrice,
  //   required int tripId,
  // }) async {
  //   // Managed automatically by backend
  // }

  // Future<void> notifyOfferAccepted({
  //   required String driverFcmToken,
  //   required String passengerName,
  //   required int tripId,
  // }) async {
  //   // Managed automatically by backend
  // }

  // Future<void> notifyDriverArrived({
  //   required String passengerFcmToken,
  //   required String driverName,
  //   required int tripId,
  // }) async {
  //   // Managed automatically by backend
  // }

  // Future<void> notifyTripStarted({
  //   required String passengerFcmToken,
  //   required int tripId,
  // }) async {
  //   // Managed automatically by backend
  // }

  // Future<void> notifyTripCompleted({
  //   required String passengerFcmToken,
  //   required int tripId,
  // }) async {
  //   // Managed automatically by backend
  // }

  // Future<void> notifyJoinedPassengersOnTripCanceled({
  //   required List<dynamic> passengerFcmTokens,
  //   required String driverName,
  //   required String tripId,
  // }) async {
  //   // Managed automatically by backend
  // }
}
