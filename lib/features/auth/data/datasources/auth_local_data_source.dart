import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:car_app/features/auth/data/models/user_model.dart';
import 'package:car_app/core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel userModel, Map<String, dynamic> rawUserData);
  Future<String?> getUserToken();
  Future<String?> getFcmToken();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel userModel, Map<String, dynamic> rawUserData) async {
    try {
      if (userModel.token != null) {
        await sharedPreferences.setString('usertoken', userModel.token!);
      }
      await sharedPreferences.setString('usertype', userModel.userType);
      await sharedPreferences.setInt('userid', userModel.id);
      if (userModel.name.isNotEmpty) {
        await sharedPreferences.setString('username', userModel.name);
        await sharedPreferences.setString('driver_name', userModel.name);
      }
      if (userModel.photo != null && userModel.photo!.isNotEmpty) {
        await sharedPreferences.setString('profile_picture_url', userModel.photo!);
      }
      await sharedPreferences.setBool('onboarding', false);

      // Check if active / kyc status is present in login payload
      final uObj = rawUserData['user'] is Map
          ? rawUserData['user']
          : (rawUserData['data'] is Map ? rawUserData['data'] : rawUserData);
      final rawIsActive = uObj['is_active'] ??
          rawUserData['is_active'] ??
          uObj['active'] ??
          rawUserData['active'] ??
          uObj['status'] ??
          rawUserData['status'] ??
          uObj['account_status'] ??
          rawUserData['account_status'];

      if (rawIsActive != null) {
        final isActive = rawIsActive == true ||
            rawIsActive == 1 ||
            rawIsActive == '1' ||
            rawIsActive.toString().toLowerCase() == 'true' ||
            rawIsActive.toString().toLowerCase() == 'active';
        await sharedPreferences.setString(
          'driver_kyc_active',
          isActive ? 'true' : 'false',
        );
      }

      // Save full user data inside Hive for ongoing layout checks.
      // Strip sensitive credential fields before persisting — passwords must never
      // be stored on-device in any form (plain or hashed).
      final safeUserData = Map<String, dynamic>.from(rawUserData);
      safeUserData.remove('password');
      safeUserData.remove('password_hash');
      safeUserData.remove('hash');
      safeUserData.remove('pwd');
      if (safeUserData['user'] is Map) {
        final safeUser = Map<String, dynamic>.from(safeUserData['user'] as Map);
        safeUser.remove('password');
        safeUser.remove('password_hash');
        safeUser.remove('hash');
        safeUser.remove('pwd');
        safeUserData['user'] = safeUser;
      }

      final box = await Hive.openBox('hive_box');
      await box.put('user_data', safeUserData);
    } catch (e) {
      throw const CacheException('Failed to write authentication cache');
    }
  }

  @override
  Future<String?> getUserToken() async {
    return sharedPreferences.getString('usertoken');
  }

  @override
  Future<String?> getFcmToken() async {
    return sharedPreferences.getString('fcmToken');
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove('usertoken');
      await sharedPreferences.remove('usertype');
      await sharedPreferences.remove('userid');
      
      final box = await Hive.openBox('hive_box');
      await box.delete('user_data');
    } catch (e) {
      throw const CacheException('Failed to clear authentication cache');
    }
  }
}
