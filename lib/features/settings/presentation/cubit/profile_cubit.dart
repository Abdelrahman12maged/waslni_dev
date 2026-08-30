import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/settings/domain/entities/user_profile.dart';
import 'package:car_app/features/settings/domain/usecases/get_user_profile_usecase.dart';
import 'package:car_app/features/settings/domain/usecases/update_user_profile_usecase.dart';
import 'package:car_app/features/settings/presentation/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final LocalStorage _localStorage;

  ProfileCubit({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required LocalStorage localStorage,
  })  : _getUserProfileUseCase = getUserProfileUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase,
        _localStorage = localStorage,
        super(ProfileInitial());

  static ProfileCubit get(BuildContext context) => BlocProvider.of(context);

  UserProfile? userProfile;

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userMobileController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();

  Future<void> getUserMyProfile() async {
    emit(ProfileLoading());
    final token = _localStorage.read(key: 'usertoken') as String? ?? '';
    final result = await _getUserProfileUseCase(token);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) {
        userProfile = profile;
        userNameController.text = profile.name ?? '';
        userMobileController.text = profile.mobile ?? '';
        emit(ProfileSuccess(profile));
      },
    );
  }

  Future<void> updateUserMyProfile({
    required dynamic profileData,
  }) async {
    emit(ProfileUpdating());
    final token = _localStorage.read(key: 'usertoken') as String? ?? '';
    final result = await _updateUserProfileUseCase(
      profileData: profileData,
      token: token,
    );

    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message)),
      (_) async {
        emit(ProfileUpdateSuccess());
        // Re-fetch fresh profile so in-memory state and Hive cache stay in sync.
        // The datasource already writes the response to Hive on success;
        // this call updates userProfile + emits ProfileSuccess for any listeners.
        await getUserMyProfile();
      },
    );
  }

  Future<void> updateUser({
    required String name,
    required String mobile,
    required String password,
    required int userId,
    required String userType,
  }) async {
    final Map<String, dynamic> data = {
      'name': name,
      'mobile': mobile,
      'password': password,
      'user_id': userId,
      'user_type': userType,
    };
    await updateUserMyProfile(profileData: data);
  }
}

