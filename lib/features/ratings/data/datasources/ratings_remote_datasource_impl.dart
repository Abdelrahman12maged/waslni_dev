import 'dart:developer';

import 'package:car_app/core/error/exceptions.dart';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/network/api_client.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/features/ratings/data/datasources/ratings_remote_datasource.dart';
import 'package:car_app/features/ratings/domain/entities/driver_ratings_page.dart';
import 'package:car_app/features/ratings/domain/entities/my_ratings_page.dart';
import 'package:car_app/features/ratings/domain/entities/pending_rating_trip.dart';
import 'package:car_app/features/ratings/domain/entities/rating_result.dart';

class RatingsRemoteDataSourceImpl implements RatingsRemoteDataSource {
  final ApiClient _client;

  const RatingsRemoteDataSourceImpl(this._client);

  @override
  Future<RatingResult> submitRating({
    required int tripId,
    required int stars,
    String? comment,
    int? ratedUserId,
    required String token,
  }) async {
    final payload = <String, dynamic>{
      'trip_id': tripId,
      'stars': stars,
    };
    if (ratedUserId != null && ratedUserId > 0) {
      payload['rated_user_id'] = ratedUserId;
    }
    if (comment != null && comment.trim().isNotEmpty) {
      payload['comment'] = comment.trim();
    }

    // ── DEBUG: log full request ─────────────────────────────────────────────
    log('submitRating → POST ${ApiEndpoints.ratingsStore}', name: 'RatingsRemoteDataSource');
    log('submitRating → payload: $payload', name: 'RatingsRemoteDataSource');
    // ───────────────────────────────────────────────────────────────────────

    final result = await _client.post(
      url: ApiEndpoints.ratingsStore,
      token: token,
      data: payload,
    );

    return result.fold(
      (failure) {
        final errorCode = failure is ServerFailure ? failure.errorCode : null;
        final statusCode = failure is ServerFailure ? failure.statusCode : null;
        log('submitRating FAILED [$statusCode]: ${failure.message} (code: $errorCode)', name: 'RatingsRemoteDataSource');
        throw ServerException(failure.message, errorCode);
      },
      (response) {
        log('submitRating OK [${response.statusCode}]: ${response.data}', name: 'RatingsRemoteDataSource');
        Map<String, dynamic> data;
        if (response.data is Map<String, dynamic>) {
          data = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          data = Map<String, dynamic>.from(response.data as Map);
        } else {
          throw const ServerException('Invalid response format for submitRating');
        }
        // Safe parse — driver_rating may be absent in some API versions
        return RatingResult.fromMapSafe(data);
      },
    );
  }

  @override
  Future<List<PendingRatingTrip>> getPendingRatings({
    required String token,
  }) async {
    log('getPendingRatings → GET ${ApiEndpoints.ratingsPending}', name: 'RatingsRemoteDataSource');

    final result = await _client.get(
      url: ApiEndpoints.ratingsPending,
      token: token,
    );

    return result.fold(
      (failure) {
        final errorCode = failure is ServerFailure ? failure.errorCode : null;
        final statusCode = failure is ServerFailure ? failure.statusCode : null;
        log('getPendingRatings FAILED [$statusCode]: ${failure.message}', name: 'RatingsRemoteDataSource');
        throw ServerException(failure.message, errorCode);
      },
      (response) {
        log('getPendingRatings OK [${response.statusCode}]: ${response.data}', name: 'RatingsRemoteDataSource');
        final list = <PendingRatingTrip>[];
        final data = response.data;

        // Try all known response shapes: { trips: [...] }, { data: [...] }, or top-level []
        List? rawList;
        if (data is List) {
          rawList = data;
        } else if (data is Map) {
          rawList = data['trips'] as List? ??
              data['data'] as List? ??
              data['pending_trips'] as List? ??
              data['pending'] as List?;
        }

        if (rawList != null) {
          for (final item in rawList) {
            if (item is Map) {
              try {
                list.add(PendingRatingTrip.fromMap(Map<String, dynamic>.from(item)));
              } catch (e) {
                log('PendingRatingTrip.fromMap error for item: $item\nerror: $e', name: 'RatingsRemoteDataSource');
              }
            }
          }
        } else {
          log('getPendingRatings: unexpected response shape — data: $data', name: 'RatingsRemoteDataSource');
        }

        log('getPendingRatings: parsed ${list.length} trips', name: 'RatingsRemoteDataSource');
        return list;
      },
    );
  }

  @override
  Future<MyRatingsPage> getMyRatings({
    required String token,
    int page = 1,
    int perPage = 15,
  }) async {
    final result = await _client.get(
      url: ApiEndpoints.ratingsMine,
      token: token,
      query: {
        'page': page,
        'per_page': perPage,
      },
    );

    return result.fold(
      (failure) {
        final errorCode = failure is ServerFailure ? failure.errorCode : null;
        log('getMyRatings failed: ${failure.message}', name: 'RatingsRemoteDataSource');
        throw ServerException(failure.message, errorCode);
      },
      (response) {
        if (response.data is Map) {
          return MyRatingsPage.fromMap(Map<String, dynamic>.from(response.data as Map));
        }
        throw const ServerException('Invalid response format for getMyRatings');
      },
    );
  }

  @override
  Future<DriverRatingsPage> getDriverRatings({
    required int driverId,
    required String token,
    int page = 1,
    int perPage = 15,
  }) async {
    final result = await _client.get(
      url: ApiEndpoints.driverRatings(driverId),
      token: token,
      query: {
        'page': page,
        'per_page': perPage,
      },
    );

    return result.fold(
      (failure) {
        final errorCode = failure is ServerFailure ? failure.errorCode : null;
        log('getDriverRatings failed: ${failure.message}', name: 'RatingsRemoteDataSource');
        throw ServerException(failure.message, errorCode);
      },
      (response) {
        if (response.data is Map) {
          return DriverRatingsPage.fromMap(Map<String, dynamic>.from(response.data as Map));
        }
        throw const ServerException('Invalid response format for getDriverRatings');
      },
    );
  }
}
