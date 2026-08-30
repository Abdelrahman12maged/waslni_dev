import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:car_app/features/chat/domain/entities/chat_message_entity.dart';
import 'package:car_app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:car_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:car_app/features/chat/presentation/cubit/chat_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/di/injection_container.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMessagesUseCase _getMessages;
  final SendMessageUseCase _sendMessage;
  final LocalStorage _storage;
  final ChatRemoteDataSource? _remoteDataSource;

  StreamSubscription<List<ChatMessageEntity>>? _messagesSub;

  ChatCubit({
    required GetMessagesUseCase getMessages,
    required SendMessageUseCase sendMessage,
    required LocalStorage storage,
    ChatRemoteDataSource? remoteDataSource,
  })  : _getMessages = getMessages,
        _sendMessage = sendMessage,
        _storage = storage,
        _remoteDataSource = remoteDataSource,
        super(const ChatInitial());

  String get currentUserId =>
      _storage.read(key: 'userid')?.toString() ??
      _storage.read(key: 'user_id')?.toString() ??
      '1';

  String get currentUserName =>
      _storage.read(key: 'username')?.toString() ??
      _storage.read(key: 'name')?.toString() ??
      (isCurrentUserDriver ? S.current.driver : S.current.passenger);

  bool get isCurrentUserDriver {
    final type = _storage.read(key: 'user_type')?.toString().toLowerCase() ?? '';
    final usertype = _storage.read(key: 'usertype')?.toString().toLowerCase() ?? '';
    final role = _storage.read(key: 'role')?.toString().toLowerCase() ?? '';
    final isDriverKey = _storage.read(key: 'is_driver');
    return type == 'driver' ||
        usertype == 'driver' ||
        role == 'driver' ||
        isDriverKey == true ||
        isDriverKey == '1' ||
        isDriverKey == 1;
  }

  void listenToMessages(String tripId) {
    emit(const ChatLoading());
    _messagesSub?.cancel();
    flushPendingMessages(tripId);
    markAsRead(tripId);
    _messagesSub = _getMessages(
      tripId: tripId,
      currentUserId: currentUserId,
    ).listen(
      (messages) {
        emit(ChatLoaded(messages));
        markAsRead(tripId);
      },
      onError: (error) {
        emit(ChatError(error.toString()));
      },
    );
  }

  Future<void> markAsRead(String tripId) async {
    try {
      final ds = _remoteDataSource ?? sl<ChatRemoteDataSource>();
      await ds.markMessagesAsRead(chatId: tripId, currentUserId: currentUserId);
    } catch (_) {}
  }

  Future<void> sendMessage({
    required String tripId,
    required String text,
    bool? isDriver,
  }) async {
    if (text.trim().isEmpty) return;

    final bool driverFlag = isDriver ?? isCurrentUserDriver;

    final result = await _sendMessage(
      tripId: tripId,
      senderId: currentUserId,
      senderName: currentUserName,
      text: text.trim(),
      isDriver: driverFlag,
      senderType: driverFlag ? 'driver' : 'passenger',
    );

    result.fold(
      (failure) {
        _queuePendingMessage(tripId, text.trim());
        emit(ChatError(failure.message));
      },
      (_) {},
    );
  }

  void _queuePendingMessage(String tripId, String text) {
    final key = 'pending_chat_$tripId';
    final existing = _storage.read(key: key) as String? ?? '';
    final list = existing.split('|||').where((s) => s.isNotEmpty).toList();
    list.add(text);
    _storage.saveString(key: key, value: list.join('|||'));
  }

  Future<void> flushPendingMessages(String tripId) async {
    final key = 'pending_chat_$tripId';
    final existing = _storage.read(key: key) as String? ?? '';
    if (existing.isEmpty) return;

    final messages = existing.split('|||').where((s) => s.isNotEmpty).toList();
    await _storage.remove(key: key);

    for (final text in messages) {
      await sendMessage(tripId: tripId, text: text);
    }
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }
}
