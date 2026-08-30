import 'package:car_app/features/settings/domain/entities/user_profile.dart';
import 'package:car_app/features/trips/domain/entities/trip_car.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    super.id,
    super.name,
    super.email,
    super.gender,
    super.mobile,
    super.lang,
    super.photo,
    super.userType,
    super.car,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> rawJson) {
    final Map<String, dynamic> uMap = rawJson['user'] is Map
        ? Map<String, dynamic>.from(rawJson['user'] as Map)
        : (rawJson['data'] is Map
            ? Map<String, dynamic>.from(rawJson['data'] as Map)
            : (rawJson['trip'] is Map
                ? Map<String, dynamic>.from(rawJson['trip'] as Map)
                : rawJson));

    // Photo
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

    // Car
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

    return UserProfileModel(
      id: id,
      name: uMap['name']?.toString(),
      email: uMap['email']?.toString(),
      gender: uMap['gender']?.toString(),
      mobile: uMap['mobile']?.toString(),
      lang: uMap['lang']?.toString(),
      photo: photo,
      userType: uMap['user_type']?.toString() ?? uMap['userType']?.toString(),
      car: car,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'mobile': mobile,
      'lang': lang,
      'photo': photo,
      'profile_picture_url': photo,
      'user_type': userType,
      'car': car != null
          ? {
              'car_type': car!.type,
              'car_model': car!.model,
              'seats': car!.seats,
              'plate_number': car!.plateNumber,
              'color': car!.color,
              'year': car!.year,
              'inside_picture': car!.insidePicture,
              'outside_picture': car!.outsidePicture,
            }
          : null,
    };
  }
}
