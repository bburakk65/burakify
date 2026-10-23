import 'package:flutter/foundation.dart';

import '../audio/track.dart';

class AddResult {
  const AddResult({
    required this.added,
    required this.duplicates,
    required this.unsupported,
  });

  final int added;
  final int duplicates;
  final int unsupported;
}

/// Kullanıcının eklediği yerel müzik dosyaları (şimdilik yalnızca bellekte;
/// uygulama kapanınca liste kaybolur, kalıcı kitaplık sonraki aşamada).
class LibraryController extends ChangeNotifier {
  final List<Track> _tracks = <Track>[];

  List<Track> get tracks => List<Track>.unmodifiable(_tracks);

  AddResult addPaths(Iterable<String> paths) {
    int added = 0;
    int duplicates = 0;
    int unsupported = 0;
    for (final String path in paths) {
      if (!isSupportedAudioPath(path)) {
        unsupported++;
        continue;
      }
      final Track track = trackFromPath(path);
      if (_tracks.contains(track)) {
        duplicates++;
        continue;
      }
      _tracks.add(track);
      added++;
    }
    if (added > 0) {
      notifyListeners();
    }
    return AddResult(
      added: added,
      duplicates: duplicates,
      unsupported: unsupported,
    );
  }
}
