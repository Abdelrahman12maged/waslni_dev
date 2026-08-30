/// Abstract contract for local key-value storage.
/// No dependency on SharedPreferences in the domain/presentation layers.
abstract class LocalStorage {
  Future<bool> saveString({required String key, required String value});
  Future<bool> saveInt({required String key, required int value});
  Future<bool> saveBool({required String key, required bool value});
  Future<bool> saveDouble({required String key, required double value});
  Future<bool> saveStringList({required String key, required List<String> value});

  /// Returns the stored value or null if not found.
  dynamic read({required String key});
  List<String>? readStringList({required String key});

  Future<bool> remove({required String key});
  Future<bool> clear();
}
