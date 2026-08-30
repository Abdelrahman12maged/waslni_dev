import 'dart:developer';

import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/network/api_client.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/error/exceptions.dart';
import 'package:car_app/features/trips/data/datasources/trips_remote_datasource.dart';
import 'package:car_app/features/trips/data/models/offer_model.dart';
import 'package:car_app/features/trips/data/models/trip_model.dart';

/// Concrete implementation of [TripsRemoteDataSource].
/// Depends ONLY on [ApiClient] — no DioHelper, no CacheHelper.
class TripsRemoteDataSourceImpl implements TripsRemoteDataSource {
  final ApiClient _client;

  const TripsRemoteDataSourceImpl(this._client);

  // ─── Helper for flexible trip list parsing ─────────────────────────────
  List<TripModel> _parseTripsList(dynamic rawData) {
    List list = [];
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      if (rawData['trips'] is List) {
        list = rawData['trips'] as List;
      } else if (rawData['similar_trips'] is List) {
        list = rawData['similar_trips'] as List;
      } else if (rawData['data'] is List) {
        list = rawData['data'] as List;
      } else if (rawData['data'] is Map) {
        final d = rawData['data'] as Map;
        if (d['trips'] is List) {
          list = d['trips'] as List;
        } else if (d['similar_trips'] is List) {
          list = d['similar_trips'] as List;
        }
      } else if (rawData['result'] is List) {
        list = rawData['result'] as List;
      }
    }

