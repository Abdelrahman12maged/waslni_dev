import 'package:car_app/features/trips/domain/entities/trip_driver.dart';

/// Represents an individual rating record.
/// Can represent a rating submitted, a rating in "My Ratings" (includes driver),
/// or a rating in "Driver Ratings" (includes passenger info).
class Rating {
  final int id;
  final int tripId;
  final int driverId;
  final int passengerId;
  final int stars;
  final String? comment;
  final bool isEditable;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TripDriver? driver;
  final String? passengerName;

  const Rating({
    required this.id,
    required this.tripId,
    required this.driverId,
    required this.passengerId,
    required this.stars,
    this.comment,
    required this.isEditable,
    this.createdAt,
    this.updatedAt,
    this.driver,
    this.passengerName,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    TripDriver? parsedDriver;
    if (map['driver'] is Map) {
      parsedDriver = TripDriver.fromMap(Map<String, dynamic>.from(map['driver'] as Map));
    }

    String? passengerName;
    int parsedPassengerId = _parseInt(map['passenger_id']);
    if (map['passenger'] is Map) {
      final pMap = map['passenger'] as Map;
      passengerName = pMap['name']?.toString();
      if (parsedPassengerId == 0) {
        parsedPassengerId = _parseInt(pMap['id']);
      }
    }

    return Rating(
      id: _parseInt(map['id']),
      tripId: _parseInt(map['trip_id']),
      driverId: _parseInt(map['driver_id']),
      passengerId: parsedPassengerId,
      stars: _parseInt(map['stars']),
      comment: map['comment']?.toString(),
      isEditable: map['is_editable'] == true,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
      driver: parsedDriver,
      passengerName: passengerName,
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}
