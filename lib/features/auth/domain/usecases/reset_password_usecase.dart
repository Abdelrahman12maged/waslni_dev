import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/usecases/usecase.dart';
import 'package:car_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class ResetPasswordUseCase implements UseCase<String, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(
      mobile: params.mobile,
      password: params.password,
      code: params.code,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String mobile;
  final String password;
  final String code;

  const ResetPasswordParams({
    required this.mobile,
    required this.password,
    required this.code,
  });

  @override
  List<Object?> get props => [mobile, password, code];
}
