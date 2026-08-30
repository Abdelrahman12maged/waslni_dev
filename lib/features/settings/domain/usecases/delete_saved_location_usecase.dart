import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteSavedLocationUseCase {
  final SettingsRepository _repository;

  const DeleteSavedLocationUseCase(this._repository);

  Future<Either<Failure, void>> call(int id, String token) =>
      _repository.deleteSavedLocation(id, token);
}
