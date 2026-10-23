import 'package:flutter/material.dart';

import '../../app/app_info.dart';
import '../../app/app_scope.dart';
import '../../app/layout/form_factor.dart';
import '../../core/data/settings_controller.dart';

/// Ayarlar: tema seçimi ve uygulamanın durum bilgileri.
/// Henüz yazılmamış özellikler "sonraki aşama" olarak açıkça belirtilir.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.formFactor});

  final FormFactor formFactor;

  Future<void> _changeTheme(
    BuildContext context,
    SettingsController settings,
    ThemeMode mode,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool saved = await settings.setThemeMode(mode);
    if (!saved) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Tema bu oturum için değişti ama kaydedilemedi; uygulama yeniden açılınca eski ayar dönebilir.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = AppScope.of(context).settings;
    final ThemeData theme = Theme.of(context);
    final double pad = formFactor == FormFactor.phone ? 16 : 24;
    return ListenableBuilder(
      listenable: settings,
      builder: (BuildContext context, Widget? _) {
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: EdgeInsets.all(pad),
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text('Ayarlar', style: theme.textTheme.headlineSmall),
                ),
                const SizedBox(height: 24),
                Text('Tema', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  key: const Key('theme_selector'),
                  segments: const <ButtonSegment<ThemeMode>>[
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text('Koyu'),
                      icon: Icon(Icons.dark_mode),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('Açık'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('Sistem'),
                      icon: Icon(Icons.settings_suggest),
                    ),
                  ],
                  selected: <ThemeMode>{settings.themeMode},
                  onSelectionChanged: (Set<ThemeMode> s) =>
                      _changeTheme(context, settings, s.first),
                ),
                const SizedBox(height: 32),
                Text('Durum', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                const _StatusRow(
                  icon: Icons.cloud_off_outlined,
                  title: 'Çevrimiçi müzik kataloğu',
                  value: 'Bağlı değil',
                ),
                const _StatusRow(
                  icon: Icons.notifications_none,
                  title: 'Arka planda çalma ve bildirim denetimleri',
                  value: 'Sonraki aşamada eklenecek',
                ),
                const _StatusRow(
                  icon: Icons.system_update_alt,
                  title: 'Uygulama içi güncelleme',
                  value: 'Sonraki aşamada eklenecek',
                ),
                const _StatusRow(
                  icon: Icons.info_outline,
                  title: 'Sürüm',
                  value: kAppVersion,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
