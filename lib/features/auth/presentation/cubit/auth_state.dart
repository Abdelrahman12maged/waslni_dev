import 'dart:io';
import 'package:car_app/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class DriverImagePickedSuccess extends AuthState {
  final File file;
  const DriverImagePickedSuccess(this.file);
  @override
  List<Object?> get props => [file];
}

class DriverImagePickedFailure extends AuthState {
  final String message;
  final String? errorCode;
  const DriverImagePickedFailure(this.message, {this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
}

class ProfileImagePickedSuccess extends AuthState {
  final File file;
  const ProfileImagePickedSuccess(this.file);
  @override
  List<Object?> get props => [file];
}

class ProfileImagePickedFailure extends AuthState {
  final String message;
  final String? errorCode;
  const ProfileImagePickedFailure(this.message, {this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
}

class DriverLicenseImagePickedSuccess extends AuthState {
  final File file;
  const DriverLicenseImagePickedSuccess(this.file);
  @override
  List<Object?> get props => [file];
}

class DriverCarInsideImagePickedSuccess extends AuthState {
  final File file;
  const DriverCarInsideImagePickedSuccess(this.file);
  @override
  List<Object?> get props => [file];
}

class DriverCarOutsideImagePickedSuccess extends AuthState {
  final File file;
  const DriverCarOutsideImagePickedSuccess(this.file);
  @override
  List<Object?> get props => [file];
}

class DriverInfoImagePickedFailure extends AuthState {
  final String message;
  final String? errorCode;
  const DriverInfoImagePickedFailure(this.message, {this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
}

class DriverDocumentPickedSuccess extends AuthState {
  final String type;
  final File file;
  const DriverDocumentPickedSuccess(this.type, this.file);
  @override
  List<Object?> get props => [type, file.path];
}

class DriverDocumentRemoved extends AuthState {
  final String type;
  const DriverDocumentRemoved(this.type);
  @override
  List<Object?> get props => [type];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

// ─── UI-only states (no business data) ───────────────────────────────────────

class PasswordVisibilityChanged extends AuthState {
  final bool isHidden;
  const PasswordVisibilityChanged(this.isHidden);
  @override
  List<Object?> get props => [isHidden];
}

class UserTypeChanged extends AuthState {
  final bool isPassenger;
  const UserTypeChanged(this.isPassenger);
  @override
  List<Object?> get props => [isPassenger];
}

class GenderChanged extends AuthState {
  final bool isMale;
  const GenderChanged(this.isMale);
  @override
  List<Object?> get props => [isMale];
}

class RememberMeChanged extends AuthState {
  final bool value;
  const RememberMeChanged(this.value);
  @override
  List<Object?> get props => [value];
}

// ─── Login States ─────────────────────────────────────────────────────────────

class LoginLoading extends AuthState {
  const LoginLoading();
}

class LoginSuccess extends AuthState {
  final UserEntity user;
  const LoginSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class LoginFailure extends AuthState {
  final String message;
  final String? errorCode;
  const LoginFailure(this.message, {this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
}

// ─── Sign-Up States ───────────────────────────────────────────────────────────

class SignUpLoading extends AuthState {
  const SignUpLoading();
}

class SignUpSuccess extends AuthState {
  final UserEntity user;
  const SignUpSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class SignUpFailure extends AuthState {
  final String message;
  final String? errorCode;
  const SignUpFailure(this.message, {this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
}

// ─── Verification States ──────────────────────────────────────────────────────

class VerificationCodeLoading extends AuthState {
  const VerificationCodeLoading();
}

class VerificationCodeSuccess extends AuthState {
  final String message;
  const VerificationCodeSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class VerificationCodeFailure extends AuthState {
  final String message;
  final String? errorCode;
  const VerificationCodeFailure(this.message, {this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
}

class ResendCodeLoading extends AuthState {
  const ResendCodeLoading();
}

class ResendCodeSuccess extends AuthState {
  final String message;
  const ResendCodeSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ResendCodeFailure extends AuthState {
  final String message;
  final String? errorCode;
  const ResendCodeFailure(this.message, {this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
}

// ─── Reset Password States ────────────────────────────────────────────────────

class ResetPasswordLoading extends AuthState {
  const ResetPasswordLoading();
}

class ResetPasswordSuccess extends AuthState {
  final String message;
  const ResetPasswordSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ResetPasswordFailure extends AuthState {
  final String message;
  final String? errorCode;
  const ResetPasswordFailure(this.message, {this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
}
