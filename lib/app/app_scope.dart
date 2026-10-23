import 'package:flutter/material.dart';

import '../core/audio/player_controller.dart';
import '../core/data/library_controller.dart';
import '../core/data/settings_controller.dart';

/// Uygulama genelinde paylaşılan hizmetler.
class AppServices {
  AppServices({
    required this.player,
    required this.library,
    required this.settings,
    required this.pickFiles,
  });

  final PlayerController player;
  final LibraryController library;
  final SettingsController settings;
  final Future<List<String>> Function() pickFiles;

  /// [settings] burada kapatılmaz; sahibi [AppBootstrap]'tır.
  void dispose() {
    player.dispose();
    library.dispose();
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final AppScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope bulunamadı');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      services != oldWidget.services;
}
