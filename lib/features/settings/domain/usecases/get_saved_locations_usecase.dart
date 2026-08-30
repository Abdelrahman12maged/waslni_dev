import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/settings/domain/entities/saved_location.dart';
import 'package:car_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class GetSavedLocationsUseCase {
  final SettingsRepository _repository;

  const GetSavedLocationsUseCase(this._repository);

  Future<Either<Failure, List<SavedLocation>>> call(String token) =>
      _repository.getSavedLocations(token);
}
