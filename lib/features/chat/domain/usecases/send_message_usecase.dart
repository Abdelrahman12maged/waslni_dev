import 'package:car_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:car_app/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String tripId,
    required String senderId,
    required String senderName,
    required String text,
    bool isDriver = false,
    String senderType = 'passenger',
  }) {
    return _repository.sendMessage(
      tripId: tripId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      isDriver: isDriver,
      senderType: senderType,
    );
  }
}
