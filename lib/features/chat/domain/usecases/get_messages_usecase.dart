import 'package:car_app/features/chat/domain/entities/chat_message_entity.dart';
import 'package:car_app/features/chat/domain/repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository _repository;

  GetMessagesUseCase(this._repository);

  Stream<List<ChatMessageEntity>> call({
    required String tripId,
    required String currentUserId,
  }) {
    return _repository.getMessages(
      tripId: tripId,
      currentUserId: currentUserId,
    );
  }
}
