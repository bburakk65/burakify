import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../audio/track.dart';
import 'catalog_source.dart';

/// Internet Archive (archive.org) kaynağı: anahtar gerektirmez, ücretsizdir.
///
/// YASAL: Yalnızca öğenin üst verisinde Creative Commons veya kamu malı lisans
/// adresi (`licenseurl`) bulunan kayıtlar listelenir; lisansı belirtilmemiş
/// kayıtlar gösterilmez. Ses dosyaları archive.org'dan doğrudan akıtılır,
/// Burakify bunları kopyalamaz veya kalıcı olarak kaydetmez.
/// NOT: Bu sınıf bu ortamda gerçek ağa karşı denenemedi; testler sahte HTTP ile.
class InternetArchiveCatalog implements CatalogSource {
  InternetArchiveCatalog({http.Client? client, this.maxItems = 12})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// Bir aramada üst verisine bakılacak en fazla öğe sayısı.
  final int maxItems;

  static const int _maxTracksPerItem = 3;
  static const int _maxTracks = 30;
  static const Duration _timeout = Duration(seconds: 15);

  @override
  String get name => 'Internet Archive';

  @override
  String get description =>
      'Creative Commons / kamu malı lisanslı müzikler, archive.org üzerinden akıtılır. '
      'Katalog tam bir ticari müzik kataloğu değildir.';

