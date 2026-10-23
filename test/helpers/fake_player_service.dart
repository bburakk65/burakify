import 'dart:async';

import 'package:burakify/core/audio/player_service.dart';

/// Testler için sahte ses motoru: gerçek ses çalmaz, durumu elle yönetilir.
class FakePlayerService implements PlayerService {
  final StreamController<bool> _playing = StreamController<bool>.broadcast();
  final StreamController<Duration> _position =
      StreamController<Duration>.broadcast();
  final StreamController<Duration?> _duration =
      StreamController<Duration?>.broadcast();
  final StreamController<void> _completed = StreamController<void>.broadcast();

  final List<String> loadedPaths = <String>[];
  final Set<String> failingPaths = <String>{};
  final List<Duration> seeks = <Duration>[];
  bool playing = false;
  double volume = 1.0;
  bool disposed = false;

  @override
  Stream<bool> get playingStream => _playing.stream;
  @override
  Stream<Duration> get positionStream => _position.stream;
  @override
  Stream<Duration?> get durationStream => _duration.stream;
  @override
  Stream<void> get completedStream => _completed.stream;

  @override
  Future<void> load(String path) async {
    playing = false;
    _playing.add(false);
    if (failingPaths.contains(path)) {
      throw Exception('açılamadı: $path');
    }
    loadedPaths.add(path);
    _duration.add(const Duration(minutes: 3));
    _position.add(Duration.zero);
  }

  @override
  Future<void> play() async {
    playing = true;
    _playing.add(true);
  }

  @override
  Future<void> pause() async {
    playing = false;
    _playing.add(false);
  }

  @override
  Future<void> seek(Duration position) async {
    seeks.add(position);
    _position.add(position);
  }

  @override
  Future<void> setVolume(double v) async {
    volume = v;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }

  /// Testte: parçanın sonuna gelindiğini bildirir.
  void complete() => _completed.add(null);

  /// Testte: konum güncellemesi yollar.
  void emitPosition(Duration d) => _position.add(d);
}
