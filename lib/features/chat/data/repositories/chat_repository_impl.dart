import 'package:car_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:car_app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:car_app/features/chat/domain/entities/chat_message_entity.dart';
import 'package:car_app/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl({required ChatRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Stream<List<ChatMessageEntity>> getMessages({
    required String tripId,
    required String currentUserId,
  }) {
    return _remoteDataSource.getMessages(
      tripId: tripId,
      currentUserId: currentUserId,
    );
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String tripId,
    required String senderId,
    required String senderName,
    required String text,
    bool isDriver = false,
    String senderType = 'passenger',
  }) async {
    try {
      await _remoteDataSource.sendMessage(
        tripId: tripId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        isDriver: isDriver,
        senderType: senderType,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChat({required String chatId}) async {
    try {
      await _remoteDataSource.deleteChat(chatId: chatId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
