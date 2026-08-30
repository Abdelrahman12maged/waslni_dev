import 'package:car_app/features/settings/data/models/user_profile_model.dart';
import 'package:car_app/features/settings/data/models/saved_location_model.dart';

abstract class SettingsRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String token);
  Future<Map<String, dynamic>> updateUserProfile({
    required dynamic profileData,
    required String token,
  });
  Future<List<SavedLocationModel>> getSavedLocations(String token);
  Future<void> addSavedLocation({
    required String name,
    required String latitude,
    required String longitude,
    required String token,
  });
  Future<void> deleteSavedLocation(int id, String token);
}