  /// Lucene özel karakterlerini boşluğa çevirir, boşlukları sadeleştirir.
  static String sanitizeQuery(String raw) {
    return raw
        .replaceAll(RegExp(r'[+\-&|!(){}\[\]^"~*?:\\/]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Future<List<Track>> search(String query) async {
    final String q = sanitizeQuery(query);
    if (q.isEmpty) {
      return const <Track>[];
    }
    try {
      List<_Hit> hits = await _searchHits(q, licensedOnly: true);
      if (hits.isEmpty) {
        // Lisans filtresi bazı kayıtları kaçırabilir; üst veride yine denetlenir.
        hits = await _searchHits(q, licensedOnly: false);
      }
      final List<List<Track>> perItem = await Future.wait(
        hits.map(_tracksOf),
      );
      final List<Track> all = <Track>[];
      final Set<String> seen = <String>{};
      for (final List<Track> list in perItem) {
        for (final Track t in list) {
          if (seen.add(t.id) && all.length < _maxTracks) {
            all.add(t);
          }
        }
      }
      return all;
    } on CatalogException {
      rethrow;
    } on TimeoutException {
      throw const CatalogException(
        'Sunucu zamanında yanıt vermedi. Bağlantınızı kontrol edip tekrar deneyin.',
      );
    } on http.ClientException {
      throw const CatalogException(
        'İnternete ulaşılamadı. Bağlantınızı kontrol edip tekrar deneyin.',
      );
    } on FormatException {
      throw const CatalogException('Sunucudan beklenmeyen bir yanıt geldi.');
    }
  }

  Future<List<_Hit>> _searchHits(String q, {required bool licensedOnly}) async {
    final String license =
        licensedOnly ? ' AND licenseurl:*creativecommons*' : '';
    final Uri uri = Uri.https('archive.org', '/advancedsearch.php', <String, dynamic>{
      'q': '(title:($q) OR creator:($q)) AND mediatype:audio$license',
      'fl[]': <String>['identifier', 'title', 'creator'],
      'sort[]': 'downloads desc',
      'rows': '$maxItems',
      'page': '1',
      'output': 'json',
    });
    final http.Response r = await _client.get(uri).timeout(_timeout);
    if (r.statusCode != 200) {
      throw CatalogException(
        'Katalog şu an yanıt vermiyor (kod ${r.statusCode}). Sonra tekrar deneyin.',
      );
    }
    final Object? body = jsonDecode(utf8.decode(r.bodyBytes));
    final Object? response = body is Map<String, dynamic> ? body['response'] : null;
    final Object? docs = response is Map<String, dynamic> ? response['docs'] : null;
    if (docs is! List<dynamic>) {
      throw const FormatException('docs yok');
    }
    final List<_Hit> hits = <_Hit>[];
    for (final Object? d in docs) {
      if (d is Map<String, dynamic> && d['identifier'] is String) {
        hits.add(_Hit(
          d['identifier'] as String,
          _text(d['title']),
          _text(d['creator']),
        ));
      }
    }
    return hits;
  }

  /// Bir öğenin üst verisinden çalınabilir, lisanslı mp3/ogg parçalarını çıkarır.
  /// Tek bir öğe başarısız olursa yalnızca o öğe atlanır.
  Future<List<Track>> _tracksOf(_Hit hit) async {
    try {
      final Uri uri = Uri.https('archive.org', '/metadata/${hit.identifier}');
      final http.Response r = await _client.get(uri).timeout(_timeout);
      if (r.statusCode != 200) {
        return const <Track>[];
      }
      return tracksFromMetadata(
        hit.identifier,
        jsonDecode(utf8.decode(r.bodyBytes)),
        fallbackTitle: hit.title,
        fallbackArtist: hit.creator,
      );
    } catch (_) {
      return const <Track>[];
    }
  }

  /// archive.org `/metadata/<id>` yanıtından parça listesi üretir (saf, test edilebilir).
  /// Lisans adresi creativecommons veya publicdomain içermiyorsa boş döner.
  static List<Track> tracksFromMetadata(
    String identifier,
    Object? json, {
    String fallbackTitle = '',
    String fallbackArtist = '',
  }) {
    if (json is! Map<String, dynamic>) {
      return const <Track>[];
    }
    final Object? meta = json['metadata'];
    if (meta is! Map<String, dynamic>) {
      return const <Track>[];
    }
    final String license = _text(meta['licenseurl']).toLowerCase();
    if (!license.contains('creativecommons.org') &&
        !license.contains('publicdomain')) {
      return const <Track>[];
    }
    final String itemTitle =
        _text(meta['title']).isNotEmpty ? _text(meta['title']) : fallbackTitle;
    final String artist =
        _text(meta['creator']).isNotEmpty ? _text(meta['creator']) : fallbackArtist;
    final Object? files = json['files'];
    if (files is! List<dynamic>) {
      return const <Track>[];
    }
    final List<Track> mp3 = <Track>[];
    final List<Track> ogg = <Track>[];
    for (final Object? f in files) {
      if (f is! Map<String, dynamic>) {
        continue;
      }
      final String name = _text(f['name']);
      final String lower = name.toLowerCase();
      final bool isMp3 = lower.endsWith('.mp3');
      final bool isOgg = lower.endsWith('.ogg');
      if (name.isEmpty || (!isMp3 && !isOgg)) {
        continue;
      }
      final String fileTitle = _text(f['title']);
      final String title = fileTitle.isNotEmpty
          ? fileTitle
          : (itemTitle.isNotEmpty ? '$itemTitle — ${titleFromPath(name)}' : titleFromPath(name));
      final Track track = Track(
        id: 'ia:$identifier/$name',
        path: Uri.https('archive.org', '/download/$identifier/$name').toString(),
        title: title,
        artist: artist,
      );
      (isMp3 ? mp3 : ogg).add(track);
    }
    final List<Track> chosen = mp3.isNotEmpty ? mp3 : ogg;
    return chosen.length > _maxTracksPerItem
        ? chosen.sublist(0, _maxTracksPerItem)
        : chosen;
  }

  static String _text(Object? v) {
    if (v is String) {
      return v.trim();
    }
    if (v is List<dynamic> && v.isNotEmpty && v.first is String) {
      return (v.first as String).trim();
    }
    return '';
  }
}

class _Hit {
  const _Hit(this.identifier, this.title, this.creator);

  final String identifier;
  final String title;
  final String creator;
}
