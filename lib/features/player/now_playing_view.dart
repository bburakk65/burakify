import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/animation/motion.dart';
import '../../core/audio/player_controller.dart';
import '../../core/audio/track.dart';
import '../../core/design/components.dart';
import 'transport_controls.dart';

/// Büyük "çalıyor" alanı. Telefon/tablet tam ekran sayfasında ve tablette
/// geniş ekranda sağ panelde kullanılır.
class NowPlayingView extends StatelessWidget {
  const NowPlayingView({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController player = AppScope.of(context).player;
    return ListenableBuilder(
      listenable: player,
      builder: (BuildContext context, Widget? _) {
        final Track? track = player.queue.current;
        if (track == null) {
          return const EmptyState(
            icon: Icons.music_note_rounded,
            title: 'Çalan şarkı yok',
            message: 'Kitaplıktan bir şarkı seçin.',
          );
        }
        final ThemeData theme = Theme.of(context);
        final Duration switchDuration =
            BurakifyMotion.duration(context, BurakifyMotion.medium);
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final double cover = math
                .min(c.maxWidth - 48, c.maxHeight * 0.45)
                .clamp(120.0, 420.0)
                .toDouble();
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AnimatedSwitcher(
                          duration: switchDuration,
                          child: CoverPlaceholder(
                            key: ValueKey<String>('cover_${track.id}'),
                            seed: track.id,
                            size: cover,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: switchDuration,
                          child: Text(
                            track.title,
                            key: ValueKey<String>('title_${track.id}'),
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (player.errorMessage != null) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            player.errorMessage!,
                            key: const Key('player_error'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 16),
                        SeekBar(player: player),
                        const SizedBox(height: 8),
                        TransportControls(player: player),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Telefon ve tablet dikey yönde mini oynatıcıdan açılan tam ekran sayfa.
class FullPlayerPage extends StatelessWidget {
  const FullPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Küçült',
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Çalıyor'),
      ),
      body: const SafeArea(child: NowPlayingView()),
    );
  }
}

/// Mini oynatıcıdan tam oynatıcıya akıcı geçiş (alttan yükselme + solma).
/// Azaltılmış harekette yalnızca kısa solma kullanılır.
Future<void> openFullPlayer(BuildContext context) {
  final Duration duration =
      BurakifyMotion.duration(context, BurakifyMotion.medium);
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (BuildContext _, Animation<double> __, Animation<double> ___) =>
          const FullPlayerPage(),
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondary,
        Widget child,
      ) {
        final Animation<double> curved = CurvedAnimation(
          parent: animation,
          curve: BurakifyMotion.standard,
        );
        if (BurakifyMotion.reduced(context)) {
          return FadeTransition(opacity: curved, child: child);
        }
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}
