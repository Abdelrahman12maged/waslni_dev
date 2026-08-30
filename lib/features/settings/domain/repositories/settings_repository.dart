import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/settings/domain/entities/user_profile.dart';
import 'package:car_app/features/settings/domain/entities/saved_location.dart';
import 'package:dartz/dartz.dart';

abstract class SettingsRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String token);
  Future<Either<Failure, void>> updateUserProfile({
    required dynamic profileData,
    required String token,
  });
  Future<Either<Failure, List<SavedLocation>>> getSavedLocations(String token);
  Future<Either<Failure, void>> addSavedLocation({
    required String name,
    required String latitude,
    required String longitude,
    required String token,
  });
  Future<Either<Failure, void>> deleteSavedLocation(int id, String token);
}
