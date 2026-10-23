import 'package:burakify/core/audio/player_controller.dart';
import 'package:burakify/core/audio/track.dart';
import 'package:burakify/core/errors/app_log.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_player_service.dart';

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakePlayerService service;
  late PlayerController player;

  setUp(() {
    AppLog.sink = (String _) {};
    service = FakePlayerService();
    player = PlayerController(service);
  });

  tearDown(() => player.dispose());

  test('kuyruk boşken durum idle', () {
    expect(player.status, PlaybackStatus.idle);
  });

  test('çalarken playing, duraklatınca paused', () async {
    await player.playTracks(<Track>[trackFromPath('/m/a.mp3')]);
    await _settle();
    expect(player.status, PlaybackStatus.playing);
    await player.togglePlay();
    await _settle();
    expect(player.status, PlaybackStatus.paused);
  });

  test('açılamayan dosyada durum error', () async {
    service.failingPaths.add('/m/bozuk.mp3');
    await player.playTracks(<Track>[trackFromPath('/m/bozuk.mp3')]);
    await _settle();
    expect(player.status, PlaybackStatus.error);
  });
}