    final results = <TripModel>[];
    for (final item in list) {
      if (item is Map) {
        try {
          final map = Map<String, dynamic>.from(item);
          final parsed = TripModel.fromJson(map);
          results.add(parsed);
        } catch (e) {
          log('FAILED_IN_PARSE_TRIPS_LIST: $e, item=$item',
              name: 'TripsRemoteDataSource');
        }
      }
    }
    return results;
  }

  // ─── Passenger Trips ──────────────────────────────────────────────────────

  @override
  Future<List<TripModel>> getPassengerTrips(
      int passengerId, String token) async {
    final result = await _client.get(
      url: ApiEndpoints.tripsByType,
      token: token,
      query: {'passenger_id': passengerId},
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) => _parseTripsList(response.data),
    );
  }

  // ─── Driver Trips ─────────────────────────────────────────────────────────

  @override
  Future<List<TripModel>> getDriverTrips(int driverId, String token) async {
    final result = await _client.get(
      url: ApiEndpoints.tripsByType,
      token: token,
      query: {'driver_id': driverId},
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) => _parseTripsList(response.data),
    );
  }

  // ─── Nearby Trips ─────────────────────────────────────────────────────────

  @override
  Future<List<TripModel>> getTripsNearMe(double lat, double lng,
      String creationType, String radius, String status, String token,
      {String? onGoingStatus, String? type, String? date}) async {
    final query = <String, dynamic>{
      'latitude': lat,
      'longitude': lng,
      'creation_type': creationType,
      'radius': radius,
      'status': status,
    };
    if (onGoingStatus != null && onGoingStatus.isNotEmpty) {
      query['on_going_status'] = onGoingStatus;
    }
    if (type != null && type.isNotEmpty) {
      query['type'] = type;
    }

    final result = await _client.get(
      url: ApiEndpoints.tripsNearMe,
      token: token,
      query: query,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) => _parseTripsList(response.data),
    );
  }

  // ─── Offers ───────────────────────────────────────────────────────────────

  @override
  Future<List<OfferModel>> getOffersByTrip(int tripId, String token) async {
    final result = await _client.get(
      url: '${ApiEndpoints.getOffers}$tripId',
      token: token,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        final rawData = response.data;
        List list = [];
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map) {
          final map = Map<String, dynamic>.from(rawData);
          final raw = map['offer'] ?? map['offers'] ?? map['data'];
          if (raw is List) {
            list = raw;
          } else if (map['data'] is Map) {
            final dataMap = Map<String, dynamic>.from(map['data']);
            if (dataMap['offer'] is List) {
              list = dataMap['offer'] as List;
            } else if (dataMap['offers'] is List) {
              list = dataMap['offers'] as List;
            }
          }
        }
        final results = <OfferModel>[];
        for (final item in list) {
          if (item is Map) {
            try {
              results.add(OfferModel.fromJson(Map<String, dynamic>.from(item)));
            } catch (e, st) {
              log('Failed to parse offer item: $e\n$st',
                  name: 'TripsRemoteDataSource');
            }
          }
        }
        return results;
      },
    );
  }

  // ─── Change Offer Status ──────────────────────────────────────────────────

  @override
  Future<void> changeOfferStatus(
    int offerId,
    String status,
    int userId,
    String token,
  ) async {
    final result = await _client.get(
      url: '${ApiEndpoints.changeOfferStatus}$offerId',
      token: token,
      query: {'status': status, 'user_id': userId},
    );

    result.fold(
      (failure) => throw ServerException(failure.message),
      (response) => log(response.data.toString(), name: 'changeOfferStatus'),
    );
  }

  // ─── Make Offer ───────────────────────────────────────────────────────────

  @override
  Future<void> makeOffer(Map<String, dynamic> offerData, String token) async {
    final result = await _client.post(
      url: ApiEndpoints.createOffer,
      token: token,
      data: offerData,
    );

    result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        final rawData = response.data;
        log('makeOffer response data: $rawData', name: 'makeOffer');
        if (rawData is Map<String, dynamic>) {
          final status = rawData['status'];
          final success = rawData['success'];
          final isStatusFalse = status == false ||
              status == 0 ||
              status?.toString().toLowerCase() == 'error' ||
              status?.toString().toLowerCase() == 'false';
          final isSuccessFalse = success == false ||
              success == 0 ||
              success?.toString().toLowerCase() == 'error' ||
              success?.toString().toLowerCase() == 'false';

          if (isStatusFalse ||
              isSuccessFalse ||
              rawData.containsKey('error') ||
              rawData.containsKey('error_code')) {
            final msg = rawData['message']?.toString() ??
                rawData['error']?.toString() ??
                rawData['msg']?.toString() ??
                'فشل تقديم العرض';
            throw ServerException(msg);
          }
        }
      },
    );
  }

  // ─── Change Trip Status ───────────────────────────────────────────────────

  @override
  Future<void> changeTripStatus(int tripId, String status, String token,
      {String? onGoingStatus, String? reason}) async {
    final Map<String, dynamic> query = {'status': status};
    if (onGoingStatus != null && onGoingStatus.isNotEmpty) {
      query['on_going_status'] = onGoingStatus;
    }
    if (reason != null && reason.isNotEmpty) {
      query['reason'] = reason;
      query['cancellation_reason'] = reason;
    }

    final result = await _client.get(
      url: '${ApiEndpoints.changeTripStatus}$tripId',
      token: token,
      query: query,
    );

    result.fold(
      (failure) => throw ServerException(failure.message),
      (response) => log(response.data.toString(), name: 'changeTripStatus'),
    );
  }

  // ─── Create Trip ──────────────────────────────────────────────────────────

  @override
  Future<TripModel> createTrip(
      Map<String, dynamic> tripData, String token) async {
    final result = await _client.post(
      url: ApiEndpoints.createTrip,
      token: token,
      data: tripData,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        final rawData = response.data;
        log('createTrip response data: $rawData', name: 'createTrip');

        Map<String, dynamic>? tripJson;
        if (rawData is Map<String, dynamic>) {
          if (rawData['trip'] is Map<String, dynamic>) {
            tripJson = rawData['trip'] as Map<String, dynamic>;
          } else if (rawData['data'] is Map<String, dynamic>) {
            final dataObj = rawData['data'] as Map<String, dynamic>;
            tripJson = (dataObj['trip'] is Map<String, dynamic>)
                ? dataObj['trip'] as Map<String, dynamic>
                : dataObj;
          } else if (rawData.containsKey('id') ||
              rawData.containsKey('from_latitude')) {
            tripJson = rawData;
          }
        }

        if (tripJson == null) {
          String? msg;
          String? errorCode;
          if (rawData is Map<String, dynamic>) {
            errorCode = rawData['error_code']?.toString();
            if (rawData['error'] != null) {
              final err = rawData['error'];
              if (err is Map) {
                msg = err.values
                    .map((v) => v is List ? v.join(', ') : v.toString())
                    .join('\n');
              } else {
                msg = err.toString();
              }
            } else if (rawData['message'] != null) {
              msg = rawData['message'].toString();
            }
          }
          throw ServerException(
              msg ?? 'فشل إنشاء الرحلة: استجابة السيرفر غير متوقعة', errorCode);
        }
        return TripModel.fromJson(tripJson);
      },
    );
  }

  // ─── Get Trip Details ─────────────────────────────────────────────────────

  @override
  Future<TripModel> getTripDetails(int tripId, String token) async {
    final result = await _client.get(
      url: ApiEndpoints.tripDetails,
      token: token,
      query: {'id': tripId},
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        final data = response.data;
        Map<String, dynamic>? tripMap;
        if (data is Map) {
          if (data['trip'] is Map) {
            tripMap = Map<String, dynamic>.from(data['trip']);
          } else if (data['data'] is Map) {
            final d = data['data'] as Map;
            tripMap = d['trip'] is Map
                ? Map<String, dynamic>.from(d['trip'])
                : Map<String, dynamic>.from(d);
          } else {
            tripMap = Map<String, dynamic>.from(data);
          }
        }
        if (tripMap == null) throw const ServerException('Trip not found');
        return TripModel.fromJson(tripMap);
      },
    );
  }

  // ─── Change Passenger Status ──────────────────────────────────────────────

  @override
  Future<void> changePassengerStatus(int tripId, int inCar, String token,
      {String? passState}) async {
    final Map<String, dynamic> query = {};
    if (passState != null && passState.isNotEmpty) {
      query['on_going_status'] = passState;
      query['pass_state'] = passState;
      query['status'] = passState;
    }

    final result = await _client.get(
      url: '${ApiEndpoints.passengerInCarStatus}$tripId/$inCar',
      token: token,
      query: query.isNotEmpty ? query : null,
    );

    result.fold(
      (failure) => throw ServerException(failure.message),
      (response) =>
          log(response.data.toString(), name: 'changePassengerStatus'),
    );
  }

  // ─── Subscribe Trip ───────────────────────────────────────────────────────

  @override
  Future<void> subscribeTrip(int tripId, String token, {int seats = 1}) async {
    final result = await _client.post(
      url: ApiEndpoints.subscribeTrip,
      token: token,
      query: {
        'trip_id': tripId,
        'seats': seats,
      },
      data: {},
    );

    result.fold(
      (failure) => throw ServerException(failure.message),
      (response) => log(response.data.toString(), name: 'subscribeTrip'),
    );
  }

  // ─── Nearby Shared Trips ──────────────────────────────────────────────────

  @override
  Future<List<TripModel>> getNearbySharedTrips({
    required double fromLat,
    required double fromLng,
    double? toLat,
    double? toLng,
    String? tripDatetime,
    double originRadiusKm = 2.0,
    double destinationRadiusKm = 2.0,
    double timeWindowHours = 1.0,
    required String token,
  }) async {
    // Build query params — to_lat/to_lng and trip_datetime are optional
    final query = <String, dynamic>{
      'from_latitude': fromLat,
      'from_longitude': fromLng,
      'origin_radius_km': originRadiusKm,
      'destination_radius_km': destinationRadiusKm,
      'time_window_hours': timeWindowHours,
    };
    if (toLat != null && toLng != null) {
      query['to_latitude'] = toLat;
      query['to_longitude'] = toLng;
    }
    if (tripDatetime != null && tripDatetime.isNotEmpty) {
      query['trip_datetime'] = tripDatetime;
    }

    try {
      log('SEARCH_SHARED_TRIPS_REQUEST: url=${ApiEndpoints.nearbySharedTrips}, query=$query',
          name: 'NearbySharedTrips');
      final result = await _client.get(
        url: ApiEndpoints.nearbySharedTrips,
        token: token,
        query: query,
      );

      return result.fold(
        (failure) {
          log('SEARCH_SHARED_TRIPS_FAILURE: ${failure.message}',
              name: 'NearbySharedTrips');
          throw ServerException(failure.message);
        },
        (response) {
          final rawData = response.data;
          log('SEARCH_SHARED_TRIPS_RAW_RESPONSE: $rawData',
              name: 'NearbySharedTrips');

          // Parse from `similar_trips` or `trips` or `data`
          List list = [];
          if (rawData is Map) {
            if (rawData['similar_trips'] is List) {
              list = rawData['similar_trips'] as List;
            } else if (rawData['trips'] is List) {
              list = rawData['trips'] as List;
            } else if (rawData['data'] is List) {
              list = rawData['data'] as List;
            } else if (rawData['data'] is Map) {
              final d = rawData['data'] as Map;
              if (d['similar_trips'] is List) {
                list = d['similar_trips'] as List;
              } else if (d['trips'] is List) {
                list = d['trips'] as List;
              }
            }
          } else if (rawData is List) {
            list = rawData;
          }

          final results = <TripModel>[];
          for (final item in list) {
            if (item is Map) {
              try {
                final map = Map<String, dynamic>.from(item);
                log('SEARCH_SHARED_TRIP_ITEM: id=${map['id']}, match_distance_origin_km=${map['match_distance_origin_km']}, distance=${map['distance']}, item_keys=${map.keys.toList()}',
                    name: 'NearbySharedTrips');
                final parsed = TripModel.fromJson(map);
                results.add(parsed);
              } catch (e) {
                log('FAILED_TO_PARSE_NEARBY_TRIP: $e, item=$item',
                    name: 'getNearbySharedTrips');
              }
            }
          }
          return results;
        },
      );
    } catch (e) {
      // ── Fallback: backend endpoint not yet active ─────────────────────────
      // If the new endpoint is not deployed yet (404 / network error),
      // fall back silently to the old getTripsNearMe endpoint.
      log('nearbySharedTrips endpoint unavailable, falling back to getTripsNearMe. Error: $e',
          name: 'getNearbySharedTrips');

      final fallbackResult = await _client.get(
        url: ApiEndpoints.tripsNearMe,
        token: token,
        query: {
          'latitude': fromLat,
          'longitude': fromLng,
          'creation_type': 'passenger',
          'radius': '5000',
          'status': 'accepted',
          'on_going_status': 'pending',
          'type': 'shared',
        },
      );

      return fallbackResult.fold(
        (failure) {
          log('SEARCH_SHARED_TRIPS_FALLBACK_FAILURE: ${failure.message}',
              name: 'NearbySharedTrips');
          throw ServerException(failure.message);
        },
        (response) {
          log('SEARCH_SHARED_TRIPS_FALLBACK_RAW_RESPONSE: ${response.data}',
              name: 'NearbySharedTrips');
          return _parseTripsList(response.data);
        },
      );
    }
  }
}
