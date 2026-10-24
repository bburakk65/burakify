import 'package:flutter/material.dart';

import 'app/bootstrap.dart';
import 'core/audio/background_audio.dart';
import 'core/data/settings_store.dart';

/// NOT: Bu ortamda derlenmedi (Flutter SDK yok). Doğrulama GitHub Actions'ta.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android'de arka plan çalma; ses motoru oluşturulmadan önce hazır olmalı.
  await initBackgroundAudio();
  runApp(const AppBootstrap(openStore: SharedPrefsSettingsStore.open));
}
