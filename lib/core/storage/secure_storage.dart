import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service contract for encrypted local storage (auth tokens, user credentials).
abstract class SecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> clear();
}

/// [FlutterSecureStorage] implementation of [SecureStorage].
class SecureStorageImpl implements SecureStorage {
  final FlutterSecureStorage _storage;

  const SecureStorageImpl(this._storage);

  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
