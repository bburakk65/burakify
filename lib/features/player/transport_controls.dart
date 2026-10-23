import 'package:flutter/material.dart';

import '../../core/audio/format.dart';
import '../../core/audio/playback_queue.dart';
import '../../core/audio/player_controller.dart';

/// Karıştır, önceki, oynat/duraklat, sonraki, tekrar düğmeleri.
class TransportControls extends StatelessWidget {
  const TransportControls({
    super.key,
    required this.player,
    this.compact = false,
  });

  final PlayerController player;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: player,
      builder: (BuildContext context, Widget? _) {
        final bool hasTrack = player.queue.current != null;
        final PlaybackRepeat repeat = player.queue.repeat;
        final double iconSize = compact ? 22 : 26;
        final String repeatTip = switch (repeat) {
          PlaybackRepeat.off => 'Tekrar: kapalı',
          PlaybackRepeat.all => 'Tekrar: tüm kuyruk',
          PlaybackRepeat.one => 'Tekrar: tek şarkı',
        };
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              key: const Key('shuffle_button'),
              tooltip: player.queue.shuffle
                  ? 'Karıştırma: açık'
                  : 'Karıştırma: kapalı',
              iconSize: iconSize,
              color: player.queue.shuffle ? scheme.primary : null,
              onPressed: hasTrack ? player.toggleShuffle : null,
              icon: const Icon(Icons.shuffle),
            ),
            IconButton(
              key: const Key('previous_button'),
              tooltip: 'Önceki',
              iconSize: iconSize + 4,
              onPressed: hasTrack ? () => player.previous() : null,
              icon: const Icon(Icons.skip_previous),
            ),
            IconButton.filled(
              key: const Key('play_pause_button'),
              tooltip: player.isPlaying ? 'Duraklat' : 'Oynat',
              iconSize: compact ? 26 : 32,
              onPressed: hasTrack ? () => player.togglePlay() : null,
              icon: player.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Icon(player.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            IconButton(
              key: const Key('next_button'),
              tooltip: 'Sonraki',
              iconSize: iconSize + 4,
              onPressed: hasTrack ? () => player.next() : null,
              icon: const Icon(Icons.skip_next),
            ),
            IconButton(
              key: const Key('repeat_button'),
              tooltip: repeatTip,
              iconSize: iconSize,
              color: repeat == PlaybackRepeat.off ? null : scheme.primary,
              onPressed: hasTrack ? player.cycleRepeat : null,
              icon: Icon(
                repeat == PlaybackRepeat.one ? Icons.repeat_one : Icons.repeat,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// İlerleme çubuğu ve süreler. Değerler gerçek oynatma konumundan gelir.
class SeekBar extends StatefulWidget {
  const SeekBar({super.key, required this.player});

  final PlayerController player;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final PlayerController player = widget.player;
    return ValueListenableBuilder<Duration>(
      valueListenable: player.duration,
      builder: (BuildContext context, Duration total, Widget? _) {
        return ValueListenableBuilder<Duration>(
          valueListenable: player.position,
          builder: (BuildContext context, Duration pos, Widget? __) {
            final double maxMs = total.inMilliseconds.toDouble();
            final bool enabled = maxMs > 0 && player.queue.current != null;
            final double value = _drag ??
                (enabled
                    ? pos.inMilliseconds.toDouble().clamp(0.0, maxMs).toDouble()
                    : 0.0);
            return Row(
              children: <Widget>[
                SizedBox(
                  width: 44,
                  child: Text(
                    formatDuration(Duration(milliseconds: value.round())),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: Slider(
                    key: const Key('seek_slider'),
                    value: value,
                    min: 0,
                    max: enabled ? maxMs : 1,
                    onChanged: enabled
                        ? (double v) => setState(() => _drag = v)
                        : null,
                    onChangeEnd: enabled
                        ? (double v) {
                            player.seek(Duration(milliseconds: v.round()));
                            setState(() => _drag = null);
                          }
                        : null,
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    formatDuration(total),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
