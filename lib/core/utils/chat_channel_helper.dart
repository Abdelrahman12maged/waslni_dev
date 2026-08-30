/// Central helper for computing isolated chat channel IDs in Firestore.
///
/// Channels are scoped by:
/// 1. Private trip + driverId: `private_trip_${tripId}_driver_${driverId}`
/// 2. Shared trip group: `shared_trip_${tripId}`
/// 3. Shared trip inquiry: `shared_trip_${tripId}_inquiry_${passengerId}`
class ChatChannelHelper {
  ChatChannelHelper._();

  /// Channel ID for private trip between passenger and a specific driver.
  static String privateTripChatId({
    required dynamic tripId,
    required dynamic driverId,
  }) {
    final tId = tripId.toString().trim();
    final dId = driverId?.toString().trim();
    if (dId != null && dId.isNotEmpty && dId != '0' && dId != 'null') {
      return 'private_trip_${tId}_driver_$dId';
    }
    return 'private_trip_$tId';
  }

  /// Channel ID for shared trip group chat (driver + all accepted passengers).
  static String sharedTripGroupChatId({required dynamic tripId}) {
    final tId = tripId.toString().trim();
    return 'shared_trip_$tId';
  }

  /// Channel ID for private inquiry from a searching passenger before joining shared trip.
  static String sharedTripInquiryChatId({
    required dynamic tripId,
    required dynamic passengerId,
  }) {
    final tId = tripId.toString().trim();
    final pId = passengerId?.toString().trim();
    if (pId != null && pId.isNotEmpty && pId != '0' && pId != 'null') {
      return 'shared_trip_${tId}_inquiry_$pId';
    }
    return 'shared_trip_$tId';
  }

  /// Channel ID for direct 1-on-1 private DM between a joined passenger and the driver in a shared trip.
  static String sharedTripDmChatId({
    required dynamic tripId,
    required dynamic passengerId,
  }) {
    final tId = tripId.toString().trim();
    final pId = passengerId?.toString().trim();
    if (pId != null && pId.isNotEmpty && pId != '0' && pId != 'null') {
      return 'shared_trip_${tId}_dm_$pId';
    }
    return 'shared_trip_$tId';
  }

  /// Helper to resolve the appropriate chatId based on context parameters.
  static String resolveChatId({
    String? explicitChatId,
    required dynamic tripId,
    dynamic driverId,
    dynamic passengerId,
    String tripType = 'private',
    bool isInquiry = false,
    bool isDm = false,
    bool isOffersPhase = false,
  }) {
    if (explicitChatId != null && explicitChatId.trim().isNotEmpty) {
      return explicitChatId.trim();
    }

    // During offers phase, communication is ALWAYS 1-on-1 between passenger and that specific driver
    final dId = driverId?.toString().trim();
    if (isOffersPhase && dId != null && dId.isNotEmpty && dId != '0' && dId != 'null') {
      return privateTripChatId(tripId: tripId, driverId: driverId);
    }

    final isShared = tripType.toLowerCase() == 'shared';
    if (isShared) {
      if (isDm && passengerId != null) {
        return sharedTripDmChatId(
          tripId: tripId,
          passengerId: passengerId,
        );
      }
      if (isInquiry && passengerId != null) {
        return sharedTripInquiryChatId(
          tripId: tripId,
          passengerId: passengerId,
        );
      }
      return sharedTripGroupChatId(tripId: tripId);
    } else {
      return privateTripChatId(tripId: tripId, driverId: driverId);
    }
  }
}
