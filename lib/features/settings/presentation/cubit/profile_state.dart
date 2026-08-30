import 'package:car_app/features/settings/domain/entities/user_profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final UserProfile userProfile;
  ProfileSuccess(this.userProfile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {}

class ProfileUpdateError extends ProfileState {
  final String message;
  ProfileUpdateError(this.message);
}
