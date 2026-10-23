import 'dart:math';

import 'package:burakify/core/audio/playback_queue.dart';
import 'package:burakify/core/audio/track.dart';
import 'package:flutter_test/flutter_test.dart';

List<Track> _tracks(int n) =>
    List<Track>.generate(n, (int i) => trackFromPath('/m/t$i.mp3'));

void main() {
  test('boş kuyrukta geçerli parça yok, next/previous null', () {
    final PlaybackQueue q = PlaybackQueue();
    expect(q.current, isNull);
    expect(q.next(), isNull);
    expect(q.previous(), isNull);
  });

  test('setTracks başlangıç indeksini geçerli yapar', () {
    final PlaybackQueue q = PlaybackQueue()..setTracks(_tracks(3), startIndex: 1);
    expect(q.current!.title, 't1');
    expect(q.currentIndex, 1);
  });

  test('next sona gelince repeat off ise null döner ve parça değişmez', () {
    final PlaybackQueue q = PlaybackQueue()..setTracks(_tracks(2));
    expect(q.next()!.title, 't1');
    expect(q.next(), isNull);
    expect(q.current!.title, 't1');
  });

  test('repeat all sonda başa sarar, başta previous sona gider', () {
    final PlaybackQueue q = PlaybackQueue()
      ..setTracks(_tracks(3))
      ..cycleRepeat();
    expect(q.repeat, RepeatMode.all);
    q.next();
    q.next();
    expect(q.next()!.title, 't0');
    expect(q.previous()!.title, 't2');
  });

  test('repeat döngüsü off -> all -> one -> off', () {
    final PlaybackQueue q = PlaybackQueue();
    q.cycleRepeat();
    q.cycleRepeat();
    expect(q.repeat, RepeatMode.one);
    q.cycleRepeat();
    expect(q.repeat, RepeatMode.off);
  });

  test('karıştırma geçerli parçayı korur ve her parçayı bir kez içerir', () {
    final PlaybackQueue q = PlaybackQueue(random: Random(42))
      ..setTracks(_tracks(6), startIndex: 3)
      ..toggleShuffle();
    expect(q.current!.title, 't3');
    final Set<String> seen = <String>{q.current!.title};
    while (true) {
      final Track? t = q.next();
      if (t == null) {
        break;
      }
      seen.add(t.title);
    }
    expect(seen.length, 6);
  });

  test('karıştırmayı kapatınca geçerli parça aynı kalır', () {
    final PlaybackQueue q = PlaybackQueue(random: Random(1))
      ..setTracks(_tracks(5), startIndex: 2)
      ..toggleShuffle()
      ..toggleShuffle();
    expect(q.current!.title, 't2');
    expect(q.next()!.title, 't3');
  });

  test('jumpTo geçerli parçayı değiştirir, geçersiz indeks null', () {
    final PlaybackQueue q = PlaybackQueue()..setTracks(_tracks(4));
    expect(q.jumpTo(2)!.title, 't2');
    expect(q.jumpTo(9), isNull);
    expect(q.current!.title, 't2');
  });

  test('addAll mükerrerleri eklemez, boş kuyrukta ilk parçayı geçerli yapar', () {
    final PlaybackQueue q = PlaybackQueue();
    expect(q.addAll(_tracks(2)), 2);
    expect(q.addAll(_tracks(3)), 1);
    expect(q.tracks.length, 3);
    expect(q.current!.title, 't0');
  });

  test('removeAt: geçerli olmayan parça kaldırılınca geçerli parça korunur', () {
    final PlaybackQueue q = PlaybackQueue()..setTracks(_tracks(4), startIndex: 2);
    expect(q.removeAt(0), isFalse);
    expect(q.current!.title, 't2');
    expect(q.tracks.length, 3);
  });

  test('removeAt: geçerli parça kaldırılınca true döner ve yenisi seçilir', () {
    final PlaybackQueue q = PlaybackQueue()..setTracks(_tracks(3), startIndex: 1);
    expect(q.removeAt(1), isTrue);
    expect(q.current!.title, 't2');
  });

  test('removeAt: son parça kaldırılınca kuyruk boşalır', () {
    final PlaybackQueue q = PlaybackQueue()..setTracks(_tracks(1));
    expect(q.removeAt(0), isTrue);
    expect(q.current, isNull);
    expect(q.isEmpty, isTrue);
  });
}
