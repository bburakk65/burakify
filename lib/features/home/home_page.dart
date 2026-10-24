import 'package:flutter/material.dart';

import '../../app/actions.dart';
import '../../app/app_scope.dart';
import '../../app/layout/form_factor.dart';
import '../../core/audio/track.dart';
import '../../core/catalog/catalog_source.dart';
import '../../core/data/library_search.dart';
import '../../core/design/components.dart';
import '../../core/design/logo.dart';
import '../library/track_views.dart';

/// Ana Sayfa: logo ve ad, kaynak seçici (Kitaplığım / Çevrimiçi), arama alanı,
/// kaynak bilgisi ve müzik kartları.
/// "Kitaplığım": arama kitaplıktaki dosya başlıklarında çalışır.
/// "Çevrimiçi": arama gönderilince [CatalogSource] (Internet Archive) sorgulanır.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.formFactor});

  final FormFactor formFactor;

  @override
  State<HomePage> createState() => _HomePageState();
}

enum _OnlineStatus { idle, loading, error, done }

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  bool _online = false;
  _OnlineStatus _status = _OnlineStatus.idle;
  List<Track> _results = const <Track>[];
  String _errorText = '';
  int _searchToken = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _query = '';
      if (_online) {
        _searchToken++;
        _status = _OnlineStatus.idle;
        _results = const <Track>[];
      }
    });
  }

  void _setOnline(bool online) {
    if (online == _online) {
      return;
    }
    _controller.clear();
    setState(() {
      _online = online;
      _query = '';
      _searchToken++;
      _status = _OnlineStatus.idle;
      _results = const <Track>[];
      _errorText = '';
    });
  }

  Future<void> _search(CatalogSource catalog) async {
    final String q = _controller.text.trim();
    if (q.isEmpty) {
      return;
    }
    final int token = ++_searchToken;
    setState(() => _status = _OnlineStatus.loading);
    try {
      final List<Track> found = await catalog.search(q);
      if (!mounted || token != _searchToken) {
        return;
      }
      setState(() {
        _results = found;
        _status = _OnlineStatus.done;
      });
    } on CatalogException catch (e) {
      if (!mounted || token != _searchToken) {
        return;
      }
      setState(() {
        _errorText = e.message;
        _status = _OnlineStatus.error;
      });
    } catch (_) {
      if (!mounted || token != _searchToken) {
        return;
      }
      setState(() {
        _errorText = 'Arama tamamlanamadı. Tekrar deneyin.';
        _status = _OnlineStatus.error;
      });
    }
  }

  Widget _onlineBody(AppServices services, Track? current) {
    switch (_status) {
      case _OnlineStatus.idle:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.travel_explore,
            title: 'Çevrimiçi müzik ara',
            message:
                'Bir sanatçı veya şarkı adı yazıp arayın. Sonuçlar internetten çalınır; internet gerekir.',
          ),
        );
      case _OnlineStatus.loading:
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: LoadingView(message: 'Aranıyor…'),
        );
      case _OnlineStatus.error:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Arama yapılamadı',
            message: _errorText,
            actionLabel: 'Tekrar dene',
            actionKey: const Key('online_retry_button'),
            onAction: () => _search(services.catalog),
          ),
        );
      case _OnlineStatus.done:
        if (_results.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.search_off,
              title: 'Sonuç bulunamadı',
              message:
                  '"${_controller.text.trim()}" için lisanslı çevrimiçi parça bulunamadı. Başka bir arama deneyin.',
            ),
          );
        }
        return buildTrackSliver(
          keyPrefix: 'online',
          tracks: _results,
          current: current,
          player: services.player,
          formFactor: widget.formFactor,
        );
    }
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
                    SegmentedButton<bool>(
                      key: const Key('source_selector'),
                      showSelectedIcon: false,
                      segments: const <ButtonSegment<bool>>[
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Kitaplığım'),
                          icon: Icon(Icons.library_music_outlined),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('Çevrimiçi'),
                          icon: Icon(Icons.cloud_outlined),
                        ),
                      ],
                      selected: <bool>{_online},
                      onSelectionChanged: (Set<bool> s) => _setOnline(s.first),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('search_field'),
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onChanged: (String v) => setState(() => _query = v),
                      onSubmitted: (String _) {
                        if (_online) {
                          _search(services.catalog);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: _online
                            ? 'Çevrimiçi müzik ara'
                            : 'Kitaplığınızda ara',
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
                    _CatalogNotice(
                      text: _online
                          ? '${services.catalog.name}: ${services.catalog.description}'
                          : 'Çevrimiçi müzik için yukarıdan "Çevrimiçi"yi seçin. Kitaplığınızdaki dosyalar internetsiz çalınır.',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _online ? 'Çevrimiçi sonuçlar' : 'Yerel müzik',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (_online)
              _onlineBody(services, current)
            else if (all.isEmpty)
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
  const _CatalogNotice({required this.text});

  final String text;

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
                text,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
