import 'package:flutter/material.dart';

import '../errors/app_log.dart';
import 'settings_store.dart';

/// Kullanıcı ayarları. Şu an yalnızca tema; varsayılan koyu temadır.
class SettingsController extends ChangeNotifier {
  SettingsController._(this._store, this._themeMode);

  static const String themeKey = 'theme_mode';

  final SettingsStore _store;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  /// Kayıtlı ayarları okur. Okuma hata verirse istisna yukarı atılır
  /// (başlangıç ekranı "Tekrar dene" gösterir). Bilinmeyen değer koyu temaya düşer.
  static Future<SettingsController> load(SettingsStore store) async {
    final String? raw = await store.readString(themeKey);
    return SettingsController._(store, _parse(raw));
  }

  static ThemeMode _parse(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  /// Temayı hemen uygular, ardından kalıcı olarak kaydetmeyi dener.
  /// Kaydedilemezse false döner (tema bu oturum için yine de değişmiş kalır).
  Future<bool> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) {
      return true;
    }
    _themeMode = mode;
    notifyListeners();
    try {
      await _store.writeString(themeKey, _encode(mode));
      return true;
    } catch (error) {
      AppLog.error('settings_write_failed', error);
      return false;
    }
  }
}
