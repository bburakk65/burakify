import 'package:flutter/material.dart';

/// Albüm kapağı yoksa gösterilen, parçaya özgü renkli yer tutucu.
/// [size] verilmezse bulunduğu alanı doldurur.
class CoverPlaceholder extends StatelessWidget {
  const CoverPlaceholder({super.key, required this.seed, this.size});

  final String seed;
  final double? size;

  static int _hash(String s) {
    int h = 7;
    for (final int c in s.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final double hue = (_hash(seed) % 360).toDouble();
    final Color a = HSLColor.fromAHSL(1, hue, 0.45, 0.38).toColor();
    final Color b = HSLColor.fromAHSL(1, (hue + 40) % 360, 0.5, 0.22).toColor();
    final Widget box = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[a, b],
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, color: Colors.white70, size: 40),
      ),
    );
    final double? s = size;
    return Semantics(
      label: 'Albüm kapağı yer tutucusu',
      child: s == null ? box : SizedBox(width: s, height: s, child: box),
    );
  }
}

/// Boş durum: simge, başlık, açıklama ve isteğe bağlı eylem.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionKey,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...<Widget>[
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: actionKey,
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Yükleme göstergesi. Yalnızca gerçek bir bekleme sürerken kullanılır;
/// yüzde göstermez (ilerleme bilinmiyor), her kullanımın bir zaman aşımı olmalıdır.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Yükleniyor…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Hata durumu: anlaşılır mesaj ve "Tekrar dene" eylemi.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('retry_button'),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
