import 'dart:convert';
import 'dart:developer';

import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/utils/location_helper.dart';
import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;

/// Concrete implementation of [MapService].
/// All platform dependencies (geolocator, geocoding, Places API) are isolated here.
class MapServiceImpl implements MapService {
  final String _googleApiKey;

  const MapServiceImpl({required String googleApiKey})
      : _googleApiKey = googleApiKey;

  // ─────────────────────────────────────────────────────────────────────────
  // Current Location
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, LatLng>> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final location = loc.Location();
        final requested = await location.requestService();
        if (!requested) {
          return Left(
            ServerFailure(
              message: 'خدمات الموقع غير مفعلة. يرجى تفعيل GPS للمتابعة.',
            ),
          );
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Left(
            ServerFailure(
              message: 'تم رفض إذن الوصول إلى الموقع.',
            ),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Left(
          ServerFailure(
            message:
                'إذن الموقع مرفوض بشكل دائم. يرجى تفعيله من إعدادات الهاتف.',
          ),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return Right(LatLng(position.latitude, position.longitude));
    } catch (e) {
      log(e.toString(), name: 'MapServiceImpl.getCurrentLocation');
      return Left(ServerFailure(message: 'فشل الحصول على الموقع الحالي.'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reverse Geocoding (LatLng → Address)
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, LocationResult>> getAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final addressParts = [p.subLocality, p.street, p.locality]
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toList();

        final rawAddress = addressParts.isNotEmpty
            ? addressParts.join(', ')
            : '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';

        final address = cleanLocationName(rawAddress);

        return Right(LocationResult(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          address: address,
          subLocality: p.subLocality,
          street: p.street,
        ));
      }
    } catch (e) {
      log(e.toString(), name: 'MapServiceImpl.getAddressFromLatLng');
    }

    // Fallback gracefully to coordinates display if reverse geocoding is unavailable
    return Right(LocationResult(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      address: '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}',
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Places Autocomplete
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return Right([]);

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&key=$_googleApiKey'
        '&language=ar',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        log('searchPlaces status: ${json['status']}', name: 'searchPlaces');

        if (json['status'] == 'OK') {
          final predictions = (json['predictions'] as List? ?? []);
          final suggestions = predictions.map((p) {
            final structured = p['structured_formatting'] as Map<String, dynamic>? ?? {};
            return PlaceSuggestion(
              placeId: p['place_id'] as String,
              description: p['description'] as String,
              mainText: structured['main_text'] as String? ?? p['description'] as String,
              secondaryText: structured['secondary_text'] as String? ?? '',
            );
          }).toList();

          if (suggestions.isNotEmpty) {
            return Right(suggestions);
          }
        }
      }
    } catch (e) {
      log(e.toString(), name: 'MapServiceImpl.searchPlaces HTTP error');
    }

    // Fallback to Geocoding search for any worldwide query
    try {
      final locations = await Geocoding().locationFromAddress(query);
      if (locations.isNotEmpty) {
        final suggestions = locations.map((loc) {
          return PlaceSuggestion(
            placeId: 'geo:${loc.latitude},${loc.longitude}',
            description: query,
            mainText: query,
            secondaryText: '',
          );
        }).toList();
        return Right(suggestions);
      }
    } catch (e) {
      log(e.toString(), name: 'Geocoding fallback search error');
    }

    return Left(ServerFailure(message: 'لم يتم العثور على نتائج للبحث.'));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Place Details (placeId → LocationResult)
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, LocationResult>> getPlaceDetails(String placeId) async {
    // Handle fallback geocoding coordinates placeId
    if (placeId.startsWith('geo:')) {
      final coords = placeId.replaceFirst('geo:', '').split(',');
      if (coords.length == 2) {
        final lat = double.tryParse(coords[0]) ?? 0.0;
        final lng = double.tryParse(coords[1]) ?? 0.0;
        return Right(LocationResult(
          latitude: lat,
          longitude: lng,
          address: 'موقع محدد',
        ));
      }
    }

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry,formatted_address,name'
        '&key=$_googleApiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        return Left(ServerFailure(message: 'فشل الحصول على تفاصيل المكان.'));
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['status'] != 'OK') {
        return Left(ServerFailure(message: 'خطأ: ${json['status']}'));
      }

      final result = json['result'] as Map<String, dynamic>;
      final location = result['geometry']['location'] as Map<String, dynamic>;

      return Right(LocationResult(
        latitude: (location['lat'] as num).toDouble(),
        longitude: (location['lng'] as num).toDouble(),
        address: result['formatted_address'] as String? ?? result['name'] as String? ?? '',
      ));
    } catch (e) {
      log(e.toString(), name: 'MapServiceImpl.getPlaceDetails');
      return Left(ServerFailure(message: 'فشل تحميل تفاصيل المكان.'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Route Polyline (Directions API)
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<LatLng>>> getRoutePolyline({
    required LatLng from,
    required LatLng to,
  }) async {
    // 1. Try Google Routes API (New v2 Endpoint)
    if (_googleApiKey.isNotEmpty) {
      try {
        final routesV2Url = Uri.parse(
          'https://routes.googleapis.com/directions/v2:computeRoutes',
        );

        final v2Response = await http
            .post(
              routesV2Url,
              headers: {
                'Content-Type': 'application/json',
                'X-Goog-Api-Key': _googleApiKey,
                'X-Goog-FieldMask': 'routes.polyline.encodedPolyline',
              },
              body: jsonEncode({
                'origin': {
                  'location': {
                    'latLng': {
                      'latitude': from.latitude,
                      'longitude': from.longitude,
                    }
                  }
                },
                'destination': {
                  'location': {
                    'latLng': {
                      'latitude': to.latitude,
                      'longitude': to.longitude,
                    }
                  }
                },
                'travelMode': 'DRIVE',
              }),
            )
            .timeout(const Duration(seconds: 3))
            .catchError((_) => http.Response('', 408));

        if (v2Response.statusCode == 200) {
          final json = jsonDecode(v2Response.body) as Map<String, dynamic>;
          final routes = json['routes'] as List?;
          if (routes != null && routes.isNotEmpty) {
            final encodedPolyline =
                routes[0]['polyline']?['encodedPolyline'] as String?;
            if (encodedPolyline != null && encodedPolyline.isNotEmpty) {
              final points = _decodePolyline(encodedPolyline);
              if (points.isNotEmpty) {
                return Right(points);
              }
            }
          }
        }
      } catch (_) {}

      // 2. Try Google Directions API (Legacy Endpoint)
      try {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${from.latitude},${from.longitude}'
          '&destination=${to.latitude},${to.longitude}'
          '&mode=driving'
          '&key=$_googleApiKey',
        );

        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 3))
            .catchError((_) => http.Response('', 408));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          if (json['status'] == 'OK' && (json['routes'] as List).isNotEmpty) {
            final encodedPolyline =
                json['routes'][0]['overview_polyline']['points'] as String;
            final points = _decodePolyline(encodedPolyline);
            if (points.isNotEmpty) {
              return Right(points);
            }
          }
        }
      } catch (_) {}
    }

    // 3. High-speed OSRM Fallback (Guarantees real curved street routes matching the road network)
    try {
      final osrmUrl = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=polyline',
      );

      final osrmResponse = await http
          .get(osrmUrl)
          .timeout(const Duration(seconds: 5))
          .catchError((_) => http.Response('', 408));

      if (osrmResponse.statusCode == 200) {
        final json = jsonDecode(osrmResponse.body) as Map<String, dynamic>;
        if (json['code'] == 'Ok' && (json['routes'] as List).isNotEmpty) {
          final encodedPolyline = json['routes'][0]['geometry'] as String;
          final points = _decodePolyline(encodedPolyline);
          if (points.isNotEmpty) {
            log('Route successfully resolved via OSRM (${points.length} road curve points)',
                name: 'MapServiceImpl.getRoutePolyline');
            return Right(points);
          }
        }
      }
    } catch (e) {
      log('OSRM routing exception: $e',
          name: 'MapServiceImpl.getRoutePolyline');
    }

    return Left(ServerFailure(message: 'فشل الحصول على مسار الشارع.'));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    final len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
