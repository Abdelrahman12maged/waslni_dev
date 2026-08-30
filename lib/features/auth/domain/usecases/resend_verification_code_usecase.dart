import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/usecases/usecase.dart';
import 'package:car_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class ResendVerificationCodeUseCase implements UseCase<String, String> {
  final AuthRepository repository;

  ResendVerificationCodeUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(String mobile) async {
    return await repository.resendVerificationCode(mobile: mobile);
  }
}
