import 'package:flutter/material.dart';

import '../core/audio/player_service.dart';
import '../core/data/settings_controller.dart';
import '../core/data/settings_store.dart';
import '../core/design/burakify_theme.dart';
import '../core/design/components.dart';
import '../core/errors/app_log.dart';
import 'burakify_app.dart';

/// Açılış: ayarları okur. Okuma sürerken yükleme, hata veya zaman aşımında
/// "Tekrar dene" gösterir; sonsuz yükleme olmaz.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({
    super.key,
    required this.openStore,
    this.playerService,
    this.pickFiles,
    this.timeout = const Duration(seconds: 8),
  });

  final Future<SettingsStore> Function() openStore;
  final PlayerService? playerService;
  final Future<List<String>> Function()? pickFiles;
  final Duration timeout;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<SettingsController> _future;
  SettingsController? _settings;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<SettingsController> _load() async {
    try {
      final SettingsStore store = await widget.openStore().timeout(widget.timeout);
      final SettingsController controller = await SettingsController.load(store);
      _settings = controller;
      return controller;
    } catch (error) {
      AppLog.error('startup_failed', error);
      rethrow;
    }
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  @override
  void dispose() {
    _settings?.dispose();
    super.dispose();
  }

  Widget _plain(Widget child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Burakify',
      theme: BurakifyTheme.light(),
      darkTheme: BurakifyTheme.dark(),
      themeMode: ThemeMode.dark,
      home: Scaffold(body: SafeArea(child: child)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SettingsController>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<SettingsController> snap) {
        if (snap.hasError) {
          return _plain(
            ErrorView(
              title: 'Burakify başlatılamadı',
              message: 'Ayarlar okunamadı. Tekrar deneyin.',
              onRetry: _retry,
            ),
          );
        }
        final SettingsController? settings = snap.data;
        if (settings == null) {
          return _plain(const LoadingView(message: 'Burakify başlatılıyor…'));
        }
        return BurakifyApp(
          settings: settings,
          playerService: widget.playerService,
          pickFiles: widget.pickFiles,
        );
      },
    );
  }
}
