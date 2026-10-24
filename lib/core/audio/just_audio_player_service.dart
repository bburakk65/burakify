import 'dart:async';

import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:just_audio/just_audio.dart';

import 'player_service.dart';
import 'track.dart';

/// `just_audio` tabanlı gerçek ses oynatma (yerel dosya ve internet akışı).
///
/// Android'de [initBackgroundAudio] (background_audio.dart) çağrılmışsa
/// `just_audio_background` devreye girer: ekran kapalıyken çalma, bildirim ve
/// kilit ekranı kontrolleri. Her parçaya [MediaItem] etiketi bu yüzden verilir;
/// Windows'ta etiket yok sayılır.
/// NOT: Bu dosya bu ortamda derlenmedi (Flutter SDK yok); doğrulama CI ve cihazdadır.
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
  Future<void> load(
    String path, {
    String title = '',
    String artist = '',
  }) async {
    // Önceki parçayı durdur; yükleme başarısız olursa eski ses çalmaya devam etmesin.
    await _player.stop();
    final MediaItem item = MediaItem(
      id: path,
      title: title.isEmpty ? titleFromPath(path) : title,
      artist: artist.isEmpty ? null : artist,
    );
    if (isOnlinePath(path)) {
      await _player.setUrl(path, tag: item);
    } else {
      await _player.setFilePath(path, tag: item);
    }
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
