import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'actions.dart';
import 'app_scope.dart';

class TogglePlayIntent extends Intent {
  const TogglePlayIntent();
}

class NextTrackIntent extends Intent {
  const NextTrackIntent();
}

class PreviousTrackIntent extends Intent {
  const PreviousTrackIntent();
}

class OpenFilesIntent extends Intent {
  const OpenFilesIntent();
}

class ToggleQueuePanelIntent extends Intent {
  const ToggleQueuePanelIntent();
}

/// Klavye kısayolları (tablet klavyesi ve Windows):
/// Boşluk = oynat/duraklat, Ctrl+→/← = sonraki/önceki,
/// Ctrl+O = dosya ekle, Ctrl+Q = kuyruk panelini aç/kapat (masaüstü).
///
/// Bilinen sınırlama: Boşluk, odaktaki bir düğmeyi "etkinleştirme" yerine
/// oynat/duraklat olarak çalıştırır.
class PlayerShortcuts extends StatelessWidget {
  const PlayerShortcuts({
    super.key,
    required this.child,
    this.onToggleQueuePanel,
  });

  final Widget child;
  final VoidCallback? onToggleQueuePanel;

  @override
  Widget build(BuildContext context) {
    final AppServices services = AppScope.of(context);
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.space):
            const TogglePlayIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
            const NextTrackIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
            const PreviousTrackIntent(),
        const SingleActivator(LogicalKeyboardKey.keyO, control: true):
            const OpenFilesIntent(),
        const SingleActivator(LogicalKeyboardKey.keyQ, control: true):
            const ToggleQueuePanelIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          TogglePlayIntent: CallbackAction<TogglePlayIntent>(
            onInvoke: (TogglePlayIntent _) {
              services.player.togglePlay();
              return null;
            },
          ),
          NextTrackIntent: CallbackAction<NextTrackIntent>(
            onInvoke: (NextTrackIntent _) {
              services.player.next();
              return null;
            },
          ),
          PreviousTrackIntent: CallbackAction<PreviousTrackIntent>(
            onInvoke: (PreviousTrackIntent _) {
              services.player.previous();
              return null;
            },
          ),
          OpenFilesIntent: CallbackAction<OpenFilesIntent>(
            onInvoke: (OpenFilesIntent _) {
              pickAndImport(context, services);
              return null;
            },
          ),
          ToggleQueuePanelIntent: CallbackAction<ToggleQueuePanelIntent>(
            onInvoke: (ToggleQueuePanelIntent _) {
              onToggleQueuePanel?.call();
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}
