import 'package:flutter/material.dart';

import '../../app/actions.dart';
import '../../app/app_scope.dart';
import '../../app/layout/form_factor.dart';
import '../../core/audio/track.dart';
import '../../core/data/library_search.dart';
import '../../core/design/components.dart';
import '../../core/design/logo.dart';
import '../library/track_views.dart';

/// Ana Sayfa: logo ve ad, arama alanı, katalog durumu bilgisi ve yerel müzik kartları.
/// Arama, kitaplıktaki dosyaların başlığında çalışır (çevrimiçi katalog yok).
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.formFactor});

  final FormFactor formFactor;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final AppServices services = AppScope.of(context);
    final ThemeData theme = Theme.of(context);
    final double pad = widget.formFactor == FormFactor.phone ? 16 : 24;
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        services.library,
        services.player,
      ]),
      builder: (BuildContext context, Widget? _) {
        final List<Track> all = services.library.tracks;
        final List<Track> tracks = filterTracks(all, _query);
        final Track? current = services.player.queue.current;
        return CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, pad, pad, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const BurakifyLogo(size: 40),
                        const SizedBox(width: 12),
                        Text(
                          'Burakify',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      header: true,
                      child: Text('Ana Sayfa', style: theme.textTheme.headlineMedium),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const Key('search_field'),
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onChanged: (String v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Kitaplığınızda ara',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                key: const Key('search_clear_button'),
                                tooltip: 'Aramayı temizle',
                                icon: const Icon(Icons.close),
                                onPressed: _clear,
                              ),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _CatalogNotice(),
                    const SizedBox(height: 24),
                    Text('Yerel müzik', style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            if (all.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.library_music_outlined,
                  title: 'Henüz müzik eklemediniz',
                  message:
                      'Cihazınızdaki müzik dosyalarını ekleyin. İnternet gerekmez.',
                  actionLabel: 'Müzik dosyası ekle',
                  actionKey: const Key('home_add_button'),
                  onAction: () => pickAndImport(context, services),
                ),
              )
            else if (tracks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.search_off,
                  title: 'Sonuç bulunamadı',
                  message: '"${_query.trim()}" ile eşleşen şarkı yok.',
                ),
              )
            else
              buildTrackSliver(
                keyPrefix: 'home',
                tracks: tracks,
                current: current,
                player: services.player,
                formFactor: widget.formFactor,
              ),
          ],
        );
      },
    );
  }
}

class _CatalogNotice extends StatelessWidget {
  const _CatalogNotice();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      key: const Key('catalog_notice'),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.info_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Çevrimiçi müzik kataloğu henüz bağlı değil. Şimdilik yalnızca cihazınızdaki müzik dosyaları çalınır.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
