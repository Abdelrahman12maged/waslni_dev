import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/notifications/domain/entities/app_notification.dart';
import 'package:dartz/dartz.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications(String token);
}
