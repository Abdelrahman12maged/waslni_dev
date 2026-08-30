import 'dart:io';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/usecases/usecase.dart';
import 'package:car_app/features/auth/domain/entities/user_entity.dart';
import 'package:car_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUp(
      name: params.name,
      mobile: params.mobile,
      password: params.password,
      gender: params.gender,
      userType: params.userType,
      language: params.language,
      profilePicture: params.profilePicture,
      carType: params.carType,
      seats: params.seats,
      carModel: params.carModel,
      plateNumber: params.plateNumber,
      drivingLic: params.drivingLic,
      insidePicture: params.insidePicture,
      outsidePicture: params.outsidePicture,
    );
  }
}

class SignUpParams extends Equatable {
  final String name;
  final String mobile;
  final String password;
  final String gender;
  final String userType;
  final String language;
  final File? profilePicture;
  final String? carType;
  final String? seats;
  final String? carModel;
  final String? plateNumber;
  final File? drivingLic;
  final File? insidePicture;
  final File? outsidePicture;

  const SignUpParams({
    required this.name,
    required this.mobile,
    required this.password,
    required this.gender,
    required this.userType,
    required this.language,
    this.profilePicture,
    this.carType,
    this.seats,
    this.carModel,
    this.plateNumber,
    this.drivingLic,
    this.insidePicture,
    this.outsidePicture,
  });

  @override
  List<Object?> get props => [
        name,
        mobile,
        password,
        gender,
        userType,
        language,
        profilePicture,
        carType,
        seats,
        carModel,
        plateNumber,
        drivingLic,
        insidePicture,
        outsidePicture,
      ];
}
