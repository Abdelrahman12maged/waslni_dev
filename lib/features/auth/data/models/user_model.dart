import 'package:car_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.mobile,
    required super.lang,
    required super.userType,
    required super.gender,
    super.emailVerifiedAt,
    super.token,
    super.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    final Map<String, dynamic> userJson = json['user'] != null 
        ? Map<String, dynamic>.from(json['user']) 
        : (json['data'] is Map
            ? Map<String, dynamic>.from(json['data'])
            : Map<String, dynamic>.from(json));

    final rawPhoto = userJson['profile_picture_url'] ??
        json['profile_picture_url'] ??
        userJson['profile_picture'] ??
        json['profile_picture'] ??
        userJson['photo'] ??
        json['photo'] ??
        userJson['image'] ??
        json['image'] ??
        userJson['avatar'] ??
        json['avatar'];
        
    return UserModel(
      id: userJson['id'] is int ? userJson['id'] : int.tryParse(userJson['id']?.toString() ?? '') ?? 0,
      name: userJson['name'] ?? '',
      mobile: userJson['mobile'] ?? '',
      lang: userJson['lang'] ?? 'en',
      userType: userJson['user_type'] ?? '',
      gender: userJson['gender'] ?? 'male',
      emailVerifiedAt: userJson['email_verified_at'],
      token: token ?? json['access_token'] ?? json['token']?.toString(),
      photo: rawPhoto?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'lang': lang,
      'user_type': userType,
      'gender': gender,
      'email_verified_at': emailVerifiedAt,
      'access_token': token,
      'photo': photo,
      'profile_picture_url': photo,
    };
  }
}
