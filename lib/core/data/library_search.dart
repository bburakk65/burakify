import '../audio/track.dart';

/// Başlığında [query] geçen parçaları döndürür (büyük/küçük harf fark etmez).
/// Boş sorguda tüm liste döner.
List<Track> filterTracks(List<Track> tracks, String query) {
  final String q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return tracks;
  }
  return tracks
      .where((Track t) => t.title.toLowerCase().contains(q))
      .toList();
}
