class ServerException implements Exception {
  final String? message;
  final String? errorCode;
  const ServerException([this.message, this.errorCode]);

  @override
  String toString() => message ?? 'ServerException';
}

class CacheException implements Exception {
  final String? message;
  const CacheException([this.message]);

  @override
  String toString() => message ?? 'CacheException';
}

class AppFirebaseException implements Exception {
  final String? message;
  const AppFirebaseException([this.message]);

  @override
  String toString() => message ?? 'FirebaseException';
}
