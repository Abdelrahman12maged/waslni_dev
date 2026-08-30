import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:dartz/dartz.dart';
import 'package:car_app/core/error/failures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Abstract contract for all Google Maps / Location operations.
/// This is the ONLY interface that the Presentation and Trips layers
/// are allowed to depend on — zero direct Geolocator/Geocoding imports
/// outside the Data layer.
abstract class MapService {
  /// Returns the device's current GPS position.
  /// Requests permission if not already granted.
  Future<Either<Failure, LatLng>> getCurrentLocation();

  /// Converts [latLng] coordinates into a human-readable [LocationResult].
  Future<Either<Failure, LocationResult>> getAddressFromLatLng(LatLng latLng);

  /// Returns autocomplete suggestions for [query] using the Places API.
  Future<Either<Failure, List<PlaceSuggestion>>> searchPlaces(String query);

  /// Resolves a [placeId] to its exact [LocationResult] (coordinates + address).
  Future<Either<Failure, LocationResult>> getPlaceDetails(String placeId);

  /// Calculates an encoded polyline between [from] and [to].
  /// Returns a list of [LatLng] points representing the route.
  Future<Either<Failure, List<LatLng>>> getRoutePolyline({
    required LatLng from,
    required LatLng to,
  });
}
