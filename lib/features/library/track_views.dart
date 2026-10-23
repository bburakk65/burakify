import 'package:flutter/material.dart';

import '../../app/layout/form_factor.dart';
import '../../core/audio/player_controller.dart';
import '../../core/audio/track.dart';
import '../../core/design/components.dart';

/// Parça listesi (telefon) veya kart ızgarası (tablet/Windows) olarak bir sliver.
/// Kitaplık ve Ana Sayfa aynı görünümü paylaşır; bir parçaya dokunmak, gösterilen
/// listeyi kuyruk yapıp o parçadan çalmaya başlar.
Widget buildTrackSliver({
  required String keyPrefix,
  required List<Track> tracks,
  required Track? current,
  required PlayerController player,
  required FormFactor formFactor,
}) {
  if (formFactor == FormFactor.phone) {
    return SliverList(
      key: Key('${keyPrefix}_list'),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int i) {
          final Track t = tracks[i];
          return ListTile(
            selected: t == current,
            leading: CoverPlaceholder(seed: t.id, size: 48),
            title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              tooltip: 'Sıraya ekle',
              icon: const Icon(Icons.playlist_add),
              onPressed: () => player.addToQueue(<Track>[t]),
            ),
            onTap: () => player.playTracks(tracks, startIndex: i),
          );
        },
        childCount: tracks.length,
      ),
    );
  }
  return SliverPadding(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
    sliver: SliverGrid(
      key: Key('${keyPrefix}_grid'),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: formFactor == FormFactor.desktop ? 220 : 200,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int i) {
          final Track t = tracks[i];
          return _TrackCard(
            track: t,
            isCurrent: t == current,
            onPlay: () => player.playTracks(tracks, startIndex: i),
            onQueue: () => player.addToQueue(<Track>[t]),
          );
        },
        childCount: tracks.length,
      ),
    ),
  );
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.track,
    required this.isCurrent,
    required this.onPlay,
    required this.onQueue,
  });

  final Track track;
  final bool isCurrent;
  final VoidCallback onPlay;
  final VoidCallback onQueue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPlay,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: CoverPlaceholder(seed: track.id)),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: IconButton.filledTonal(
                      tooltip: 'Sıraya ekle',
                      onPressed: onQueue,
                      icon: const Icon(Icons.playlist_add),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                track.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isCurrent ? theme.colorScheme.primary : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
