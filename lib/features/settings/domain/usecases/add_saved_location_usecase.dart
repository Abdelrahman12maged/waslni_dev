import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class AddSavedLocationUseCase {
  final SettingsRepository _repository;

  const AddSavedLocationUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String name,
    required String latitude,
    required String longitude,
    required String token,
  }) =>
      _repository.addSavedLocation(
        name: name,
        latitude: latitude,
        longitude: longitude,
        token: token,
      );
}
