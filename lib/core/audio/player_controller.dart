import 'dart:async';

import 'package:flutter/foundation.dart';

import '../errors/app_log.dart';
import 'playback_queue.dart';
import 'player_service.dart';
import 'track.dart';

/// Oynatma durumunun tek bir değerle özeti (arayüz ve testler için).
enum PlaybackStatus { idle, loading, playing, paused, error }

/// Kuyruk + ses motorunu birleştirir ve arayüze durum sunar.
/// Arayüz animasyonlarından bağımsızdır; ses komutları animasyon beklemez.
class PlayerController extends ChangeNotifier {
  PlayerController(this._service, {PlaybackQueue? queue})
      : _queue = queue ?? PlaybackQueue() {
    _subs.add(_service.playingStream.listen((bool playing) {
      if (playing != _isPlaying) {
        _isPlaying = playing;
        _notify();
      }
    }));
    _subs.add(_service.positionStream.listen((Duration d) {
      if (!_disposed) {
        position.value = d;
      }
    }));
    _subs.add(_service.durationStream.listen((Duration? d) {
      if (!_disposed) {
        duration.value = d ?? Duration.zero;
      }
    }));
    _subs.add(_service.completedStream.listen((_) => _onCompleted()));
  }

  final PlayerService _service;
  final PlaybackQueue _queue;
  final List<StreamSubscription<Object?>> _subs =
      <StreamSubscription<Object?>>[];

  /// Sık güncellenen değerler ayrı tutulur; tüm arayüz yeniden çizilmesin.
  final ValueNotifier<Duration> position = ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<Duration> duration = ValueNotifier<Duration>(Duration.zero);

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _disposed = false;
  String? _errorMessage;
  String? _loadedId;
  double _volume = 1.0;
  int _loadToken = 0;

  /// Salt okunur kullanım içindir; değişiklikler bu denetleyici üzerinden yapılır.
  PlaybackQueue get queue => _queue;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PlaybackStatus get status {
    if (_queue.current == null) {
      return PlaybackStatus.idle;
    }
    if (_isLoading) {
      return PlaybackStatus.loading;
    }
    if (_errorMessage != null) {
      return PlaybackStatus.error;
    }
    return _isPlaying ? PlaybackStatus.playing : PlaybackStatus.paused;
  }
  double get volume => _volume;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// [tracks] kuyruğunu kurar ve [startIndex] parçasını çalar.
  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) async {
    _queue.setTracks(tracks, startIndex: startIndex);
    await _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    if (_disposed) {
      return;
    }
    final Track? track = _queue.current;
    final int token = ++_loadToken;
    if (track == null) {
      await _service.pause();
      _loadedId = null;
      _isLoading = false;
      position.value = Duration.zero;
      duration.value = Duration.zero;
      _notify();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    position.value = Duration.zero;
    _notify();
    try {
      await _service.load(track.path);
      if (_disposed || token != _loadToken) {
        return;
      }
      _loadedId = track.id;
      await _service.play();
    } catch (error) {
      AppLog.error('track_load_failed', error);
      if (_disposed || token != _loadToken) {
        return;
      }
      _loadedId = null;
      _errorMessage = 'Dosya açılamadı: ${track.title}';
      try {
        await _service.pause();
      } catch (_) {
        // Duraklatma da başarısızsa yapılacak başka bir şey yok.
      }
    } finally {
      if (!_disposed && token == _loadToken) {
        _isLoading = false;
        _notify();
      }
    }
  }

  Future<void> togglePlay() async {
    final Track? current = _queue.current;
    if (current == null) {
      return;
    }
    if (_isPlaying) {
      await _service.pause();
      return;
    }
    if (_loadedId != current.id || _errorMessage != null) {
      await _loadCurrent();
      return;
    }
    await _service.play();
  }

  Future<void> next() async {
    final Track? t = _queue.next();
    if (t == null) {
      await _service.pause();
      await _service.seek(Duration.zero);
      _notify();
      return;
    }
    await _loadCurrent();
  }

  Future<void> previous() async {
    if (_queue.current == null) {
      return;
    }
    if (position.value > const Duration(seconds: 3)) {
      await _service.seek(Duration.zero);
      return;
    }
    _queue.previous();
    await _loadCurrent();
  }

  Future<void> seek(Duration to) => _service.seek(to);

  Future<void> jumpTo(int trackIndex) async {
    if (_queue.jumpTo(trackIndex) == null) {
      return;
    }
    await _loadCurrent();
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0).toDouble();
    _notify();
    await _service.setVolume(_volume);
  }

  void toggleShuffle() {
    _queue.toggleShuffle();
    _notify();
  }

  void cycleRepeat() {
    _queue.cycleRepeat();
    _notify();
  }

  /// Parçaları kuyruğun sonuna ekler; eklenen sayıyı döndürür.
  int addToQueue(Iterable<Track> tracks) {
    final int added = _queue.addAll(tracks);
    if (added > 0) {
      _notify();
    }
    return added;
  }

  Future<void> removeFromQueue(int trackIndex) async {
    final bool wasCurrent = _queue.removeAt(trackIndex);
    _notify();
    if (wasCurrent) {
      await _loadCurrent();
    }
  }

  Future<void> clearQueue() async {
    _queue.clear();
    await _loadCurrent();
  }

  Future<void> _onCompleted() async {
    if (_disposed) {
      return;
    }
    if (_queue.repeat == PlaybackRepeat.one) {
      await _service.seek(Duration.zero);
      await _service.play();
      return;
    }
    await next();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final StreamSubscription<Object?> s in _subs) {
      s.cancel();
    }
    position.dispose();
    duration.dispose();
    _service.dispose();
    super.dispose();
  }
}
