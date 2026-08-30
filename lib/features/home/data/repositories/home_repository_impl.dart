import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/network/api_client.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/home/data/models/nearby_trip_model.dart';
import 'package:car_app/features/home/domain/entities/driver_trips_summary.dart';
import 'package:car_app/features/home/domain/entities/nearby_trip.dart';
import 'package:car_app/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _client;
  final LocalStorage _storage;

  const HomeRepositoryImpl({
    required ApiClient client,
    required LocalStorage storage,
  })  : _client = client,
        _storage = storage;

  String get _token => _storage.read(key: 'usertoken')?.toString() ?? '';

  @override
  Future<Either<Failure, List<NearbyTrip>>> getNearbyTrips({
    double? lat,
    double? lng,
    String? creationType,
    int? radius,
    String? status,
  }) async {
    final result = await _client.get(
      url: 'api/trips/nearme',
      token: _token,
      query: {
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
        if (creationType != null) 'creation_type': creationType,
        if (radius != null) 'radius': radius.toString(),
        if (status != null) 'status': status,
      },
    );

    return result.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (response) {
        final trips = (response.data['trips'] as List? ?? [])
            .map((e) => NearbyTripModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(trips);
      },
    );
  }

  @override
  Future<Either<Failure, DriverTripsSummary>> getDriverTripsTotals({
    required int driverId,
  }) async {
    final result = await _client.get(
      url: 'api/trips/get-totals',
      token: _token,
      query: {'driver_id': driverId},
    );

    return result.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (response) {
        final raw = response.data;
        final Map<String, dynamic> data =
            raw is Map<String, dynamic> ? raw : {};
        return Right(DriverTripsSummary(
          openCount: 0,
          acceptedCount: (data['accepted'] as num? ?? data['current'] as num? ?? 0).toInt(),
          completedCount: (data['completed'] as num? ?? 0).toInt(),
          suspendedCount: (data['suspended'] as num? ?? 0).toInt(),
          canceledCount: (data['canceled'] as num? ?? data['cancelled'] as num? ?? 0).toInt(),
          closedCount: (data['closed'] as num? ?? 0).toInt(),
        ));
      },
    );
  }
}
