import 'package:car_app/features/notifications/data/models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications(String token);
}
