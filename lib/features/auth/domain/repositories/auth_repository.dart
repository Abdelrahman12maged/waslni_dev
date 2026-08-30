import 'dart:io';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String mobile,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUp({
    required String name,
    required String mobile,
    required String password,
    required String gender,
    required String userType,
    required String language,
    File? profilePicture,
    String? carType,
    String? seats,
    String? carModel,
    String? plateNumber,
    File? drivingLic,
    File? insidePicture,
    File? outsidePicture,
  });

  Future<Either<Failure, String>> checkVerificationCode({
    required String mobile,
    required String code,
  });

  Future<Either<Failure, String>> resendVerificationCode({
    required String mobile,
  });

  Future<Either<Failure, String>> resetPassword({
    required String mobile,
    required String password,
    required String code,
  });

  Future<Either<Failure, void>> updateDeviceToken({
    required String fcmToken,
  });
}
