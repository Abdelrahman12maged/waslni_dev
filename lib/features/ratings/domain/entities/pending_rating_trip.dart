import 'package:car_app/features/trips/domain/entities/trip_driver.dart';

/// Represents a trip awaiting rating by the current passenger.
/// Returned by `GET /api/ratings/pending`.
class PendingRatingTrip {
  final int tripId;
  final String fromLocationName;
  final String toLocationName;
  final DateTime? tripDatetime;
  final String status;
  final TripDriver driver;

  const PendingRatingTrip({
    required this.tripId,
    required this.fromLocationName,
    required this.toLocationName,
    this.tripDatetime,
    required this.status,
    required this.driver,
  });

  factory PendingRatingTrip.fromMap(Map<String, dynamic> map) {
    final driverMap = map['driver'] is Map
        ? Map<String, dynamic>.from(map['driver'] as Map)
        : <String, dynamic>{};

    return PendingRatingTrip(
      tripId: _parseInt(map['trip_id'] ?? map['id']),
      fromLocationName: map['from_location_name']?.toString() ?? '',
      toLocationName: map['to_location_name']?.toString() ?? '',
      tripDatetime: _parseDate(map['trip_datetime'] ?? map['datetime']),
      status: map['status']?.toString() ?? '',
      driver: TripDriver.fromMap(driverMap),
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
