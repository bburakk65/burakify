import 'package:flutter/material.dart';

import '../core/audio/just_audio_player_service.dart';
import '../core/audio/player_controller.dart';
import '../core/audio/player_service.dart';
import '../core/data/audio_file_picker.dart';
import '../core/data/library_controller.dart';
import '../core/data/settings_controller.dart';
import '../core/design/burakify_theme.dart';
import 'app_scope.dart';
import 'shell/adaptive_shell.dart';

class BurakifyApp extends StatefulWidget {
  /// [playerService] ve [pickFiles] testlerde sahte uygulamalarla değiştirilir.
  const BurakifyApp({
    super.key,
    required this.settings,
    this.playerService,
    this.pickFiles,
  });

  final SettingsController settings;
  final PlayerService? playerService;
  final Future<List<String>> Function()? pickFiles;

  @override
  State<BurakifyApp> createState() => _BurakifyAppState();
}

class _BurakifyAppState extends State<BurakifyApp> {
  late final AppServices _services;

  @override
  void initState() {
    super.initState();
    _services = AppServices(
      player: PlayerController(widget.playerService ?? JustAudioPlayerService()),
      library: LibraryController(),
      settings: widget.settings,
      pickFiles: widget.pickFiles ?? pickAudioPaths,
    );
  }

  @override
  void dispose() {
    _services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: _services,
      child: ListenableBuilder(
        listenable: widget.settings,
        builder: (BuildContext context, Widget? _) {
          return MaterialApp(
            title: 'Burakify',
            debugShowCheckedModeBanner: false,
            theme: BurakifyTheme.light(),
            darkTheme: BurakifyTheme.dark(),
            themeMode: widget.settings.themeMode,
            home: const AdaptiveShell(),
          );
        },
      ),
    );
  }
}
