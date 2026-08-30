import 'package:car_app/features/home/domain/entities/nearby_trip.dart';

class NearbyTripModel extends NearbyTrip {
  const NearbyTripModel({
    required super.id,
    required super.fromLocationName,
    required super.toLocationName,
    required super.tripDatetime,
    required super.type,
    required super.status,
    required super.distance,
    required super.minimumPrice,
    required super.maximumPrice,
    required super.numberOfSeats,
    super.genderPreference,
    super.userId,
    super.driverId,
  });

  factory NearbyTripModel.fromJson(Map<String, dynamic> json) {
    return NearbyTripModel(
      id: json['id'] ?? 0,
      fromLocationName: json['from_location_name'] ?? 'Unknown',
      toLocationName: json['to_location_name'] ?? 'Unknown',
      tripDatetime: json['trip_datetime']?.toString() ?? '',
      type: json['type']?.toString() ?? 'private',
      status: json['status']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '0',
      minimumPrice: json['minimum_price']?.toString() ?? '0.00',
      maximumPrice: json['maximum_price']?.toString() ?? '0.00',
      numberOfSeats: json['number_of_seats'] ?? 0,
      genderPreference: json['gender_preference']?.toString(),
      userId: json['created_by'] != null 
          ? (json['created_by'] is int ? json['created_by'] : int.tryParse(json['created_by'].toString()))
          : (json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '')),
      driverId: json['driver_id'] is int ? json['driver_id'] : int.tryParse(json['driver_id']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
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
