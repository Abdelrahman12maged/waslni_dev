import 'package:car_app/core/error/exceptions.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:car_app/features/settings/data/models/user_profile_model.dart';
import 'package:car_app/features/settings/data/models/saved_location_model.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';


class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio _dio;

  const SettingsRemoteDataSourceImpl(this._dio);

  @override
  Future<UserProfileModel> getUserProfile(String token) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.myProfile,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        try {
          final box = await Hive.openBox('hive_box');
          final rawData = response.data;
          if (rawData is Map<String, dynamic>) {
            final safeUserData = Map<String, dynamic>.from(rawData);
            if (safeUserData['user'] is Map) {
              final safeUser = Map<String, dynamic>.from(safeUserData['user'] as Map);
              safeUser.remove('password');
              safeUserData['user'] = safeUser;
            }
            await box.put('user_data', safeUserData);
          } else {
            await box.put('user_data', response.data);
          }
        } catch (_) {}
        return UserProfileModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to get user profile');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Dio error getting user profile');
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserProfile({
    required dynamic profileData,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.updateProfile,
        data: profileData is FormData ? profileData : FormData.fromMap(profileData),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        final box = await Hive.openBox('hive_box');
        final rawData = response.data;
        if (rawData is Map<String, dynamic>) {
          final safeUserData = Map<String, dynamic>.from(rawData);
          if (safeUserData['user'] is Map) {
            final safeUser = Map<String, dynamic>.from(safeUserData['user'] as Map);
            safeUser.remove('password');
            safeUserData['user'] = safeUser;
          }
          await box.put('user_data', safeUserData);
        } else {
          await box.put('user_data', response.data);
        }
        return response.data;
      } else {
        throw const ServerException('Failed to update profile');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Dio error updating profile');
    }
  }

  @override
  Future<List<SavedLocationModel>> getSavedLocations(String token) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.savedLocations,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        final rawLocations = response.data['user_locations'] as List? ?? [];
        return rawLocations
            .map((j) => SavedLocationModel.fromJson(j as Map<String, dynamic>))
            .toList();
      } else {
        throw const ServerException('Failed to get saved locations');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Dio error getting saved locations');
    }
  }

  @override
  Future<void> addSavedLocation({
    required String name,
    required String latitude,
    required String longitude,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.addLocation,
        data: {
          'name': name,
          'latitude': latitude,
          'longitude': longitude,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final statusCode = response.statusCode ?? 0;
      final data = response.data;
      final bool isHttpSuccess = statusCode >= 200 && statusCode < 300;
      final bool isDataSuccess = data is Map
          ? (data['status'] == 200 ||
              data['status'] == 201 ||
              data['status'] == true ||
              data['status'] == 'success')
          : true;

      if (!isHttpSuccess && !isDataSuccess) {
        throw const ServerException('Failed to add saved location');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Dio error adding saved location');
    }
  }

  @override
  Future<void> deleteSavedLocation(int id, String token) async {
    try {
      final response = await _dio.delete(
        '${ApiEndpoints.deleteLocation}$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final statusCode = response.statusCode ?? 0;
      final data = response.data;
      final bool isHttpSuccess = statusCode >= 200 && statusCode < 300;
      final bool isDataSuccess = data is Map
          ? (data['status'] == 200 ||
              data['status'] == 201 ||
              data['status'] == true ||
              data['status'] == 'success')
          : true;

      if (!isHttpSuccess && !isDataSuccess) {
        throw const ServerException('Failed to delete saved location');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Dio error deleting saved location');
    }
  }
}
