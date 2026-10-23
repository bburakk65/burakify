import 'package:burakify/core/audio/track.dart';
import 'package:burakify/core/data/library_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final List<Track> tracks = <Track>[
    trackFromPath('/m/Gece_Yarisi.mp3'),
    trackFromPath('/m/amber_sabah.mp3'),
    trackFromPath('/m/Kiyi.flac'),
  ];

  test('boş veya boşluk sorgusu tüm listeyi döndürür', () {
    expect(filterTracks(tracks, ''), tracks);
    expect(filterTracks(tracks, '   '), tracks);
  });

  test('büyük/küçük harf fark etmez, başlığın herhangi bir yerinde eşleşir', () {
    expect(filterTracks(tracks, 'AMBER').map((Track t) => t.title),
        <String>['amber sabah']);
    expect(filterTracks(tracks, 'yar').map((Track t) => t.title),
        <String>['Gece Yarisi']);
  });

  test('eşleşme yoksa boş liste', () {
    expect(filterTracks(tracks, 'xyz'), isEmpty);
  });
}
