import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String mobile;
  final String lang;
  final String userType;
  final String gender;
  final String? emailVerifiedAt;
  final String? token;
  final String? photo;

  const UserEntity({
    required this.id,
    required this.name,
    required this.mobile,
    required this.lang,
    required this.userType,
    required this.gender,
    this.emailVerifiedAt,
    this.token,
    this.photo,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        mobile,
        lang,
        userType,
        gender,
        emailVerifiedAt,
        token,
        photo,
      ];
}
