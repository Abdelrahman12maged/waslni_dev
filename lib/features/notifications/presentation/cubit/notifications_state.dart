import 'package:car_app/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsSuccess extends NotificationsState {
  final List<AppNotification> notifications;
  NotificationsSuccess(this.notifications);
}

class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError(this.message);
}
