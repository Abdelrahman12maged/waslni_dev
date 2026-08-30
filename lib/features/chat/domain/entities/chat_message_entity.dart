import 'package:equatable/equatable.dart';

/// Represents a single chat message entity in the domain layer.
class ChatMessageEntity extends Equatable {
  final String id;
  final String tripId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final bool isDriver;
  final String senderType;
  /// List of userIds who have read this message.
  final List<String> readBy;

  const ChatMessageEntity({
    required this.id,
    required this.tripId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isMe = false,
    this.isDriver = false,
    this.senderType = 'passenger',
    this.readBy = const [],
  });

  @override
  List<Object?> get props => [
        id,
        tripId,
        senderId,
        senderName,
        text,
        timestamp,
        isMe,
        isDriver,
        senderType,
        readBy,
      ];
}
