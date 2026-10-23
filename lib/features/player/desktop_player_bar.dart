import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/audio/player_controller.dart';
import '../../core/audio/track.dart';
import '../../core/design/components.dart';
import 'transport_controls.dart';

/// Windows alt oynatıcı çubuğu: solda parça, ortada kontroller ve ilerleme,
/// sağda ses seviyesi ve kuyruk paneli düğmesi.
class DesktopPlayerBar extends StatelessWidget {
  const DesktopPlayerBar({
    super.key,
    required this.queuePanelOpen,
    required this.onToggleQueue,
  });

  final bool queuePanelOpen;
  final VoidCallback onToggleQueue;

  @override
  Widget build(BuildContext context) {
    final PlayerController player = AppScope.of(context).player;
    final ThemeData theme = Theme.of(context);
    return Material(
      key: const Key('desktop_player_bar'),
      color: theme.colorScheme.surfaceContainerHigh,
      child: SizedBox(
        height: 104,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              Expanded(flex: 3, child: _NowPlayingInfo(player: player)),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TransportControls(player: player, compact: true),
                    SeekBar(player: player),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: ListenableBuilder(
                  listenable: player,
                  builder: (BuildContext context, Widget? _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          player.volume == 0
                              ? Icons.volume_off
                              : Icons.volume_up,
                          size: 20,
                        ),
                        SizedBox(
                          width: 100,
                          child: Slider(
                            key: const Key('volume_slider'),
                            value: player.volume,
                            onChanged: (double v) => player.setVolume(v),
                          ),
                        ),
                        IconButton(
                          key: const Key('queue_toggle_button'),
                          tooltip: queuePanelOpen
                              ? 'Kuyruğu gizle (Ctrl+Q)'
                              : 'Kuyruğu göster (Ctrl+Q)',
                          isSelected: queuePanelOpen,
                          onPressed: onToggleQueue,
                          icon: const Icon(Icons.queue_music),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NowPlayingInfo extends StatelessWidget {
  const _NowPlayingInfo({required this.player});

  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: player,
      builder: (BuildContext context, Widget? _) {
        final Track? track = player.queue.current;
        if (track == null) {
          return Text(
            'Çalan şarkı yok',
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }
        return Row(
          children: <Widget>[
            CoverPlaceholder(seed: track.id, size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (player.errorMessage != null)
                    Text(
                      player.errorMessage!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
