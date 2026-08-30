import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/notifications/domain/entities/app_notification.dart';
import 'package:car_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:dartz/dartz.dart';

class GetNotificationsUseCase {
  final NotificationsRepository _repository;

  const GetNotificationsUseCase(this._repository);

  Future<Either<Failure, List<AppNotification>>> call(String token) =>
      _repository.getNotifications(token);
}
