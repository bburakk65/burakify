import 'package:flutter/material.dart';

import '../../app/actions.dart';
import '../../app/app_scope.dart';
import '../../app/layout/form_factor.dart';
import '../../core/audio/track.dart';
import '../../core/design/components.dart';
import 'track_views.dart';

/// Kitaplık: kullanıcının eklediği tüm yerel müzik dosyaları.
/// Telefonda liste, tablet ve Windows'ta ekran genişliğine göre sütun sayısı
/// değişen kart ızgarası.
///
/// KAPSAM: Albüm/sanatçı/çalma listesi gruplaması yok; dosya etiketleri
/// (albüm, sanatçı, kapak) henüz okunmuyor. Yalnızca "şarkılar" gösterilir.
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key, required this.formFactor});

  final FormFactor formFactor;

  @override
  Widget build(BuildContext context) {
    final AppServices services = AppScope.of(context);
    final double pad = formFactor == FormFactor.phone ? 16 : 24;
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        services.library,
        services.player,
      ]),
      builder: (BuildContext context, Widget? _) {
        final List<Track> tracks = services.library.tracks;
        final Track? current = services.player.queue.current;
        return CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, pad, pad, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Kitaplık',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    if (tracks.isNotEmpty)
                      FilledButton.tonalIcon(
                        key: const Key('library_add_button'),
                        onPressed: () => pickAndImport(context, services),
                        icon: const Icon(Icons.add),
                        label: const Text('Dosya ekle'),
                      ),
                  ],
                ),
              ),
            ),
            if (tracks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.library_music_outlined,
                  title: 'Kitaplığınız boş',
                  message: formFactor == FormFactor.desktop
                      ? 'Cihazınızdaki müzik dosyalarını seçin veya bu pencereye sürükleyip bırakın. İnternet gerekmez.'
                      : 'Cihazınızdaki müzik dosyalarını seçin. İnternet gerekmez.',
                  actionLabel: 'Müzik dosyası ekle',
                  actionKey: const Key('empty_add_button'),
                  onAction: () => pickAndImport(context, services),
                ),
              )
            else
              buildTrackSliver(
                keyPrefix: 'library',
                tracks: tracks,
                current: current,
                player: services.player,
                formFactor: formFactor,
              ),
          ],
        );
      },
    );
  }
}
