import 'dart:developer';

import 'package:car_app/core/error/exceptions.dart';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/ratings/data/datasources/ratings_remote_datasource.dart';
import 'package:car_app/features/ratings/domain/entities/driver_ratings_page.dart';
import 'package:car_app/features/ratings/domain/entities/my_ratings_page.dart';
import 'package:car_app/features/ratings/domain/entities/pending_rating_trip.dart';
import 'package:car_app/features/ratings/domain/entities/rating_result.dart';
import 'package:car_app/features/ratings/domain/repositories/ratings_repository.dart';
import 'package:dartz/dartz.dart';

class RatingsRepositoryImpl implements RatingsRepository {
  final RatingsRemoteDataSource _remoteDataSource;
  final LocalStorage _storage;

  const RatingsRepositoryImpl({
    required RatingsRemoteDataSource remoteDataSource,
    required LocalStorage storage,
  })  : _remoteDataSource = remoteDataSource,
        _storage = storage;

  String get _token => _storage.read(key: 'usertoken')?.toString() ?? '';

  @override
  Future<Either<Failure, RatingResult>> submitRating({
    required int tripId,
    required int stars,
    String? comment,
    int? ratedUserId,
  }) async {
    try {
      final result = await _remoteDataSource.submitRating(
        tripId: tripId,
        stars: stars,
        comment: comment,
        ratedUserId: ratedUserId,
        token: _token,
      );
      return Right(result);
    } on ServerException catch (e) {
      log('submitRating error: ${e.message} (code: ${e.errorCode})', name: 'RatingsRepositoryImpl');
      return Left(ServerFailure(
        message: e.message ?? 'Failed to submit rating',
        errorCode: e.errorCode,
      ));
    } catch (e) {
      log('submitRating unexpected error: $e', name: 'RatingsRepositoryImpl');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PendingRatingTrip>>> getPendingRatings() async {
    try {
      final list = await _remoteDataSource.getPendingRatings(token: _token);
      return Right(list);
    } on ServerException catch (e) {
      log('getPendingRatings error: ${e.message}', name: 'RatingsRepositoryImpl');
      return Left(ServerFailure(
        message: e.message ?? 'Failed to get pending ratings',
        errorCode: e.errorCode,
      ));
    } catch (e) {
      log('getPendingRatings unexpected error: $e', name: 'RatingsRepositoryImpl');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MyRatingsPage>> getMyRatings({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final pageData = await _remoteDataSource.getMyRatings(
        token: _token,
        page: page,
        perPage: perPage,
      );
      return Right(pageData);
    } on ServerException catch (e) {
      log('getMyRatings error: ${e.message}', name: 'RatingsRepositoryImpl');
      return Left(ServerFailure(
        message: e.message ?? 'Failed to get my ratings',
        errorCode: e.errorCode,
      ));
    } catch (e) {
      log('getMyRatings unexpected error: $e', name: 'RatingsRepositoryImpl');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DriverRatingsPage>> getDriverRatings({
    required int driverId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final pageData = await _remoteDataSource.getDriverRatings(
        driverId: driverId,
        token: _token,
        page: page,
        perPage: perPage,
      );
      return Right(pageData);
    } on ServerException catch (e) {
      log('getDriverRatings error: ${e.message}', name: 'RatingsRepositoryImpl');
      return Left(ServerFailure(
        message: e.message ?? 'Failed to get driver ratings',
        errorCode: e.errorCode,
      ));
    } catch (e) {
      log('getDriverRatings unexpected error: $e', name: 'RatingsRepositoryImpl');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
