import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:car_app/core/error/exceptions.dart' as app_ex;
import 'package:car_app/features/auth/data/models/user_model.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String mobile,
    required String password,
    required String fcmToken,
  });

  Future<UserModel> signUp({
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

  Future<void> firebaseSignUp({
    required String phoneNumber,
    required String password,
  });

  Future<void> firebaseSignIn({
    required String phoneNumber,
    required String password,
  });

  Future<void> firebaseSaveUser({
    required String uid,
    required String name,
    required String phoneNumber,
    required String role,
    required int uId,
  });

  Future<String> checkVerificationCode({
    required String mobile,
    required String code,
  });

  Future<String> resendVerificationCode({
    required String mobile,
  });

  Future<String> resetPassword({
    required String mobile,
    required String password,
    required String code,
  });

  Future<void> updateDeviceToken({
    required String fcmToken,
    required String token,
  });

  String? get firebaseUserUid;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  String? get firebaseUserUid => firebaseAuth.currentUser?.uid;

  @override
  Future<UserModel> login({
    required String mobile,
    required String password,
    required String fcmToken,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {
          "mobile": mobile,
          "password": password,
          "fcm_token": fcmToken,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is! Map) {
          throw app_ex.ServerException(S.current.unexpectedServerResponse);
        }

        // 1. Check explicit failure flags
        if (responseData['success'] == false ||
            responseData['status'] == false ||
            responseData['status'] == 0 ||
            responseData['status'] == '0') {
          final errorMap = responseData['error'] ?? responseData['errors'];
          String errorMessage = responseData['message']?.toString() ?? S.current.invalidCredentialsDetailed;
          if (errorMap is Map) {
            final messages = errorMap.values
                .expand((v) => v is List ? v : [v])
                .join('\n');
            errorMessage = messages.isNotEmpty ? messages : errorMessage;
          } else if (errorMap is String && errorMap.isNotEmpty) {
            errorMessage = errorMap;
          } else if (errorMap is List && errorMap.isNotEmpty) {
            errorMessage = errorMap.join('\n');
          }
          throw app_ex.ServerException(errorMessage);
        }

        // 2. Check for token existence
        final token = responseData['access_token'] ??
            responseData['token'] ??
            (responseData['user'] is Map
                ? (responseData['user']['access_token'] ??
                    responseData['user']['token'])
                : null);

        final rawMsg = responseData['message']?.toString();
        final lowerMsg = rawMsg?.toLowerCase() ?? '';

        // If message indicates invalid credentials or no token was returned
        if (lowerMsg.contains('invalid') ||
            lowerMsg.contains('incorrect') ||
            lowerMsg.contains('unauthorized') ||
            lowerMsg.contains('not found') ||
            lowerMsg.contains('غير صحيح') ||
            lowerMsg.contains('خطأ') ||
            lowerMsg.contains('فشل') ||
            token == null ||
            token.toString().trim().isEmpty) {
          String userFriendlyMsg = rawMsg ?? S.current.invalidCredentialsDetailed;
          if (lowerMsg.contains('invalid login credentials') ||
              lowerMsg.contains('invalid credentials') ||
              lowerMsg.contains('unauthorized')) {
            userFriendlyMsg = S.current.invalidCredentialsDetailed;
          }
          throw app_ex.ServerException(userFriendlyMsg);
        }

        return UserModel.fromJson(
          Map<String, dynamic>.from(responseData),
          token: token.toString(),
        );
      } else {
        final msg = response.data is Map
            ? (response.data['message']?.toString() ?? response.data['error']?.toString())
            : null;
        throw app_ex.ServerException(msg ?? S.current.serverErrorDuringLogin);
      }
    } on DioException catch (e) {
      throw app_ex.ServerException(e.message ?? 'Dio error during login');
    } catch (e) {
      if (e is app_ex.ServerException) rethrow;
      throw app_ex.ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUp({
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
      dynamic requestData;

      if (userType == 'driver') {
        final Map<String, dynamic> map = {
          'name': name,
          'mobile': mobile,
          'password': password,
          'gender': gender,
          'user_type': 'driver',
          'lang': language,
          'car_type': carType,
          'seats': seats,
          'model': carModel,
          'plate_number': plateNumber,
        };

        if (profilePicture != null) {
          final fileName = profilePicture.path.split(RegExp(r'[/\\]')).last;
          final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
          map['profile_picture'] = await MultipartFile.fromFile(
            profilePicture.path,
            filename: fileName,
            contentType: MediaType('image', ext),
          );
        }

        if (drivingLic != null) {
          final fileName = drivingLic.path.split(RegExp(r'[/\\]')).last;
          final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
          map['driving_lic'] = await MultipartFile.fromFile(
            drivingLic.path,
            filename: fileName,
            contentType: MediaType('image', ext),
          );
        }

        if (insidePicture != null) {
          final fileName = insidePicture.path.split(RegExp(r'[/\\]')).last;
          final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
          map['inside_picture'] = await MultipartFile.fromFile(
            insidePicture.path,
            filename: fileName,
            contentType: MediaType('image', ext),
          );
        }

        if (outsidePicture != null) {
          final fileName = outsidePicture.path.split(RegExp(r'[/\\]')).last;
          final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
          map['outside_picture'] = await MultipartFile.fromFile(
            outsidePicture.path,
            filename: fileName,
            contentType: MediaType('image', ext),
          );
        }

        requestData = FormData.fromMap(map);
      } else {
        final Map<String, dynamic> map = {
          'name': name,
          'mobile': mobile,
          'password': password,
          'gender': gender,
          'user_type': userType,
          'lang': language,
        };

        if (profilePicture != null) {
          final fileName = profilePicture.path.split(RegExp(r'[/\\]')).last;
          final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
          map['profile_picture'] = await MultipartFile.fromFile(
            profilePicture.path,
            filename: fileName,
            contentType: MediaType('image', ext),
          );
        }

        requestData = FormData.fromMap(map);
      }

      final response = await dio.post(
        ApiEndpoints.register,
        data: requestData,
      );

      if (response.statusCode == 200 || response.data['status'] == 200) {
        final responseData = response.data;

        // Check for success: false — API returns 200 even on validation errors
        if (responseData['success'] == false) {
          final errorMap = responseData['error'];
          String errorMessage = 'Sign up failed';
          if (errorMap is Map) {
            // Flatten all error messages from e.g. {mobile: ["msg1"], name: ["msg2"]}
            final messages = errorMap.values
                .expand((v) => v is List ? v : [v])
                .join('\n');
            errorMessage = messages.isNotEmpty ? messages : errorMessage;
          } else if (errorMap is String) {
            errorMessage = errorMap;
          }
          throw app_ex.ServerException(errorMessage);
        }

        // Parse user on actual success
        if (responseData['data'] != null && responseData['user'] == null) {
          final merged = Map<String, dynamic>.from(responseData);
          merged['user'] = responseData['data'];
          return UserModel.fromJson(merged);
        }
        return UserModel.fromJson(responseData);
      } else {
        throw app_ex.ServerException(
            response.data['msg'] ?? response.data['message'] ?? 'Server error during sign up');
      }
    } on DioException catch (e) {
      throw app_ex.ServerException(e.message ?? 'Dio error during sign up');
    } catch (e) {
      if (e is app_ex.ServerException) rethrow;
      throw app_ex.ServerException(e.toString());
    }
  }

  @override
  Future<void> firebaseSignUp({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: '$phoneNumber@phone.com',
        password: password,
      );
    } catch (e) {
      throw app_ex.AppFirebaseException(e.toString());
    }
  }

  @override
  Future<void> firebaseSignIn({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: '$phoneNumber@phone.com',
        password: password,
      );
    } catch (e) {
      throw app_ex.AppFirebaseException(e.toString());
    }
  }

  @override
  Future<void> firebaseSaveUser({
    required String uid,
    required String name,
    required String phoneNumber,
    required String role,
    required int uId,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
      }
      final ref = firestore.collection('users');
      await ref.doc(uid).set({
        'phoneNumber': phoneNumber,
        'rool': role,
        'name': name,
        'u_id': uId,
      });
    } catch (e) {
      throw app_ex.AppFirebaseException(e.toString());
    }
  }

  @override
  Future<String> checkVerificationCode({
    required String mobile,
    required String code,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.checkVerificationCode,
        data: {
          'code': code,
          "mobile": mobile,
        },
      );

      if (response.data['status'] == 200) {
        return response.data['message'] ?? 'Verification successful';
      } else {
        throw app_ex.ServerException(
            response.data['message'] ?? 'Verification failed');
      }
    } on DioException catch (e) {
      throw app_ex.ServerException(
          e.message ?? 'Network error during code check');
    } catch (e) {
      if (e is app_ex.ServerException) rethrow;
      throw app_ex.ServerException(e.toString());
    }
  }

  @override
  Future<String> resendVerificationCode({
    required String mobile,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.resendVerificationCode,
        data: {
          "mobile": mobile,
        },
      );

      if (response.statusCode == 200) {
        return 'Verification Code Sent Successfully!';
      } else {
        throw const app_ex.ServerException(
            'Verification Code Not Sent. Ensure the number is valid.');
      }
    } on DioException catch (e) {
      throw app_ex.ServerException(
          e.message ?? 'Network error during resending code');
    } catch (e) {
      if (e is app_ex.ServerException) rethrow;
      throw app_ex.ServerException(e.toString());
    }
  }

  @override
  Future<String> resetPassword({
    required String mobile,
    required String password,
    required String code,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.resetPasswordWithCode,
        data: {
          'code': code,
          "mobile": mobile,
          "password": password,
        },
      );

      if (response.data['status'] == 200) {
        return response.data['message'] ?? 'Password reset successful';
      } else {
        throw app_ex.ServerException(
            response.data['message'] ?? 'Password reset failed');
      }
    } on DioException catch (e) {
      throw app_ex.ServerException(
          e.message ?? 'Network error during password reset');
    } catch (e) {
      if (e is app_ex.ServerException) rethrow;
      throw app_ex.ServerException(e.toString());
    }
  }

  @override
  Future<void> updateDeviceToken({
    required String fcmToken,
    required String token,
  }) async {
    try {
      await dio.post(
        ApiEndpoints.updateDeviceToken,
        data: {
          'fcm_token': fcmToken,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw app_ex.ServerException(
          e.message ?? 'Network error during device token update');
    } catch (e) {
      if (e is app_ex.ServerException) rethrow;
      throw app_ex.ServerException(e.toString());
    }
  }
}
