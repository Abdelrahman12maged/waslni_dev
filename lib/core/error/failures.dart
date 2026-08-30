abstract class Failure {
  final String message;
  const Failure({required this.message});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  final int? statusCode;
  final String? errorCode;
  const ServerFailure({required super.message, this.statusCode, this.errorCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class AppFirebaseFailure extends Failure {
  const AppFirebaseFailure({required super.message});
}
