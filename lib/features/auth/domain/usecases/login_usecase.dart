import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/usecases/usecase.dart';
import 'package:car_app/features/auth/domain/entities/user_entity.dart';
import 'package:car_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await repository.login(
      mobile: params.mobile,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String mobile;
  final String password;

  const LoginParams({required this.mobile, required this.password});

  @override
  List<Object?> get props => [mobile, password];
}
