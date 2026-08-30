import 'package:car_app/core/error/exceptions.dart';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:car_app/features/notifications/domain/entities/app_notification.dart';
import 'package:car_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:dartz/dartz.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  const NotificationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications(
    String token,
  ) async {
    try {
      final list = await _remoteDataSource.getNotifications(token);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
