import 'package:burakify/core/data/settings_controller.dart';
import 'package:burakify/core/data/settings_store.dart';
import 'package:burakify/core/errors/app_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => AppLog.sink = (String _) {});

  test('kayıt yoksa varsayılan koyu tema', () async {
    final SettingsController c =
        await SettingsController.load(MemorySettingsStore());
    expect(c.themeMode, ThemeMode.dark);
  });

  test('kayıtlı tema okunur', () async {
    final SettingsController light = await SettingsController.load(
      MemorySettingsStore(initial: <String, String>{'theme_mode': 'light'}),
    );
    final SettingsController system = await SettingsController.load(
      MemorySettingsStore(initial: <String, String>{'theme_mode': 'system'}),
    );
    expect(light.themeMode, ThemeMode.light);
    expect(system.themeMode, ThemeMode.system);
  });

  test('bozuk kayıt koyu temaya düşer', () async {
    final SettingsController c = await SettingsController.load(
      MemorySettingsStore(initial: <String, String>{'theme_mode': '???'}),
    );
    expect(c.themeMode, ThemeMode.dark);
  });

  test('tema değişir, kaydedilir ve dinleyicilere bildirilir', () async {
    final MemorySettingsStore store = MemorySettingsStore();
    final SettingsController c = await SettingsController.load(store);
    int notified = 0;
    c.addListener(() => notified++);

    final bool saved = await c.setThemeMode(ThemeMode.light);

    expect(saved, isTrue);
    expect(c.themeMode, ThemeMode.light);
    expect(notified, 1);
    expect(await store.readString('theme_mode'), 'light');
  });

  test('aynı tema seçilirse bildirim yapılmaz', () async {
    final SettingsController c =
        await SettingsController.load(MemorySettingsStore());
    int notified = 0;
    c.addListener(() => notified++);
    expect(await c.setThemeMode(ThemeMode.dark), isTrue);
    expect(notified, 0);
  });

  test('kayıt başarısız olursa false döner, tema bu oturumda değişmiş kalır',
      () async {
    final MemorySettingsStore store = MemorySettingsStore(failWrites: true);
    final SettingsController c = await SettingsController.load(store);
    final bool saved = await c.setThemeMode(ThemeMode.light);
    expect(saved, isFalse);
    expect(c.themeMode, ThemeMode.light);
    expect(await store.readString('theme_mode'), isNull);
  });
}
