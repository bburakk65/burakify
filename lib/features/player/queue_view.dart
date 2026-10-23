import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/audio/player_controller.dart';
import '../../core/audio/track.dart';
import '../../core/design/components.dart';

/// Oynatma kuyruğu listesi. Telefon/tablette bir sayfa, masaüstünde sağ panel
/// olarak kullanılır.
class QueueView extends StatelessWidget {
  const QueueView({super.key, this.padding = 16});

  final double padding;

  @override
  Widget build(BuildContext context) {
    final PlayerController player = AppScope.of(context).player;
    final ThemeData theme = Theme.of(context);
    return ListenableBuilder(
      listenable: player,
      builder: (BuildContext context, Widget? _) {
        final List<Track> tracks = player.queue.tracks;
        final Track? current = player.queue.current;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(padding, padding, padding, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text('Kuyruk', style: theme.textTheme.titleLarge),
                  ),
                  if (tracks.isNotEmpty)
                    TextButton(
                      key: const Key('queue_clear_button'),
                      onPressed: () => player.clearQueue(),
                      child: const Text('Temizle'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: tracks.isEmpty
                  ? const EmptyState(
                      icon: Icons.queue_music,
                      title: 'Kuyruk boş',
                      message:
                          'Kitaplıktan bir şarkı çalın veya "Sıraya ekle" düğmesini kullanın.',
                    )
                  : ListView.builder(
                      itemCount: tracks.length,
                      itemBuilder: (BuildContext context, int i) {
                        final Track t = tracks[i];
                        final bool isCurrent = t == current;
                        return ListTile(
                          selected: isCurrent,
                          leading: isCurrent
                              ? Icon(
                                  player.isPlaying
                                      ? Icons.volume_up
                                      : Icons.pause_circle_outline,
                                )
                              : Text('${i + 1}'),
                          title: Text(
                            t.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            tooltip: 'Kuyruktan kaldır',
                            icon: const Icon(Icons.close),
                            onPressed: () => player.removeFromQueue(i),
                          ),
                          onTap: () => player.jumpTo(i),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
