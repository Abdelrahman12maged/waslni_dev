import 'package:car_app/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences implementation of [LocalStorage].
/// Registered as a singleton in the DI container.
class SharedPrefsStorage implements LocalStorage {
  final SharedPreferences _prefs;

  const SharedPrefsStorage(this._prefs);

  @override
  dynamic read({required String key}) => _prefs.get(key);

  @override
  Future<bool> saveString({required String key, required String value}) =>
      _prefs.setString(key, value);

  @override
  Future<bool> saveInt({required String key, required int value}) =>
      _prefs.setInt(key, value);

  @override
  Future<bool> saveBool({required String key, required bool value}) =>
      _prefs.setBool(key, value);

  @override
  Future<bool> saveDouble({required String key, required double value}) =>
      _prefs.setDouble(key, value);

  @override
  Future<bool> saveStringList({required String key, required List<String> value}) =>
      _prefs.setStringList(key, value);

  @override
  List<String>? readStringList({required String key}) =>
      _prefs.getStringList(key);

  @override
  Future<bool> remove({required String key}) => _prefs.remove(key);

  @override
  Future<bool> clear() => _prefs.clear();
}
