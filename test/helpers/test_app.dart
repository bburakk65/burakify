import 'package:burakify/app/bootstrap.dart';
import 'package:burakify/core/audio/track.dart';
import 'package:burakify/core/catalog/catalog_source.dart';
import 'package:burakify/core/data/settings_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_player_service.dart';

/// Test penceresinin mantıksal boyutunu ayarlar (devicePixelRatio = 1).
void setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Gövde süresince hedef platformu değiştirir (Android / Windows düzeni için).
Future<void> withPlatform(
  TargetPlatform platform,
  Future<void> Function() body,
) async {
  debugDefaultTargetPlatformOverride = platform;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

class PumpedApp {
  PumpedApp(this.player, this.store);

  final FakePlayerService player;
  final MemorySettingsStore store;
}

/// Uygulamayı sahte ses motoru, bellek ayar deposu ve sahte dosya seçiciyle açar.
Future<PumpedApp> pumpApp(
  WidgetTester tester, {
  List<String> picked = const <String>[],
  MemorySettingsStore? store,
  CatalogSource? catalog,
}) async {
  final FakePlayerService player = FakePlayerService();
  final MemorySettingsStore settings = store ?? MemorySettingsStore();
  await tester.pumpWidget(
    AppBootstrap(
      openStore: () async => settings,
      playerService: player,
      pickFiles: () async => picked,
      catalog: catalog ?? FakeCatalog(),
    ),
  );
  await tester.pumpAndSettle();
  return PumpedApp(player, settings);
}

/// Sistem "geri" olayını gönderir (Android geri tuşu).
Future<void> pressSystemBack(WidgetTester tester) async {
  final ByteData message =
      const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute'));
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    message,
    (ByteData? _) {},
  );
  await tester.pumpAndSettle();
}

/// Testler için sahte katalog: ağa çıkmaz.
class FakeCatalog implements CatalogSource {
  FakeCatalog({this.results = const <Track>[], this.error});

  final List<Track> results;
  final CatalogException? error;
  final List<String> queries = <String>[];

  @override
  String get name => 'Sahte katalog';

  @override
  String get description => 'Test için';

  @override
  Future<List<Track>> search(String query) async {
    queries.add(query);
    if (error != null) {
      throw error!;
    }
    return results;
  }
}
