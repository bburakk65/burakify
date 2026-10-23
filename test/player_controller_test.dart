import 'package:burakify/core/audio/playback_queue.dart';
import 'package:burakify/core/audio/player_controller.dart';
import 'package:burakify/core/audio/track.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_player_service.dart';

Future<void> _settle() => Future<void>.delayed(Duration.zero);

List<Track> _tracks(int n) =>
    List<Track>.generate(n, (int i) => trackFromPath('/m/t$i.mp3'));

void main() {
  late FakePlayerService service;
  late PlayerController player;

  setUp(() {
    service = FakePlayerService();
    player = PlayerController(service);
  });

  tearDown(() => player.dispose());

  test('playTracks ilk parçayı yükler ve çalar', () async {
    await player.playTracks(_tracks(3));
    await _settle();
    expect(service.loadedPaths, <String>['/m/t0.mp3']);
    expect(player.isPlaying, isTrue);
    expect(player.errorMessage, isNull);
  });

  test('next sonraki parçayı yükler', () async {
    await player.playTracks(_tracks(3));
    await player.next();
    expect(service.loadedPaths.last, '/m/t1.mp3');
  });

  test('kuyruğun sonunda next duraklatır ve başa sarar', () async {
    await player.playTracks(_tracks(1));
    await player.next();
    await _settle();
    expect(player.isPlaying, isFalse);
    expect(service.seeks.last, Duration.zero);
  });

  test('3 saniyeden sonra previous aynı parçayı başa sarar', () async {
    await player.playTracks(_tracks(3), startIndex: 1);
    service.emitPosition(const Duration(seconds: 10));
    await _settle();
    await player.previous();
    expect(service.loadedPaths.length, 1);
    expect(service.seeks.last, Duration.zero);
  });

  test('3 saniyeden önce previous önceki parçaya geçer', () async {
    await player.playTracks(_tracks(3), startIndex: 1);
    await player.previous();
    expect(service.loadedPaths.last, '/m/t0.mp3');
  });

  test('açılamayan dosyada hata mesajı gösterilir, kuyruk korunur', () async {
    service.failingPaths.add('/m/t0.mp3');
    await player.playTracks(_tracks(2));
    await _settle();
    expect(player.errorMessage, contains('t0'));
    expect(player.isPlaying, isFalse);
    expect(player.isLoading, isFalse);
    expect(player.queue.tracks.length, 2);
  });

  test('hatadan sonra sonraki parça çalışır ve hata temizlenir', () async {
    service.failingPaths.add('/m/t0.mp3');
    await player.playTracks(_tracks(2));
    await player.next();
    await _settle();
    expect(player.errorMessage, isNull);
    expect(player.isPlaying, isTrue);
  });

  test('parça bitince sonrakine geçer', () async {
    await player.playTracks(_tracks(2));
    service.complete();
    await _settle();
    await _settle();
    expect(service.loadedPaths.last, '/m/t1.mp3');
  });

  test('repeat one: parça bitince aynı parça başa sarılıp çalınır', () async {
    await player.playTracks(_tracks(2));
    player.cycleRepeat();
    player.cycleRepeat();
    expect(player.queue.repeat, PlaybackRepeat.one);
    service.complete();
    await _settle();
    await _settle();
    expect(service.loadedPaths.length, 1);
    expect(service.seeks.last, Duration.zero);
    expect(service.playing, isTrue);
  });

  test('togglePlay duraklatır ve yeniden çalar', () async {
    await player.playTracks(_tracks(1));
    await _settle();
    await player.togglePlay();
    await _settle();
    expect(player.isPlaying, isFalse);
    await player.togglePlay();
    await _settle();
    expect(player.isPlaying, isTrue);
  });

  test('geçerli parça kuyruktan kaldırılınca sıradaki yüklenir', () async {
    await player.playTracks(_tracks(3));
    await player.removeFromQueue(0);
    expect(service.loadedPaths.last, '/m/t1.mp3');
    expect(player.queue.tracks.length, 2);
  });

  test('kuyruk temizlenince oynatma durur', () async {
    await player.playTracks(_tracks(2));
    await player.clearQueue();
    await _settle();
    expect(player.queue.current, isNull);
    expect(player.isPlaying, isFalse);
  });

  test('ses seviyesi 0-1 aralığına sıkıştırılır', () async {
    await player.setVolume(3);
    expect(player.volume, 1.0);
    expect(service.volume, 1.0);
    await player.setVolume(-1);
    expect(player.volume, 0.0);
  });
}
