import 'package:car_app/core/error/exceptions.dart';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:car_app/features/settings/domain/entities/user_profile.dart';
import 'package:car_app/features/settings/domain/entities/saved_location.dart';
import 'package:car_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _remoteDataSource;

  const SettingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String token) async {
    try {
      final profile = await _remoteDataSource.getUserProfile(token);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    required dynamic profileData,
    required String token,
  }) async {
    try {
      await _remoteDataSource.updateUserProfile(
        profileData: profileData,
        token: token,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SavedLocation>>> getSavedLocations(
    String token,
  ) async {
    try {
      final locations = await _remoteDataSource.getSavedLocations(token);
      return Right(locations);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addSavedLocation({
    required String name,
    required String latitude,
    required String longitude,
    required String token,
  }) async {
    try {
      await _remoteDataSource.addSavedLocation(
        name: name,
        latitude: latitude,
        longitude: longitude,
        token: token,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSavedLocation(
    int id,
    String token,
  ) async {
    try {
      await _remoteDataSource.deleteSavedLocation(id, token);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
