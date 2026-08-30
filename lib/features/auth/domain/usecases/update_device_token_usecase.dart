import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/usecases/usecase.dart';
import 'package:car_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateDeviceTokenUseCase implements UseCase<void, String> {
  final AuthRepository _repository;

  const UpdateDeviceTokenUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String fcmToken) {
    return _repository.updateDeviceToken(fcmToken: fcmToken);
  }
}
