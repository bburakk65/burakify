import 'package:burakify/core/data/settings_store.dart';
import 'package:burakify/core/design/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

const List<String> _threeFiles = <String>[
  '/m/gece_yarisi.mp3',
  '/m/amber_sabah.mp3',
  '/m/kiyi.mp3',
];

Finder _inNav(Type container, String label) =>
    find.descendant(of: find.byType(container), matching: find.text(label));

Future<void> _addFilesFromHome(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('home_add_button')));
  await tester.pumpAndSettle();
}

ThemeMode _themeMode(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

void main() {
  group('telefon (Android, 400x800)', () {
    testWidgets('Ana Sayfa: logo, arama, katalog bilgisi ve boş durum',
        (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        await pumpApp(tester);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(BurakifyLogo), findsOneWidget);
        expect(find.byKey(const Key('search_field')), findsOneWidget);
        expect(find.byKey(const Key('catalog_notice')), findsOneWidget);
        expect(find.byKey(const Key('home_add_button')), findsOneWidget);
        expect(find.byKey(const Key('mini_player')), findsNothing);
      });
    });

    testWidgets('sekmeler arasında gezinme: Kitaplık, Kuyruk, Ayarlar',
        (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        await pumpApp(tester);

        await tester.tap(_inNav(NavigationBar, 'Kitaplık'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('empty_add_button')), findsOneWidget);

        await tester.tap(_inNav(NavigationBar, 'Kuyruk'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('queue_page')), findsOneWidget);

        await tester.tap(_inNav(NavigationBar, 'Ayarlar'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('theme_selector')), findsOneWidget);

        await tester.tap(_inNav(NavigationBar, 'Ana Sayfa'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('search_field')), findsOneWidget);
      });
    });

    testWidgets('geri tuşu Ayarlar sekmesinden Ana Sayfa\'ya döner',
        (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        await pumpApp(tester);
        await tester.tap(_inNav(NavigationBar, 'Ayarlar'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('theme_selector')), findsOneWidget);

        await pressSystemBack(tester);

        expect(find.byKey(const Key('theme_selector')), findsNothing);
        expect(find.byKey(const Key('search_field')), findsOneWidget);
      });
    });

    testWidgets('dosya ekleme, arama, temizleme ve sonuç bulunamadı',
        (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        await pumpApp(tester, picked: <String>[..._threeFiles, '/m/not.txt']);
        await _addFilesFromHome(tester);
        expect(find.text('gece yarisi'), findsOneWidget);
        expect(find.text('amber sabah'), findsOneWidget);
        expect(find.text('kiyi'), findsOneWidget);
        expect(find.textContaining('3 şarkı eklendi'), findsOneWidget);
        expect(find.textContaining('1 desteklenmeyen dosya atlandı'),
            findsOneWidget);

        await tester.enterText(find.byKey(const Key('search_field')), 'AMBER');
        await tester.pumpAndSettle();
        expect(find.text('amber sabah'), findsOneWidget);
        expect(find.text('gece yarisi'), findsNothing);

        await tester.enterText(find.byKey(const Key('search_field')), 'xyz');
        await tester.pumpAndSettle();
        expect(find.text('Sonuç bulunamadı'), findsOneWidget);

        await tester.tap(find.byKey(const Key('search_clear_button')));
        await tester.pumpAndSettle();
        expect(find.text('gece yarisi'), findsOneWidget);
        expect(find.text('kiyi'), findsOneWidget);
      });
    });

    testWidgets('bir parçaya dokununca çalar, mini ve tam oynatıcı açılır',
        (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        final PumpedApp app = await pumpApp(tester, picked: _threeFiles);
        await _addFilesFromHome(tester);
        await tester.tap(find.text('amber sabah'));
        await tester.pumpAndSettle();
        expect(app.player.loadedPaths, <String>['/m/amber_sabah.mp3']);
        expect(app.player.playing, isTrue);
        expect(find.byKey(const Key('mini_player')), findsOneWidget);

        await tester.tap(find.byKey(const Key('mini_player')));
        await tester.pumpAndSettle();
        expect(find.text('Çalıyor'), findsOneWidget);
        expect(find.byKey(const Key('seek_slider')), findsOneWidget);
      });
    });

    testWidgets('açılamayan dosyada hata gösterilir, uygulama çökmez',
        (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        final PumpedApp app =
            await pumpApp(tester, picked: <String>['/m/bozuk.mp3']);
        app.player.failingPaths.add('/m/bozuk.mp3');
        await _addFilesFromHome(tester);
        await tester.tap(find.text('bozuk'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('mini_player')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('player_error')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('ayarlar ve tema', () {
    testWidgets('varsayılan tema koyu', (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        await pumpApp(tester);
        expect(_themeMode(tester), ThemeMode.dark);
      });
    });

    testWidgets('tema değişir ve kaydedilir', (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        final PumpedApp app = await pumpApp(tester);
        await tester.tap(_inNav(NavigationBar, 'Ayarlar'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Açık'));
        await tester.pumpAndSettle();

        expect(_themeMode(tester), ThemeMode.light);
        expect(await app.store.readString('theme_mode'), 'light');
      });
    });

    testWidgets('kayıtlı tema açılışta uygulanır', (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        await pumpApp(
          tester,
          store: MemorySettingsStore(
            initial: <String, String>{'theme_mode': 'light'},
          ),
        );
        expect(_themeMode(tester), ThemeMode.light);
      });
    });

    testWidgets('kaydedilemezse kullanıcıya bildirilir',
        (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        final PumpedApp app = await pumpApp(tester);
        app.store.failWrites = true;
        await tester.tap(_inNav(NavigationBar, 'Ayarlar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Açık'));
        await tester.pumpAndSettle();
        expect(find.textContaining('kaydedilemedi'), findsOneWidget);
        expect(_themeMode(tester), ThemeMode.light);
      });
    });

    testWidgets('Ayarlar henüz olmayan özellikleri açıkça belirtir',
        (WidgetTester tester) async {
      setSize(tester, const Size(400, 800));
      await withPlatform(TargetPlatform.android, () async {
        await pumpApp(tester);
        await tester.tap(_inNav(NavigationBar, 'Ayarlar'));
        await tester.pumpAndSettle();
        expect(find.text('Bağlı değil'), findsOneWidget);
        expect(find.text('Sonraki aşamada eklenecek'), findsNWidgets(2));
      });
    });
  });

  group('tablet (Android)', () {
    testWidgets('dikey: gezinme rayı; yön değişince sekme ve arama metni korunur',
        (WidgetTester tester) async {
      setSize(tester, const Size(800, 1280));
      await withPlatform(TargetPlatform.android, () async {
        await pumpApp(tester);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byKey(const Key('now_playing_pane')), findsNothing);

        await tester.enterText(find.byKey(const Key('search_field')), 'abc');
        await tester.pumpAndSettle();

        // Yatay yöne geçiş.
        tester.view.physicalSize = const Size(1280, 800);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('now_playing_pane')), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
        final TextField field =
            tester.widget<TextField>(find.byKey(const Key('search_field')));
        expect(field.controller!.text, 'abc');
      });
    });

    testWidgets('Ana Sayfa ve Kitaplık çok sütunlu ızgara gösterir',
        (WidgetTester tester) async {
      setSize(tester, const Size(1280, 800));
      await withPlatform(TargetPlatform.android, () async {
        await pumpApp(tester, picked: _threeFiles);
        await _addFilesFromHome(tester);
        expect(find.byKey(const Key('home_grid')), findsOneWidget);
        expect(find.byKey(const Key('home_list')), findsNothing);
        final double xa = tester.getTopLeft(find.text('gece yarisi')).dx;
        final double xb = tester.getTopLeft(find.text('amber sabah')).dx;
        expect(xb, isNot(equals(xa)), reason: 'aynı satırda yan yana olmalı');

        await tester.tap(_inNav(NavigationRail, 'Kitaplık'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('library_grid')), findsOneWidget);
      });
    });
  });

  group('Windows', () {
    testWidgets('1280 px: yan menü, kuyruk paneli ve alt oynatıcı çubuğu',
        (WidgetTester tester) async {
      setSize(tester, const Size(1280, 800));
      await withPlatform(TargetPlatform.windows, () async {
        await pumpApp(tester);
        expect(find.byKey(const Key('desktop_sidebar')), findsOneWidget);
        expect(find.byKey(const Key('queue_panel')), findsOneWidget);
        expect(find.byKey(const Key('desktop_player_bar')), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byType(NavigationRail), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(const Key('desktop_sidebar')),
            matching: find.byType(ListTile),
          ),
          findsNWidgets(4),
        );
      });
    });

    testWidgets('yan menüden Ayarlar\'a geçilir', (WidgetTester tester) async {
      setSize(tester, const Size(1280, 800));
      await withPlatform(TargetPlatform.windows, () async {
        await pumpApp(tester);
        await tester.tap(
          find.descendant(
            of: find.byKey(const Key('desktop_sidebar')),
            matching: find.text('Ayarlar'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('theme_selector')), findsOneWidget);
      });
    });

    testWidgets('Ctrl+Q kuyruk panelini kapatır ve açar',
        (WidgetTester tester) async {
      setSize(tester, const Size(1280, 800));
      await withPlatform(TargetPlatform.windows, () async {
        await pumpApp(tester);
        Future<void> ctrlQ() async {
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyQ);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pumpAndSettle();
        }

        await ctrlQ();
        expect(find.byKey(const Key('queue_panel')), findsNothing);
        await ctrlQ();
        expect(find.byKey(const Key('queue_panel')), findsOneWidget);
      });
    });

    testWidgets('900 px: kuyruk paneli yok, Ctrl+Q çekmeceyi açar',
        (WidgetTester tester) async {
      setSize(tester, const Size(900, 700));
      await withPlatform(TargetPlatform.windows, () async {
        await pumpApp(tester);
        expect(find.byKey(const Key('desktop_sidebar')), findsOneWidget);
        expect(find.byKey(const Key('queue_panel')), findsNothing);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyQ);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();
        expect(find.byType(Drawer), findsOneWidget);
      });
    });

    testWidgets('Boşluk tuşu oynat/duraklat yapar', (WidgetTester tester) async {
      setSize(tester, const Size(1280, 800));
      await withPlatform(TargetPlatform.windows, () async {
        final PumpedApp app =
            await pumpApp(tester, picked: <String>['/m/amber_sabah.mp3']);
        await _addFilesFromHome(tester);
        await tester.tap(find.text('amber sabah'));
        await tester.pumpAndSettle();
        expect(app.player.playing, isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(app.player.playing, isFalse);

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(app.player.playing, isTrue);
      });
    });

    testWidgets('500 px: kompakt düzene geçer', (WidgetTester tester) async {
      setSize(tester, const Size(500, 800));
      await withPlatform(TargetPlatform.windows, () async {
        await pumpApp(tester);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byKey(const Key('desktop_sidebar')), findsNothing);
      });
    });
  });
}
