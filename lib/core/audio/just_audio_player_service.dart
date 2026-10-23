import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'player_service.dart';

/// `just_audio` tabanlı gerçek ses oynatma.
///
/// KAPSAM: Yalnızca uygulama açıkken çalma. Arka plan servisi, bildirim ve
/// kilit ekranı kontrolleri (`audio_service`) bu dosyada YOK; ayrı aşamada
/// eklenecek (bkz. docs/10-PLAYBACK-ANDROID-REQUIREMENTS.md).
/// NOT: Bu dosya bu ortamda derlenmedi/test edilmedi (Flutter SDK yok).
class JustAudioPlayerService implements PlayerService {
  JustAudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Stream<bool> get playingStream => _player.playingStream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<void> get completedStream => _player.processingStateStream
      .where((ProcessingState s) => s == ProcessingState.completed)
      .map((ProcessingState _) {});

  @override
  Future<void> load(String path) async {
    // Önceki parçayı durdur; yükleme başarısız olursa eski ses çalmaya devam etmesin.
    await _player.stop();
    await _player.setFilePath(path);
  }

  @override
  Future<void> play() async {
    // just_audio'da play() çalma bitene/duraklayana kadar tamamlanmaz; beklenmez.
    unawaited(_player.play().catchError((Object _) {}));
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> dispose() => _player.dispose();
}
