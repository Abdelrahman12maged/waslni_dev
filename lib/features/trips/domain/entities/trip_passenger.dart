/// Represents a passenger who has joined a shared trip.
/// Parsed from the API's `passengers` array on a trip response.
class TripPassenger {
  final int id;
  final String name;

  /// Primary phone (field names vary: `mobile`, `phone`).
  final String? phone;

  /// Profile photo URL.
  final String? photo;

  /// Number of seats this passenger requested.
  final int seats;

  /// Booking / subscription status (e.g. 'pending', 'accepted', 'rejected').
  final String status;

  /// Whether the passenger is currently in the car (picked up).
  final bool inCar;

  /// FCM token for push notifications.
  final String? fcmToken;

  const TripPassenger({
    required this.id,
    required this.name,
    this.phone,
    this.photo,
    required this.seats,
    required this.status,
    this.inCar = false,
    this.fcmToken,
  });

  factory TripPassenger.fromMap(Map<String, dynamic> map) {
    // Passenger data may be nested under a 'passenger' or 'user' key
    // or flat at the top level — handle both.
    final inner = map['passenger'] is Map<String, dynamic>
        ? map['passenger'] as Map<String, dynamic>
        : map['user'] is Map<String, dynamic>
            ? map['user'] as Map<String, dynamic>
            : map;

    // The API returns pivot data (seats, in_car) inside a nested 'pivot' object.
    // e.g. passengers[n].pivot.seats = number of seats this passenger booked.
    final pivotRaw = map['pivot'];
    final pivot = pivotRaw is Map<String, dynamic>
        ? pivotRaw
        : (pivotRaw is Map ? Map<String, dynamic>.from(pivotRaw) : null);

    // seats priority: pivot.seats → map['seats'] → fallback 1
    final rawSeats = pivot?['seats'] ?? map['seats'] ?? inner['seats'] ?? 1;

    // in_car priority: pivot.in_car → map['in_car'] → map['inCar']
    final rawInCar = pivot?['in_car'] ?? map['in_car'] ?? map['inCar'];

    final rawPhoto = inner['profile_picture_url'] ??
        map['profile_picture_url'] ??
        inner['profile_picture'] ??
        map['profile_picture'] ??
        inner['photo'] ??
        map['photo'] ??
        inner['image'] ??
        map['image'] ??
        inner['avatar'] ??
        map['avatar'];

    return TripPassenger(
      id: _parseInt(inner['id'] ?? map['id']),
      name: inner['name']?.toString() ?? map['name']?.toString() ?? '',
      phone: inner['mobile']?.toString() ??
          inner['phone']?.toString() ??
          map['mobile']?.toString() ??
          map['phone']?.toString(),
      photo: rawPhoto?.toString(),
      seats: _parseInt(rawSeats),
      status: pivot?['status']?.toString() ?? map['status']?.toString() ?? 'pending',
      inCar: rawInCar == true || rawInCar == 1 || rawInCar == '1',
      fcmToken: inner['fcm_token']?.toString() ?? map['fcm_token']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'mobile': phone,
        'phone': phone,
        'photo': photo,
        'seats': seats,
        'status': status,
        'in_car': inCar,
        'fcm_token': fcmToken,
      };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
