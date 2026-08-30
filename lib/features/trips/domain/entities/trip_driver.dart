import 'package:car_app/features/trips/domain/entities/trip_car.dart';

/// Represents a driver attached to a trip.
/// Parsed from the API's `driver` or `creator` nested object.
///
/// Note: `latitude` / `longitude` fields are live tracking data returned
/// by the server on some refreshed trip responses. They are nullable and
/// should not be cached.
class TripDriver {
  final int id;
  final String name;

  /// Primary phone (field names vary: `mobile`, `phone`).
  final String? phone;

  /// Profile photo URL.
  final String? photo;

  /// FCM token for push notifications (backend use only — not displayed in UI).
  final String? fcmToken;

  /// Driver rating (e.g. "4.8").
  final String? rating;

  /// Driver average rating as double (e.g. 4.8).
  final double? ratingAvg;

  /// Total count of ratings received by this driver.
  final int? ratingsCount;

  /// The car assigned to this driver for this trip.
  final TripCar? car;

  /// Live latitude — only present on refreshed trip details responses.
  final double? latitude;

  /// Live longitude — only present on refreshed trip details responses.
  final double? longitude;

  /// Total completed trips count for this driver (e.g. 42).
  final int? tripsCount;

  const TripDriver({
    required this.id,
    required this.name,
    this.phone,
    this.photo,
    this.fcmToken,
    this.rating,
    this.ratingAvg,
    this.ratingsCount,
    this.car,
    this.latitude,
    this.longitude,
    this.tripsCount,
  });

  factory TripDriver.fromMap(Map<String, dynamic> map) {
    // Parse car — may come as `map['car']` (object), `map['car']` (list), or flat fields
    TripCar? parsedCar;
    final rawCar = map['car'];
    if (rawCar is Map) {
      parsedCar = TripCar.fromMap(Map<String, dynamic>.from(rawCar));
    } else if (rawCar is List && rawCar.isNotEmpty) {
      final firstCar = rawCar.first;
      if (firstCar is Map) {
        parsedCar = TripCar.fromMap(Map<String, dynamic>.from(firstCar));
      }
    }

    // If car object is null or missing model/type, check flat driver fields
    if (parsedCar == null || (parsedCar.type.isEmpty && parsedCar.model.isEmpty)) {
      final hasCarFields = map.containsKey('car_type_text') ||
          map.containsKey('car_model_text') ||
          map.containsKey('car_plate_text') ||
          map.containsKey('car_type') ||
          map.containsKey('car_model') ||
          map.containsKey('plate_number');
      if (hasCarFields) {
        parsedCar = TripCar.fromMap(map);
      }
    }

    // Latitude / longitude — multiple field name variants across endpoints
    final lat = _parseDoubleOpt(map['latitude'] ?? map['lat']);
    final lng = _parseDoubleOpt(map['longitude'] ?? map['lng']);

    final inner = map['user'] is Map<String, dynamic>
        ? map['user'] as Map<String, dynamic>
        : (map['driver'] is Map<String, dynamic>
            ? map['driver'] as Map<String, dynamic>
            : (map['creator'] is Map<String, dynamic>
                ? map['creator'] as Map<String, dynamic>
                : (map['passenger'] is Map<String, dynamic>
                    ? map['passenger'] as Map<String, dynamic>
                    : map)));

    final rawPhoto = inner['profile_picture_url'] ??
        map['profile_picture_url'] ??
        inner['profile_picture'] ??
        map['profile_picture'] ??
        inner['photo'] ??
        map['photo'] ??
        inner['image'] ??
        map['image'] ??
        inner['avatar'] ??
        map['avatar'] ??
        inner['personal_photo'] ??
        map['personal_photo'] ??
        inner['driver_photo'] ??
        map['driver_photo'] ??
        inner['picture'] ??
        map['picture'];

    final rawRatingAvg = _parseDoubleOpt(
        map['rating_avg'] ?? inner['rating_avg'] ?? map['rating'] ?? inner['rating']);
    final rawRatingsCount = _parseIntOpt(
        map['ratings_count'] ?? inner['ratings_count'] ?? map['rating_count'] ?? inner['rating_count']);

    return TripDriver(
      id: _parseInt(map['id'] ?? inner['id']),
      name: (map['name'] ?? inner['name'])?.toString() ?? '',
      phone: (map['mobile'] ?? inner['mobile'] ?? map['phone'] ?? inner['phone'])?.toString(),
      photo: rawPhoto?.toString(),
      fcmToken: map['fcm_token']?.toString(),
      rating: map['rating']?.toString() ?? rawRatingAvg?.toString(),
      ratingAvg: rawRatingAvg,
      ratingsCount: rawRatingsCount,
      car: parsedCar,
      latitude: lat,
      longitude: lng,
      tripsCount: _parseIntOpt(map['trips_count'] ?? map['tripsCount']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'mobile': phone,
        'phone': phone,
        'photo': photo,
        'fcm_token': fcmToken,
        'rating': rating,
        'rating_avg': ratingAvg,
        'ratings_count': ratingsCount,
        'car': car?.toMap(),
        'latitude': latitude,
        'longitude': longitude,
        'trips_count': tripsCount,
      };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _parseIntOpt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _parseDoubleOpt(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
