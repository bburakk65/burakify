import 'package:flutter/material.dart';

import '../../core/design/logo.dart';
import '../../features/home/home_page.dart';
import '../../features/library/library_page.dart';
import '../../features/player/desktop_player_bar.dart';
import '../../features/player/mini_player.dart';
import '../../features/player/now_playing_view.dart';
import '../../features/player/queue_view.dart';
import '../../features/settings/settings_page.dart';
import '../actions.dart';
import '../app_scope.dart';
import '../file_drop_zone.dart';
import '../layout/form_factor.dart';
import '../shortcuts.dart';

class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const List<_Destination> _destinations = <_Destination>[
  _Destination(Icons.home_outlined, Icons.home, 'Ana Sayfa'),
  _Destination(Icons.library_music_outlined, Icons.library_music, 'Kitaplık'),
  _Destination(Icons.queue_music_outlined, Icons.queue_music, 'Kuyruk'),
  _Destination(Icons.settings_outlined, Icons.settings, 'Ayarlar'),
];

/// Genişliğe ve platforma göre telefon, tablet veya Windows düzenini seçer.
/// Seçili sekme, arama metni ve panel durumu, pencere boyutu/yön değişse de korunur.
/// Geri (Android geri tuşu): Ana Sayfa dışındaki bir sekmedeyken Ana Sayfa'ya döner,
/// Ana Sayfa'dayken uygulamadan çıkar.
class AdaptiveShell extends StatefulWidget {
  const AdaptiveShell({super.key});

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  final GlobalKey<ScaffoldState> _desktopScaffoldKey =
      GlobalKey<ScaffoldState>();
  // Ana Sayfa'nın arama metni, düzen değişince (ör. yön değişimi) kaybolmasın.
  final GlobalKey _homeKey = GlobalKey(debugLabel: 'home');
  int _index = 0;
  bool _queuePanelOpen = true;
  bool _wideDesktop = true;

  void _select(int i) => setState(() => _index = i);

  void _toggleQueue() {
    if (_wideDesktop) {
      setState(() => _queuePanelOpen = !_queuePanelOpen);
    } else {
      _desktopScaffoldKey.currentState?.openEndDrawer();
    }
  }

  Widget _page(FormFactor ff) {
    switch (_index) {
      case 0:
        return HomePage(key: _homeKey, formFactor: ff);
      case 1:
        return LibraryPage(formFactor: ff);
      case 2:
        return QueueView(
          key: const Key('queue_page'),
          padding: ff == FormFactor.phone ? 16 : 24,
        );
      default:
        return SettingsPage(formFactor: ff);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _select(0);
        }
      },
      child: PlayerShortcuts(
        onToggleQueuePanel: _toggleQueue,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            switch (formFactorFor(width: width, platform: platform)) {
              case FormFactor.phone:
                return _phone(context);
              case FormFactor.tablet:
                return _tablet(context, width);
              case FormFactor.desktop:
                return _desktop(context, width);
            }
          },
        ),
      ),
    );
  }

  Widget _phone(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Expanded(child: _page(FormFactor.phone)),
            MiniPlayer(onTap: () => openFullPlayer(context)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: <Widget>[
          for (final _Destination d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }

  /// Tablet: sol gezinme rayı + içerik; yeterince genişse sağda kalıcı
  /// "çalıyor" paneli, değilse alt mini oynatıcı ve tam ekran sayfa.
  Widget _tablet(BuildContext context, double width) {
    final AppServices services = AppScope.of(context);
    final bool sidePane = width >= kTabletSidePaneMinWidth;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: FloatingActionButton.small(
                  key: const Key('rail_add_button'),
                  tooltip: 'Dosya ekle (Ctrl+O)',
                  onPressed: () => pickAndImport(context, services),
                  child: const Icon(Icons.add),
                ),
              ),
              destinations: <NavigationRailDestination>[
                for (final _Destination d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(child: _page(FormFactor.tablet)),
                  if (!sidePane)
                    MiniPlayer(onTap: () => openFullPlayer(context)),
                ],
              ),
            ),
            if (sidePane) ...<Widget>[
              const VerticalDivider(width: 1),
              const SizedBox(
                key: Key('now_playing_pane'),
                width: 380,
                child: NowPlayingView(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Windows: sol yan menü, merkez içerik, isteğe bağlı sağ kuyruk paneli ve
  /// alt oynatıcı çubuğu. Dar pencerede kuyruk çekmece olarak açılır.
  Widget _desktop(BuildContext context, double width) {
    final AppServices services = AppScope.of(context);
    _wideDesktop = width >= kQueuePanelMinWidth;
    final bool showQueuePanel = _wideDesktop && _queuePanelOpen;
    return FileDropZone(
      onPaths: (List<String> paths) =>
          importPaths(ScaffoldMessenger.of(context), services, paths),
      child: Scaffold(
        key: _desktopScaffoldKey,
        endDrawer: _wideDesktop
            ? null
            : const Drawer(child: SafeArea(child: QueueView())),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  _Sidebar(
                    selectedIndex: _index,
                    onSelect: _select,
                    onAdd: () => pickAndImport(context, services),
                  ),
                  Expanded(child: _page(FormFactor.desktop)),
                  if (showQueuePanel) ...<Widget>[
                    const VerticalDivider(width: 1),
                    const SizedBox(
                      key: Key('queue_panel'),
                      width: 320,
                      child: QueueView(),
                    ),
                  ],
                ],
              ),
            ),
            DesktopPlayerBar(
              queuePanelOpen: showQueuePanel,
              onToggleQueue: _toggleQueue,
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedIndex,
    required this.onSelect,
    required this.onAdd,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // ListTile, arka planını en yakın Material üzerine boyar; bu yüzden renk
    // Container/ColoredBox yerine Material ile verilir.
    return Material(
      key: const Key('desktop_sidebar'),
      color: theme.colorScheme.surfaceContainerLow,
      child: SizedBox(
        width: 232,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const BurakifyLogo(size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Burakify',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              for (int i = 0; i < _destinations.length; i++)
                ListTile(
                  selected: i == selectedIndex,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    i == selectedIndex
                        ? _destinations[i].selectedIcon
                        : _destinations[i].icon,
                  ),
                  title: Text(_destinations[i].label),
                  onTap: () => onSelect(i),
                ),
              const Spacer(),
              FilledButton.tonalIcon(
                key: const Key('sidebar_add_button'),
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Dosya ekle'),
              ),
              const SizedBox(height: 8),
              Text(
                'Ctrl+O',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
