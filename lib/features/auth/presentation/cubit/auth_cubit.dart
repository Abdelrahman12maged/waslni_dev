import 'dart:io';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/driver_documents/domain/usecases/upload_driver_documents_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_app/features/auth/domain/usecases/check_verification_code_usecase.dart';
import 'package:car_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:car_app/features/auth/domain/usecases/resend_verification_code_usecase.dart';
import 'package:car_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:car_app/features/auth/domain/usecases/signup_usecase.dart';
import 'package:car_app/features/auth/domain/usecases/update_device_token_usecase.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:car_app/core/services/home_widget_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final CheckVerificationCodeUseCase checkVerificationCodeUseCase;
  final ResendVerificationCodeUseCase resendVerificationCodeUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final UpdateDeviceTokenUseCase updateDeviceTokenUseCase;
  final UploadDriverDocumentsUseCase uploadDriverDocumentsUseCase;
  final LocalStorage localStorage;

  AuthCubit({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.checkVerificationCodeUseCase,
    required this.resendVerificationCodeUseCase,
    required this.resetPasswordUseCase,
    required this.updateDeviceTokenUseCase,
    required this.uploadDriverDocumentsUseCase,
    required this.localStorage,
  }) : super(const AuthInitial()) {
    rememberMe = localStorage.read(key: 'remember_me') as bool? ?? false;
  }

  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  // ─── UI State Toggles ───────────────────────────────────────────────────────

  bool isPasswordHidden = true;
  bool isPassenger = true;
  bool isMale = true;
  bool rememberMe = false;

  File? profileImage;
  File? driverImage;
  File? driverLicenseImage;
  File? driverCarOutsideImage;
  File? driverCarInsideImage;

  // ─── KYC Document Files ───────────────────────────────────────────────────
  File? nationalIdFile;
  File? criminalRecordFile;
  File? vehicleLicenseDocFile;

  final _imagePicker = ImagePicker();

  Future<void> getProfileImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        profileImage = File(pickedFile.path);
        emit(ProfileImagePickedSuccess(profileImage!));
      } else {
        emit(const ProfileImagePickedFailure('no_profile_image_selected', errorCode: 'no_profile_image_selected'));
      }
    } catch (e) {
      emit(ProfileImagePickedFailure(e.toString(), errorCode: 'image_pick_error'));
    }
  }

  Future<void> getDriverImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        driverImage = File(pickedFile.path);
        emit(DriverImagePickedSuccess(driverImage!));
      } else {
        emit(const DriverImagePickedFailure('no_driver_image_selected', errorCode: 'no_driver_image_selected'));
      }
    } catch (e) {
      emit(DriverImagePickedFailure(e.toString(), errorCode: 'image_pick_error'));
    }
  }

  Future<void> getDriverInfoImages(int imageNum, {ImageSource source = ImageSource.gallery}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (imageNum == 0) {
          driverLicenseImage = file;
          emit(DriverLicenseImagePickedSuccess(file));
        } else if (imageNum == 1) {
          driverCarInsideImage = file;
          emit(DriverCarInsideImagePickedSuccess(file));
        } else if (imageNum == 2) {
          driverCarOutsideImage = file;
          emit(DriverCarOutsideImagePickedSuccess(file));
        }
      } else {
        emit(const DriverInfoImagePickedFailure('no_image_selected', errorCode: 'no_image_selected'));
      }
    } catch (e) {
      emit(DriverInfoImagePickedFailure(e.toString(), errorCode: 'image_pick_error'));
    }
  }

  // ─── KYC Document Pickers ─────────────────────────────────────────────────

  Future<void> pickDriverDocument(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty || result.files.single.path == null) return;
      final file = File(result.files.single.path!);

      switch (type) {
        case 'national_id':
          nationalIdFile = file;
          emit(DriverDocumentPickedSuccess(type, file));
          break;
        case 'criminal_record':
          criminalRecordFile = file;
          emit(DriverDocumentPickedSuccess(type, file));
          break;
        case 'vehicle_license':
          vehicleLicenseDocFile = file;
          emit(DriverDocumentPickedSuccess(type, file));
          break;
      }
    } catch (e) {
      emit(DriverInfoImagePickedFailure(e.toString(), errorCode: 'document_pick_error'));
    }
  }

  void removeDriverDocument(String type) {
    switch (type) {
      case 'national_id':
        nationalIdFile = null;
        break;
      case 'criminal_record':
        criminalRecordFile = null;
        break;
      case 'vehicle_license':
        vehicleLicenseDocFile = null;
        break;
    }
    emit(DriverDocumentRemoved(type));
  }

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    emit(PasswordVisibilityChanged(isPasswordHidden));
  }

  void setUserType(bool passenger) {
    isPassenger = passenger;
    emit(UserTypeChanged(passenger));
  }

  void setGender(bool male) {
    isMale = male;
    emit(GenderChanged(male));
  }

  void setRememberMe(bool value) {
    rememberMe = value;
    if (!value) {
      localStorage.saveBool(key: 'remember_me', value: false);
      localStorage.remove(key: 'saved_mobile');
      localStorage.remove(key: 'saved_password');
    }
    emit(RememberMeChanged(value));
  }

  // ─── Login ──────────────────────────────────────────────────────────────────

  Future<void> login({
    required String mobile,
    required String password,
  }) async {
    emit(const LoginLoading());

    final result = await loginUseCase(
      LoginParams(mobile: mobile, password: password),
    );

    result.fold(
      (failure) => emit(LoginFailure(
        failure.message,
        errorCode: failure is ServerFailure ? failure.errorCode : null,
      )),
      (user) async {
        if (rememberMe) {
          await localStorage.saveBool(key: 'remember_me', value: true);
          await localStorage.saveString(key: 'saved_mobile', value: mobile);
          await localStorage.saveString(key: 'saved_password', value: password);
        } else {
          await localStorage.saveBool(key: 'remember_me', value: false);
          await localStorage.remove(key: 'saved_mobile');
          await localStorage.remove(key: 'saved_password');
        }

        try {
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null && fcmToken.isNotEmpty) {
            await updateDeviceTokenUseCase(fcmToken);
            await FirebaseFirestore.instance.collection('users').doc(user.id.toString()).set({
              'fcm_token': fcmToken,
              'device_token': fcmToken,
              'name': user.name,
              'mobile': user.mobile,
              'photo': user.photo,
              'updated_at': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (_) {}

        // Upload any pending KYC documents picked during registration
        await _uploadPendingKycDocuments();

        // ── Update Home Widget after login ──────────────────────────────
        try {
          await HomeWidgetService.updateAfterLogin(
            userName: user.name,
            userType: user.userType == 'driver' ? 'driver' : 'passenger',
          );
        } catch (_) {}

        emit(LoginSuccess(user));
      },
    );
  }

  // ─── Sign Up ────────────────────────────────────────────────────────────────

  Future<void> signUp({
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
    emit(const SignUpLoading());

    final effectiveProfilePic = profilePicture ?? profileImage ?? driverImage;

    final result = await signUpUseCase(
      SignUpParams(
        name: name,
        mobile: mobile,
        password: password,
        gender: gender,
        userType: userType,
        language: language,
        profilePicture: effectiveProfilePic,
        carType: carType,
        seats: seats,
        carModel: carModel,
        plateNumber: plateNumber,
        drivingLic: drivingLic,
        insidePicture: insidePicture,
        outsidePicture: outsidePicture,
      ),
    );

    result.fold(
      (failure) => emit(SignUpFailure(
        failure.message,
        errorCode: failure is ServerFailure ? failure.errorCode : null,
      )),
      (user) async {
        // If driver selected KYC documents during signup:
        final hasKycFiles = nationalIdFile != null ||
            criminalRecordFile != null ||
            vehicleLicenseDocFile != null;

        if (hasKycFiles) {
          if (user.token != null && user.token!.isNotEmpty) {
            // Direct token available: upload documents right now
            await _uploadPendingKycDocuments();
          } else {
            // Token will be available after OTP verification/login: persist file paths
            _savePendingKycPathsToStorage();
          }
        }

        emit(SignUpSuccess(user));
      },
    );
  }

  // ─── KYC Document Upload Helpers ──────────────────────────────────────────

  void _savePendingKycPathsToStorage() {
    if (nationalIdFile != null) {
      localStorage.saveString(
          key: 'pending_kyc_national_id', value: nationalIdFile!.path);
    }
    if (criminalRecordFile != null) {
      localStorage.saveString(
          key: 'pending_kyc_criminal_record',
          value: criminalRecordFile!.path);
    }
    if (vehicleLicenseDocFile != null) {
      localStorage.saveString(
          key: 'pending_kyc_vehicle_license',
          value: vehicleLicenseDocFile!.path);
    }
  }

  Future<void> _uploadPendingKycDocuments() async {
    try {
      File? nid = nationalIdFile;
      File? cr = criminalRecordFile;
      File? vl = vehicleLicenseDocFile;

      if (nid == null) {
        final path = localStorage.read(key: 'pending_kyc_national_id') as String?;
        if (path != null && path.isNotEmpty) nid = File(path);
      }
      if (cr == null) {
        final path =
            localStorage.read(key: 'pending_kyc_criminal_record') as String?;
        if (path != null && path.isNotEmpty) cr = File(path);
      }
      if (vl == null) {
        final path =
            localStorage.read(key: 'pending_kyc_vehicle_license') as String?;
        if (path != null && path.isNotEmpty) vl = File(path);
      }

      debugPrint('🚀 [AuthSignUpKYC] Auto-uploading registration documents:');
      debugPrint('   - National ID: ${nid?.path ?? "NONE"}');
      debugPrint('   - Criminal Record: ${cr?.path ?? "NONE"}');
      debugPrint('   - Vehicle License: ${vl?.path ?? "NONE"}');

      if (nid == null && cr == null && vl == null) {
        debugPrint('⚠️ [AuthSignUpKYC] No KYC files to upload.');
        return;
      }

      final result = await uploadDriverDocumentsUseCase(
        UploadDocumentsParams(
          nationalId: nid,
          criminalRecord: cr,
          vehicleLicense: vl,
        ),
      );

      result.fold(
        (failure) => debugPrint('❌ [AuthSignUpKYC] Registration KYC upload failed: ${failure.message}'),
        (status) => debugPrint('✅ [AuthSignUpKYC] Registration KYC upload success! Account isActive=${status.account.isActive}'),
      );

      // Cleanup pending paths from storage & memory
      localStorage.remove(key: 'pending_kyc_national_id');
      localStorage.remove(key: 'pending_kyc_criminal_record');
      localStorage.remove(key: 'pending_kyc_vehicle_license');
      nationalIdFile = null;
      criminalRecordFile = null;
      vehicleLicenseDocFile = null;
    } catch (e) {
      debugPrint('💥 [AuthSignUpKYC] Error in _uploadPendingKycDocuments: $e');
    }
  }

  // ─── Verification Code ──────────────────────────────────────────────────────

  Future<void> checkVerificationCode({
    required String mobile,
    required String code,
  }) async {
    emit(const VerificationCodeLoading());

    final result = await checkVerificationCodeUseCase(
      CheckVerificationCodeParams(mobile: mobile, code: code),
    );

    result.fold(
      (failure) => emit(VerificationCodeFailure(
        failure.message,
        errorCode: failure is ServerFailure ? failure.errorCode : null,
      )),
      (message) => emit(VerificationCodeSuccess(message)),
    );
  }

  Future<void> resendVerificationCode(String mobile) async {
    emit(const ResendCodeLoading());

    final result = await resendVerificationCodeUseCase(mobile);

    result.fold(
      (failure) => emit(ResendCodeFailure(
        failure.message,
        errorCode: failure is ServerFailure ? failure.errorCode : null,
      )),
      (message) => emit(ResendCodeSuccess(message)),
    );
  }

  // ─── Reset Password ─────────────────────────────────────────────────────────

  Future<void> resetPassword({
    required String mobile,
    required String password,
    required String code,
  }) async {
    emit(const ResetPasswordLoading());

    final result = await resetPasswordUseCase(
      ResetPasswordParams(mobile: mobile, password: password, code: code),
    );

    result.fold(
      (failure) => emit(ResetPasswordFailure(
        failure.message,
        errorCode: failure is ServerFailure ? failure.errorCode : null,
      )),
      (message) => emit(ResetPasswordSuccess(message)),
    );
  }
}
