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
