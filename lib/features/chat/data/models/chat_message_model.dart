import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_app/features/chat/domain/entities/chat_message_entity.dart';

/// Data model for [ChatMessageEntity]. Handles Firestore serialization.
class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.tripId,
    required super.senderId,
    required super.senderName,
    required super.text,
    required super.timestamp,
    super.isMe,
    super.isDriver,
    super.senderType,
    super.readBy,
  });

  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String currentUserId,
  ) {
    final data = doc.data() ?? {};
    final rawTimestamp = data['timestamp'];
    DateTime dt;
    if (rawTimestamp is Timestamp) {
      dt = rawTimestamp.toDate();
    } else if (rawTimestamp is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else {
      dt = DateTime.now();
    }

    final senderIdStr = data['senderId']?.toString() ?? '';
    final senderTypeStr = data['senderType']?.toString().toLowerCase() ??
        (data['is_driver'] == true ? 'driver' : 'passenger');
    final bool isDriverMsg = data['is_driver'] == true ||
        data['isDriver'] == true ||
        senderTypeStr == 'driver';

    final readByRaw = data['readBy'];
    final List<String> readByList = readByRaw is List
        ? readByRaw.map((e) => e.toString()).toList()
        : <String>[];

    return ChatMessageModel(
      id: doc.id,
      tripId: data['tripId']?.toString() ?? '',
      senderId: senderIdStr,
      senderName: data['senderName']?.toString() ?? '',
      text: data['text']?.toString() ?? '',
      timestamp: dt,
      isMe: senderIdStr == currentUserId,
      isDriver: isDriverMsg,
      senderType: senderTypeStr,
      readBy: readByList,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'is_driver': isDriver,
      'text': text,
      'readBy': readBy,
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
