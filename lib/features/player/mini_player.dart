import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/animation/motion.dart';
import '../../core/audio/player_controller.dart';
import '../../core/audio/track.dart';
import '../../core/design/components.dart';

/// Telefon ve tablet için alt mini oynatıcı. Parça yoksa görünmez.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PlayerController player = AppScope.of(context).player;
    final ThemeData theme = Theme.of(context);
    return ListenableBuilder(
      listenable: player,
      builder: (BuildContext context, Widget? _) {
        final Track? track = player.queue.current;
        return AnimatedSize(
          duration: BurakifyMotion.duration(context, BurakifyMotion.fast),
          curve: BurakifyMotion.standard,
          alignment: Alignment.bottomCenter,
          child: track == null
              ? const SizedBox(width: double.infinity)
              : Material(
                  key: const Key('mini_player'),
                  color: theme.colorScheme.surfaceContainerHigh,
                  child: InkWell(
                    onTap: onTap,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _MiniProgress(player: player),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: <Widget>[
                              CoverPlaceholder(seed: track.id, size: 48),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AnimatedSwitcher(
                                  duration: BurakifyMotion.duration(
                                    context,
                                    BurakifyMotion.medium,
                                  ),
                                  child: Align(
                                    key: ValueKey<String>(track.id),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      track.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                key: const Key('mini_play_pause'),
                                tooltip:
                                    player.isPlaying ? 'Duraklat' : 'Oynat',
                                onPressed: () => player.togglePlay(),
                                icon: Icon(
                                  player.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                              ),
                              IconButton(
                                key: const Key('mini_next'),
                                tooltip: 'Sonraki',
                                onPressed: () => player.next(),
                                icon: const Icon(Icons.skip_next),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.player});

  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: player.duration,
      builder: (BuildContext context, Duration total, Widget? _) {
        return ValueListenableBuilder<Duration>(
          valueListenable: player.position,
          builder: (BuildContext context, Duration pos, Widget? __) {
            final int totalMs = total.inMilliseconds;
            // Süre bilinmiyorsa uydurma yüzde göstermeyiz.
            final double? value = totalMs > 0
                ? (pos.inMilliseconds / totalMs).clamp(0.0, 1.0).toDouble()
                : 0.0;
            return LinearProgressIndicator(minHeight: 2, value: value);
          },
        );
      },
    );
  }
}
