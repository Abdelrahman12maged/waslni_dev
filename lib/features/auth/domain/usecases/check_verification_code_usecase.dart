import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/usecases/usecase.dart';
import 'package:car_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class CheckVerificationCodeUseCase implements UseCase<String, CheckVerificationCodeParams> {
  final AuthRepository repository;

  CheckVerificationCodeUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CheckVerificationCodeParams params) async {
    return await repository.checkVerificationCode(
      mobile: params.mobile,
      code: params.code,
    );
  }
}

class CheckVerificationCodeParams extends Equatable {
  final String mobile;
  final String code;

  const CheckVerificationCodeParams({required this.mobile, required this.code});

  @override
  List<Object?> get props => [mobile, code];
}
