import 'dart:convert';

import 'package:burakify/core/audio/track.dart';
import 'package:burakify/core/catalog/catalog_source.dart';
import 'package:burakify/core/catalog/internet_archive_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: <String, String>{'content-type': 'application/json'},
    );

Map<String, dynamic> _searchBody(List<Map<String, String>> docs) =>
    <String, dynamic>{
      'response': <String, dynamic>{'docs': docs},
    };

void main() {
  group('InternetArchiveCatalog.sanitizeQuery', () {
    test('özel karakterleri temizler ve boşlukları sadeleştirir', () {
      expect(
        InternetArchiveCatalog.sanitizeQuery('  rock & roll: "live" (1999)  '),
        'rock roll live 1999',
      );
    });

    test('yalnızca özel karakterden oluşan sorgu boş olur', () {
      expect(InternetArchiveCatalog.sanitizeQuery(' ()[]*? '), '');
    });
  });

  group('tracksFromMetadata', () {
    test('lisanssız öğe boş döner', () {
      final List<Track> r = InternetArchiveCatalog.tracksFromMetadata(
        'x',
        <String, dynamic>{
          'metadata': <String, dynamic>{'title': 'T'},
          'files': <Map<String, String>>[
            <String, String>{'name': 'a.mp3'},
          ],
        },
      );
      expect(r, isEmpty);
    });

    test('kamu malı lisansı kabul edilir; dosya adı kodlanır; başlık üretilir', () {
      final List<Track> r = InternetArchiveCatalog.tracksFromMetadata(
        'id1',
        <String, dynamic>{
          'metadata': <String, dynamic>{
            'title': 'T',
            'creator': 'Biri',
            'licenseurl': 'https://creativecommons.org/publicdomain/zero/1.0/',
          },
          'files': <Map<String, String>>[
            <String, String>{'name': 'My Song.mp3'},
          ],
        },
      );
      expect(r, hasLength(1));
      expect(r.single.path, 'https://archive.org/download/id1/My%20Song.mp3');
      expect(r.single.title, 'T — My Song');
      expect(r.single.artist, 'Biri');
      expect(r.single.isOnline, isTrue);
    });

    test('mp3 varsa ogg seçilmez, en çok 3 parça alınır', () {
      final List<Track> r = InternetArchiveCatalog.tracksFromMetadata(
        'id2',
        <String, dynamic>{
          'metadata': <String, dynamic>{
            'licenseurl': 'http://creativecommons.org/licenses/by/4.0/',
          },
          'files': <Map<String, String>>[
            <String, String>{'name': '1.mp3'},
            <String, String>{'name': '2.mp3'},
            <String, String>{'name': '3.mp3'},
            <String, String>{'name': '4.mp3'},
            <String, String>{'name': 'x.ogg'},
            <String, String>{'name': 'kapak.jpg'},
          ],
        },
      );
      expect(r.map((Track t) => t.id), <String>[
        'ia:id2/1.mp3',
        'ia:id2/2.mp3',
        'ia:id2/3.mp3',
      ]);
    });
  });

  group('InternetArchiveCatalog.search', () {
    test('lisanslı parçaları döndürür, lisanssız öğeyi eler', () async {
      final MockClient client = MockClient((http.Request req) async {
        if (req.url.path == '/advancedsearch.php') {
          expect(req.url.queryParameters['q'], contains('mediatype:audio'));
          return _json(_searchBody(<Map<String, String>>[
            <String, String>{
              'identifier': 'item1',
              'title': 'Albüm',
              'creator': 'Sanatçı',
            },
            <String, String>{'identifier': 'item2', 'title': 'X'},
          ]));
        }
        if (req.url.path == '/metadata/item1') {
          return _json(<String, dynamic>{
            'metadata': <String, dynamic>{
              'title': 'Albüm',
              'creator': 'Sanatçı',
              'licenseurl': 'https://creativecommons.org/licenses/by/4.0/',
            },
            'files': <Map<String, String>>[
              <String, String>{'name': 'a.mp3', 'title': 'Şarkı Bir'},
              <String, String>{'name': 'kapak.jpg'},
            ],
          });
        }
        if (req.url.path == '/metadata/item2') {
          return _json(<String, dynamic>{
            'metadata': <String, dynamic>{'title': 'X'},
            'files': <Map<String, String>>[
              <String, String>{'name': 'b.mp3'},
            ],
          });
        }
        return http.Response('yok', 404);
      });
      final List<Track> r = await InternetArchiveCatalog(client: client)
          .search('albüm');
      expect(r, hasLength(1));
      expect(r.single.id, 'ia:item1/a.mp3');
      expect(r.single.path, 'https://archive.org/download/item1/a.mp3');
      expect(r.single.title, 'Şarkı Bir');
      expect(r.single.artist, 'Sanatçı');
    });

    test('lisans filtreli arama boşsa filtresiz yeniden dener', () async {
      final List<String> queries = <String>[];
      final MockClient client = MockClient((http.Request req) async {
        if (req.url.path == '/advancedsearch.php') {
          queries.add(req.url.queryParameters['q']!);
          return _json(_searchBody(const <Map<String, String>>[]));
        }
        return http.Response('yok', 404);
      });
      final List<Track> r =
          await InternetArchiveCatalog(client: client).search('deneme');
      expect(r, isEmpty);
      expect(queries, hasLength(2));
      expect(queries.first, contains('licenseurl'));
      expect(queries.last, isNot(contains('licenseurl')));
    });

    test('boş sorgu ağa gitmez', () async {
      int calls = 0;
      final MockClient client = MockClient((http.Request req) async {
        calls++;
        return http.Response('', 500);
      });
      expect(await InternetArchiveCatalog(client: client).search('  '), isEmpty);
      expect(calls, 0);
    });

    test('sunucu hatası CatalogException olur', () async {
      final MockClient client =
          MockClient((http.Request req) async => http.Response('x', 500));
      await expectLater(
        InternetArchiveCatalog(client: client).search('a'),
        throwsA(isA<CatalogException>()),
      );
    });

    test('ağ hatası anlaşılır bir iletiye çevrilir', () async {
      final MockClient client = MockClient(
        (http.Request req) async => throw http.ClientException('bağlantı yok'),
      );
      await expectLater(
        InternetArchiveCatalog(client: client).search('a'),
        throwsA(
          isA<CatalogException>().having(
            (CatalogException e) => e.message,
            'message',
            contains('İnternete ulaşılamadı'),
          ),
        ),
      );
    });

    test('bozuk JSON CatalogException olur', () async {
      final MockClient client =
          MockClient((http.Request req) async => http.Response('{bozuk', 200));
      await expectLater(
        InternetArchiveCatalog(client: client).search('a'),
        throwsA(isA<CatalogException>()),
      );
    });
  });
}
