import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/settings/domain/entities/user_profile.dart';
import 'package:car_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class GetUserProfileUseCase {
  final SettingsRepository _repository;

  const GetUserProfileUseCase(this._repository);

  Future<Either<Failure, UserProfile>> call(String token) =>
      _repository.getUserProfile(token);
}
