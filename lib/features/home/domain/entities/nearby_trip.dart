/// Represents a trip near the user's current location.
class NearbyTrip {
  final int id;
  final String fromLocationName;
  final String toLocationName;
  final String tripDatetime;
  final String type;
  final String status;
  final String distance;
  final String minimumPrice;
  final String maximumPrice;
  final int numberOfSeats;
  final String? genderPreference;
  final int? userId;
  final int? driverId;

  const NearbyTrip({
    required this.id,
    required this.fromLocationName,
    required this.toLocationName,
    required this.tripDatetime,
    required this.type,
    required this.status,
    required this.distance,
    required this.minimumPrice,
    required this.maximumPrice,
    required this.numberOfSeats,
    this.genderPreference,
    this.userId,
    this.driverId,
  });

  String get dateOnly {
    final spaceIdx = tripDatetime.indexOf(' ');
    return spaceIdx >= 0 ? tripDatetime.substring(0, spaceIdx) : tripDatetime;
  }

  String get timeOnly {
    final spaceIdx = tripDatetime.indexOf(' ');
    return spaceIdx >= 0 ? tripDatetime.substring(spaceIdx) : '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_location_name': fromLocationName,
      'to_location_name': toLocationName,
      'trip_datetime': tripDatetime,
      'type': type,
      'status': status,
      'distance': distance,
      'minimum_price': minimumPrice,
      'maximum_price': maximumPrice,
      'number_of_seats': numberOfSeats,
      'gender_preference': genderPreference,
      'user_id': userId,
      'driver_id': driverId,
    };
  }
}
