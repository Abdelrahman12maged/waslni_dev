import 'dart:io';
import 'package:car_app/core/error/exceptions.dart';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:car_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:car_app/features/auth/domain/entities/user_entity.dart';
import 'package:car_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final fcmToken = await localDataSource.getFcmToken() ?? '';
      final userModel = await remoteDataSource.login(
        mobile: mobile,
        password: password,
        fcmToken: fcmToken,
      );

      // Setup Firebase Auth & Firestore
      try {
        await remoteDataSource.firebaseSignUp(phoneNumber: mobile, password: password);
      } catch (signUpError) {
        // Fallback to sign in if registration fails (e.g. user already exists)
      }

      try {
        await remoteDataSource.firebaseSignIn(phoneNumber: mobile, password: password);
        final uid = remoteDataSource.firebaseUserUid;
        if (uid != null) {
          await remoteDataSource.firebaseSaveUser(
            uid: uid,
            name: userModel.name,
            phoneNumber: mobile,
            role: userModel.userType,
            uId: userModel.id,
          );
        }
      } catch (e) {
        // Firebase operations are non-blocking so PHP login can succeed
      }

      // Cache user locally
      await localDataSource.cacheUser(userModel, userModel.toJson());

      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error during login', errorCode: e.errorCode));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Cache error during login'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final userModel = await remoteDataSource.signUp(
        name: name,
        mobile: mobile,
        password: password,
        gender: gender,
        userType: userType,
        language: language,
        profilePicture: profilePicture,
        carType: carType,
        seats: seats,
        carModel: carModel,
        plateNumber: plateNumber,
        drivingLic: drivingLic,
        insidePicture: insidePicture,
        outsidePicture: outsidePicture,
      );

      // If token is present, cache user and setup Firebase directly
      if (userModel.token != null && userModel.token!.isNotEmpty) {
        try {
          await remoteDataSource.firebaseSignUp(phoneNumber: mobile, password: password);
        } catch (_) {}

        try {
          await remoteDataSource.firebaseSignIn(phoneNumber: mobile, password: password);
          final uid = remoteDataSource.firebaseUserUid;
          if (uid != null) {
            await remoteDataSource.firebaseSaveUser(
              uid: uid,
              name: userModel.name,
              phoneNumber: mobile,
              role: userModel.userType,
              uId: userModel.id,
            );
          }
        } catch (_) {}

        await localDataSource.cacheUser(userModel, userModel.toJson());
        return Right(userModel);
      } else {
        // If registration does not return token directly, perform automatic login to authenticate session
        return await login(mobile: mobile, password: password);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error during sign up', errorCode: e.errorCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> checkVerificationCode({
    required String mobile,
    required String code,
  }) async {
    try {
      final result = await remoteDataSource.checkVerificationCode(
        mobile: mobile,
        code: code,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error during verification code check', errorCode: e.errorCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resendVerificationCode({
    required String mobile,
  }) async {
    try {
      final result = await remoteDataSource.resendVerificationCode(mobile: mobile);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error during code resend', errorCode: e.errorCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    required String mobile,
    required String password,
    required String code,
  }) async {
    try {
      final result = await remoteDataSource.resetPassword(
        mobile: mobile,
        password: password,
        code: code,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error during password reset', errorCode: e.errorCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDeviceToken({
    required String fcmToken,
  }) async {
    try {
      final token = await localDataSource.getUserToken();
      if (token == null || token.isEmpty) {
        return const Left(CacheFailure(message: 'User is not authenticated'));
      }
      await remoteDataSource.updateDeviceToken(
        fcmToken: fcmToken,
        token: token,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to update device token', errorCode: e.errorCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
