import 'package:shared_preferences/shared_preferences.dart';

import '../errors/app_error.dart';

/// Basit anahtar-değer ayar deposu arayüzü. Testlerde bellek uygulaması kullanılır.
abstract class SettingsStore {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);
}

class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore({
    Map<String, String>? initial,
    this.failWrites = false,
  }) : _values = <String, String>{...?initial};

  final Map<String, String> _values;
  bool failWrites;

  @override
  Future<String?> readString(String key) async => _values[key];

  @override
  Future<void> writeString(String key, String value) async {
    if (failWrites) {
      throw const AppError(AppErrorKind.storage, 'Ayar kaydedilemedi.');
    }
    _values[key] = value;
  }
}

/// `shared_preferences` tabanlı gerçek depo (Android ve Windows).
class SharedPrefsSettingsStore implements SettingsStore {
  SharedPrefsSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<SettingsStore> open() async =>
      SharedPrefsSettingsStore(await SharedPreferences.getInstance());

  @override
  Future<String?> readString(String key) async => _prefs.getString(key);

  @override
  Future<void> writeString(String key, String value) async {
    final bool ok = await _prefs.setString(key, value);
    if (!ok) {
      throw const AppError(AppErrorKind.storage, 'Ayar kaydedilemedi.');
    }
  }
}
