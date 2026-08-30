import 'dart:developer';

import 'package:car_app/core/error/exceptions.dart';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/trips/data/datasources/trips_remote_datasource.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

/// Concrete implementation of [TripsRepository].
/// Converts [ServerException] → [Either<Failure, T>].
/// Reads the auth token from [LocalStorage] — no CacheHelper.
class TripsRepositoryImpl implements TripsRepository {
  final TripsRemoteDataSource _remoteDataSource;
  final LocalStorage _storage;

  const TripsRepositoryImpl({
    required TripsRemoteDataSource remoteDataSource,
    required LocalStorage storage,
  })  : _remoteDataSource = remoteDataSource,
        _storage = storage;

  // ─── Helper ───────────────────────────────────────────────────────────────

  String get _token {
    return _storage.read(key: 'usertoken')?.toString() ?? '';
  }

  // ─── Passenger Trips ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Trip>>> getPassengerTrips(
      {required int passengerId}) async {
    try {
      final trips =
          await _remoteDataSource.getPassengerTrips(passengerId, _token);
      return Right(trips);
    } on ServerException catch (e) {
      log(e.toString(), name: 'TripsRepositoryImpl.getPassengerTrips');
      return Left(ServerFailure(
          message: e.message ?? 'Failed to fetch passenger trips',
          errorCode: e.errorCode));
    }
  }

  // ─── Driver Trips ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Trip>>> getDriverTrips(
      {required int driverId}) async {
    try {
      final trips = await _remoteDataSource.getDriverTrips(driverId, _token);
      return Right(trips);
    } on ServerException catch (e) {
      log(e.toString(), name: 'TripsRepositoryImpl.getDriverTrips');
      return Left(
          ServerFailure(message: e.message ?? 'Failed to fetch driver trips',
              errorCode: e.errorCode));
    }
  }
  // ─── Nearby Trips ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Trip>>> getTripsNearMe({
    required double lat,
    required double lng,
    required String creationType,
    required String radius,
    required String status,
    String? onGoingStatus,
    String? type,
    String? date,
  }) async {
    try {
      final trips = await _remoteDataSource.getTripsNearMe(
        lat,
        lng,
        creationType,
        radius,
        status,
        _token,
        onGoingStatus: onGoingStatus,
        type: type,
        date: date,
      );
      return Right(trips);
    } on ServerException catch (e) {
      log(e.toString(), name: 'TripsRepositoryImpl.getTripsNearMe');
      return Left(
          ServerFailure(message: e.message ?? 'Failed to fetch nearby trips',
              errorCode: e.errorCode));
    }
  }

  // ─── Offers ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Offer>>> getOffersByTrip(
      {required int tripId}) async {
    try {
      final offers = await _remoteDataSource.getOffersByTrip(tripId, _token);
      return Right(offers);
    } on ServerException catch (e) {
      log(e.toString(), name: 'TripsRepositoryImpl.getOffersByTrip');
      return Left(
          ServerFailure(message: e.message ?? 'Failed to fetch offers',
              errorCode: e.errorCode));
    }
  }

  // ─── Change Offer Status ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> changeOfferStatus({
    required int offerId,
    required String status,
    required int userId,
  }) async {
    try {
      await _remoteDataSource.changeOfferStatus(
          offerId, status, userId, _token);
      return const Right(null);
    } on ServerException catch (e) {
      log(e.toString(), name: 'TripsRepositoryImpl.changeOfferStatus');
      return Left(
          ServerFailure(message: e.message ?? 'Failed to change offer status',
              errorCode: e.errorCode));
    }
  }

  @override
  Future<Either<Failure, void>> makeOffer({
    required Map<String, dynamic> offerData,
  }) async {
    try {
      await _remoteDataSource.makeOffer(offerData, _token);
      return const Right(null);
    } on ServerException catch (e) {
      log(e.toString(), name: 'TripsRepositoryImpl.makeOffer');
      return Left(ServerFailure(message: e.message ?? 'Failed to make offer',
          errorCode: e.errorCode));
    }
  }

  // ─── Change Trip Status ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> changeTripStatus({
    required int tripId,
    required String status,
    String? onGoingStatus,
    String? reason,
  }) async {
    try {
      await _remoteDataSource.changeTripStatus(tripId, status, _token,
          onGoingStatus: onGoingStatus, reason: reason);
      return const Right(null);
    } on ServerException catch (e) {
      log(e.toString(), name: 'TripsRepositoryImpl.changeTripStatus');
      return Left(
          ServerFailure(message: e.message ?? 'Failed to change trip status',
              errorCode: e.errorCode));
    }
  }

  // ─── Create Trip ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Trip>> createTrip(
      {required Map<String, dynamic> tripData}) async {
    try {
      final trip = await _remoteDataSource.createTrip(tripData, _token);
      return Right(trip);
    } on ServerException catch (e) {
      log(e.toString(), name: 'TripsRepositoryImpl.createTrip');
      return Left(ServerFailure(message: e.message ?? 'Failed to create trip',
          errorCode: e.errorCode));
    }
  }

  // ─── Trip Details ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Trip>> getTripDetails({required int tripId}) async {
    try {
      final trip = await _remoteDataSource.getTripDetails(tripId, _token);
      return Right(trip);
    } on ServerException catch (e) {
      log(e.toString(), name: 'TripsRepositoryImpl.getTripDetails');
      return Left(
          ServerFailure(message: e.message ?? 'Failed to fetch trip details',
              errorCode: e.errorCode));
    }
  }

  @override
  Future<Either<Failure, void>> changePassengerStatus({
    required int tripId,
    required int inCar,
    String? passState,
  }) async {
    try {
      await _remoteDataSource.changePassengerStatus(
        tripId,
        inCar,
        _token,
        passState: passState,
      );
      return const Right(null);
    } on ServerException catch (e) {
      log(e.toString(), name: 'TripsRepositoryImpl.changePassengerStatus');
      return Left(ServerFailure(
          message: e.message ?? 'Failed to change passenger status',
          errorCode: e.errorCode));
    }
  }

  @override
  Future<Either<Failure, void>> subscribeTrip({
    required int tripId,
    int seats = 1,
  }) async {
    try {
      await _remoteDataSource.subscribeTrip(tripId, _token, seats: seats);
      return const Right(null);
    } on ServerException catch (e) {
      log(e.toString(), name: 'TripsRepositoryImpl.subscribeTrip');
      return Left(
        ServerFailure(
          message: e.message ?? 'Failed to subscribe to trip',
          errorCode: e.errorCode,
        ),
      );
    }
  }

  // ─── Nearby Shared Trips ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Trip>>> getNearbySharedTrips({
    required double fromLat,
    required double fromLng,
    double? toLat,
    double? toLng,
    String? tripDatetime,
    double originRadiusKm = 2.0,
    double destinationRadiusKm = 2.0,
    double timeWindowHours = 1.0,
  }) async {
    try {
      final trips = await _remoteDataSource.getNearbySharedTrips(
        fromLat: fromLat,
        fromLng: fromLng,
        toLat: toLat,
        toLng: toLng,
        tripDatetime: tripDatetime,
        originRadiusKm: originRadiusKm,
        destinationRadiusKm: destinationRadiusKm,
        timeWindowHours: timeWindowHours,
        token: _token,
      );
      return Right(trips);
    } on ServerException catch (e) {
      log(e.toString(), name: 'TripsRepositoryImpl.getNearbySharedTrips');
      return Left(ServerFailure(
        message: e.message ?? 'Failed to fetch nearby shared trips',
        errorCode: e.errorCode,
      ));
    }
  }
}


