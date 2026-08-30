import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateUserProfileUseCase {
  final SettingsRepository _repository;

  const UpdateUserProfileUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required dynamic profileData,
    required String token,
  }) =>
      _repository.updateUserProfile(profileData: profileData, token: token);
}
