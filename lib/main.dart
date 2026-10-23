import 'package:flutter/material.dart';

import 'app/bootstrap.dart';
import 'core/data/settings_store.dart';

/// NOT: Bu ortamda derlenmedi (Flutter SDK yok). Bkz. docs/12-PROMPT-2-RAPOR.md.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap(openStore: SharedPrefsSettingsStore.open));
}
