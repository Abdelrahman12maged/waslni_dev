import 'package:car_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:car_app/features/chat/domain/entities/chat_message_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatMessageEntity>> getMessages({
    required String tripId,
    required String currentUserId,
  });

  Future<Either<Failure, void>> sendMessage({
    required String tripId,
    required String senderId,
    required String senderName,
    required String text,
    bool isDriver = false,
    String senderType = 'passenger',
  });

  Future<Either<Failure, void>> deleteChat({required String chatId});
}
