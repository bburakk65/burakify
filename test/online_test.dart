import 'package:burakify/core/audio/player_controller.dart';
import 'package:burakify/core/audio/track.dart';
import 'package:burakify/core/catalog/catalog_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_player_service.dart';
import 'helpers/test_app.dart';

const Track _online = Track(
  id: 'ia:x/a.mp3',
  path: 'https://archive.org/download/x/a.mp3',
  title: 'Online Şarkı',
  artist: 'Biri',
);

Future<void> _openOnlineAndSearch(WidgetTester tester, String q) async {
  await tester.tap(find.text('Çevrimiçi'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('search_field')), q);
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pumpAndSettle();
}

void main() {
  test('isOnlinePath ve Track.isOnline', () {
    expect(isOnlinePath('https://a.b/c.mp3'), isTrue);
    expect(isOnlinePath('HTTP://a.b/c.mp3'), isTrue);
    expect(isOnlinePath('/storage/emulated/0/a.mp3'), isFalse);
    expect(isOnlinePath('C:\\Muzik\\a.mp3'), isFalse);
    expect(_online.isOnline, isTrue);
    expect(trackFromPath('/a/b.mp3').isOnline, isFalse);
  });

  test('çevrimiçi parça açılamazsa internet ipucu verilir', () async {
    final FakePlayerService fake = FakePlayerService();
    fake.failingPaths.add(_online.path);
    final PlayerController c = PlayerController(fake);
    await c.playTracks(<Track>[_online]);
    expect(c.errorMessage, contains('internet'));
    expect(c.status, PlaybackStatus.error);
    c.dispose();
  });

  test('parça adı ve sanatçı ses motoruna iletilir', () async {
    final FakePlayerService fake = FakePlayerService();
    final PlayerController c = PlayerController(fake);
    await c.playTracks(<Track>[_online]);
    expect(fake.loadedPaths, <String>[_online.path]);
    expect(fake.loadedTitles, <String>['Online Şarkı']);
    c.dispose();
  });

  group('Ana Sayfa çevrimiçi arama', () {
    testWidgets('sonuç listelenir ve dokununca çevrimiçi parça çalınır',
        (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        final FakeCatalog catalog = FakeCatalog(results: <Track>[_online]);
        final PumpedApp app = await pumpApp(tester, catalog: catalog);
        await _openOnlineAndSearch(tester, 'abc');
        expect(catalog.queries, <String>['abc']);
        expect(find.text('Online Şarkı'), findsOneWidget);
        expect(find.text('Biri'), findsOneWidget);

        await tester.tap(find.text('Online Şarkı'));
        await tester.pumpAndSettle();
        expect(app.player.loadedPaths, <String>[_online.path]);
        expect(app.player.playing, isTrue);
      });
    });

    testWidgets('hata iletisi ve "Tekrar dene" gösterilir',
        (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        final FakeCatalog catalog =
            FakeCatalog(error: const CatalogException('Bağlantı yok'));
        await pumpApp(tester, catalog: catalog);
        await _openOnlineAndSearch(tester, 'abc');
        expect(find.text('Bağlantı yok'), findsOneWidget);
        await tester.tap(find.byKey(const Key('online_retry_button')));
        await tester.pumpAndSettle();
        expect(catalog.queries, <String>['abc', 'abc']);
      });
    });

    testWidgets('sonuç yoksa bilgi verilir', (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        await pumpApp(tester, catalog: FakeCatalog());
        await _openOnlineAndSearch(tester, 'yok');
        expect(find.text('Sonuç bulunamadı'), findsOneWidget);
      });
    });

    testWidgets('Kitaplığım\'a dönünce yerel görünüm geri gelir',
        (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        await pumpApp(tester, catalog: FakeCatalog(results: <Track>[_online]));
        await _openOnlineAndSearch(tester, 'abc');
        await tester.tap(find.text('Kitaplığım'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('home_add_button')), findsOneWidget);
        expect(find.text('Online Şarkı'), findsNothing);
      });
    });
  });
}
