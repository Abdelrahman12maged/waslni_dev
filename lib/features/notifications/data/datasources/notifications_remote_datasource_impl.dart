import 'package:car_app/core/error/exceptions.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:car_app/features/notifications/data/models/notification_model.dart';
import 'package:dio/dio.dart';

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final Dio _dio;

  const NotificationsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NotificationModel>> getNotifications(String token) async {
    try {
      Response response;
      try {
        response = await _dio.get(
          ApiEndpoints.getNotifications,
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 405) {
          response = await _dio.post(
            ApiEndpoints.getNotifications,
            data: {},
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          );
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200) {
        final data = response.data;
        List rawList = [];
        if (data is Map) {
          rawList = data['notifications'] as List? ??
                    data['data'] as List? ??
                    data['result'] as List? ??
                    [];
        } else if (data is List) {
          rawList = data;
        }
        return rawList
            .whereType<Map>()
            .map((j) => NotificationModel.fromJson(Map<String, dynamic>.from(j)))
            .toList();
      } else {
        throw const ServerException('Failed to fetch notifications');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Dio error fetching notifications');
    }
  }
}
