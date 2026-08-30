import 'package:equatable/equatable.dart';
import 'package:car_app/features/chat/domain/entities/chat_message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessageEntity> messages;

  const ChatLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatTripCanceledSuccess extends ChatState {
  final String reason;

  const ChatTripCanceledSuccess(this.reason);

  @override
  List<Object?> get props => [reason];
}
