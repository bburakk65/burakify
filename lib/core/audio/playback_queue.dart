import 'dart:math';

import 'track.dart';

enum RepeatMode { off, all, one }

/// Saf (arayüzden ve sesten bağımsız) oynatma kuyruğu mantığı.
///
/// `_tracks` kullanıcıya görünen sıradır. `_order` çalma sırasını (karıştırma
/// açıkken farklı olabilir) `_tracks` indeksleri olarak tutar.
class PlaybackQueue {
  PlaybackQueue({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<Track> _tracks = <Track>[];
  List<int> _order = <int>[];
  int _position = -1;
  bool _shuffle = false;
  RepeatMode _repeat = RepeatMode.off;

  List<Track> get tracks => List<Track>.unmodifiable(_tracks);
  bool get isEmpty => _tracks.isEmpty;
  bool get shuffle => _shuffle;
  RepeatMode get repeat => _repeat;

  Track? get current => (_position >= 0 && _position < _order.length)
      ? _tracks[_order[_position]]
      : null;

  /// Geçerli parçanın [tracks] içindeki indeksi.
  int? get currentIndex => (_position >= 0 && _position < _order.length)
      ? _order[_position]
      : null;

  bool get hasNext =>
      current != null &&
      (_position < _order.length - 1 || _repeat == RepeatMode.all);

  /// Kuyruğu değiştirir ve [startIndex] parçasını geçerli yapar.
  void setTracks(List<Track> tracks, {int startIndex = 0}) {
    _tracks
      ..clear()
      ..addAll(tracks);
    if (_tracks.isEmpty) {
      _order = <int>[];
      _position = -1;
      return;
    }
    final int first = startIndex.clamp(0, _tracks.length - 1).toInt();
    _rebuildOrder(first);
  }

  void _rebuildOrder(int firstIndex) {
    final int n = _tracks.length;
    if (!_shuffle) {
      _order = List<int>.generate(n, (int i) => i);
      _position = firstIndex;
      return;
    }
    final List<int> rest = <int>[
      for (int i = 0; i < n; i++)
        if (i != firstIndex) i,
    ]..shuffle(_random);
    _order = <int>[firstIndex, ...rest];
    _position = 0;
  }

  void toggleShuffle() {
    final int? cur = currentIndex;
    _shuffle = !_shuffle;
    if (cur != null) {
      _rebuildOrder(cur);
    }
  }

  void cycleRepeat() {
    switch (_repeat) {
      case RepeatMode.off:
        _repeat = RepeatMode.all;
      case RepeatMode.all:
        _repeat = RepeatMode.one;
      case RepeatMode.one:
        _repeat = RepeatMode.off;
    }
  }

  /// Sonraki parçaya geçer. Sıra bittiyse ve tekrar "tümü" değilse null döner
  /// (geçerli parça değişmez).
  Track? next() {
    if (_tracks.isEmpty) {
      return null;
    }
    if (_position < _order.length - 1) {
      _position++;
      return current;
    }
    if (_repeat == RepeatMode.all) {
      if (_shuffle) {
        _rebuildOrder(_random.nextInt(_tracks.length));
      } else {
        _position = 0;
      }
      return current;
    }
    return null;
  }

  /// Önceki parçaya geçer; başta ve tekrar "tümü" değilse geçerli parçada kalır.
  Track? previous() {
    if (_tracks.isEmpty) {
      return null;
    }
    if (_position > 0) {
      _position--;
    } else if (_repeat == RepeatMode.all) {
      _position = _order.length - 1;
    }
    return current;
  }

  /// [trackIndex] ([tracks] indeksi) parçasını geçerli yapar.
  Track? jumpTo(int trackIndex) {
    if (trackIndex < 0 || trackIndex >= _tracks.length) {
      return null;
    }
    final int p = _order.indexOf(trackIndex);
    if (p < 0) {
      return null;
    }
    _position = p;
    return current;
  }

  /// Zaten kuyrukta olmayan parçaları sona ekler; eklenen sayıyı döndürür.
  int addAll(Iterable<Track> tracks) {
    final Set<String> known = _tracks.map((Track t) => t.id).toSet();
    final List<int> newIndices = <int>[];
    for (final Track t in tracks) {
      if (known.add(t.id)) {
        _tracks.add(t);
        newIndices.add(_tracks.length - 1);
      }
    }
    if (newIndices.isEmpty) {
      return 0;
    }
    if (_shuffle) {
      newIndices.shuffle(_random);
    }
    final bool wasEmpty = _order.isEmpty;
    _order.addAll(newIndices);
    if (wasEmpty) {
      _position = 0;
    }
    return newIndices.length;
  }

  /// [trackIndex] parçasını kaldırır. Kaldırılan geçerli parçaysa true döner;
  /// çağıran yeni geçerli parçayı yüklemelidir.
  bool removeAt(int trackIndex) {
    if (trackIndex < 0 || trackIndex >= _tracks.length) {
      return false;
    }
    final int removedPos = _order.indexOf(trackIndex);
    final bool wasCurrent = removedPos == _position;
    _tracks.removeAt(trackIndex);
    _order = <int>[
      for (final int i in _order)
        if (i != trackIndex) (i > trackIndex ? i - 1 : i),
    ];
    if (_tracks.isEmpty) {
      _position = -1;
      return wasCurrent;
    }
    if (removedPos < _position) {
      _position--;
    } else if (_position >= _order.length) {
      _position = _order.length - 1;
    }
    return wasCurrent;
  }

  void clear() {
    _tracks.clear();
    _order = <int>[];
    _position = -1;
  }
}
