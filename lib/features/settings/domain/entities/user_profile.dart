import 'package:equatable/equatable.dart';
import 'package:car_app/features/trips/domain/entities/trip_car.dart';

class UserProfile extends Equatable {
  final int? id;
  final String? name;
  final String? email;
  final String? gender;
  final String? mobile;
  final String? lang;
  final String? photo;
  final String? userType;
  final TripCar? car;

  const UserProfile({
    this.id,
    this.name,
    this.email,
    this.gender,
    this.mobile,
    this.lang,
    this.photo,
    this.userType,
    this.car,
  });

  factory UserProfile.fromMap(Map<String, dynamic> rawJson) {
    final Map<String, dynamic> uMap = rawJson['user'] is Map
        ? Map<String, dynamic>.from(rawJson['user'] as Map)
        : (rawJson['data'] is Map
            ? Map<String, dynamic>.from(rawJson['data'] as Map)
            : (rawJson['trip'] is Map
                ? Map<String, dynamic>.from(rawJson['trip'] as Map)
                : rawJson));

    final rawPhoto = uMap['profile_picture_url'] ??
        rawJson['profile_picture_url'] ??
        uMap['profile_picture'] ??
        rawJson['profile_picture'] ??
        uMap['photo'] ??
        rawJson['photo'] ??
        uMap['image'] ??
        uMap['avatar'] ??
        uMap['picture'] ??
        uMap['personal_picture'] ??
        rawJson['personal_picture'] ??
        rawJson['image'];
    final photoStr = rawPhoto?.toString().trim();
    final photo = (photoStr == null || photoStr.isEmpty || photoStr.toLowerCase() == 'null' || photoStr.toLowerCase() == 'undefined')
        ? null
        : photoStr;

    TripCar? car;
    final rawCar = uMap['car'] ??
        rawJson['car'] ??
        rawJson['user']?['car'] ??
        rawJson['data']?['car'];
    if (rawCar is Map) {
      car = TripCar.fromMap(Map<String, dynamic>.from(rawCar));
    } else if (rawCar is List && rawCar.isNotEmpty && rawCar[0] is Map) {
      car = TripCar.fromMap(Map<String, dynamic>.from(rawCar[0]));
    }

    final id = uMap['id'] is int
        ? uMap['id'] as int
        : int.tryParse(uMap['id']?.toString() ?? '');

    return UserProfile(
      id: id,
      name: uMap['name']?.toString() ?? rawJson['name']?.toString(),
      email: uMap['email']?.toString() ?? rawJson['email']?.toString(),
      gender: uMap['gender']?.toString() ?? rawJson['gender']?.toString(),
      mobile: uMap['mobile']?.toString() ?? rawJson['mobile']?.toString(),
      lang: uMap['lang']?.toString() ?? rawJson['lang']?.toString(),
      photo: photo,
      userType: uMap['user_type']?.toString() ?? rawJson['user_type']?.toString(),
      car: car,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        gender,
        mobile,
        lang,
        photo,
        userType,
        car,
      ];
}
