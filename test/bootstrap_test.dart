import 'dart:async';

import 'package:burakify/app/bootstrap.dart';
import 'package:burakify/core/data/settings_store.dart';
import 'package:burakify/core/errors/app_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_player_service.dart';

void main() {
  late List<String> logs;
  late void Function(String) previousSink;

  setUp(() {
    logs = <String>[];
    previousSink = AppLog.sink;
    AppLog.sink = logs.add;
  });

  tearDown(() => AppLog.sink = previousSink);

  testWidgets('ayarlar okunurken yükleme gösterilir, sonra uygulama açılır',
      (tester) async {
    final Completer<SettingsStore> completer = Completer<SettingsStore>();
    await tester.pumpWidget(
      AppBootstrap(
        openStore: () => completer.future,
        playerService: FakePlayerService(),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Burakify başlatılıyor…'), findsOneWidget);
    expect(find.byKey(const Key('search_field')), findsNothing);

    completer.complete(MemorySettingsStore());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search_field')), findsOneWidget);
  });

  testWidgets('okuma hatasında Tekrar dene gösterilir ve yeniden deneme çalışır',
      (tester) async {
    int calls = 0;
    await tester.pumpWidget(
      AppBootstrap(
        openStore: () async {
          calls++;
          if (calls == 1) {
            throw StateError('okunamadı: /data/user/0/com.burakify/ozel.db');
          }
          return MemorySettingsStore();
        },
        playerService: FakePlayerService(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Burakify başlatılamadı'), findsOneWidget);
    expect(find.byKey(const Key('retry_button')), findsOneWidget);

    // Günlükte teşhis bilgisi var, özel yol yok.
    expect(logs, hasLength(1));
    expect(logs.single, contains('startup_failed'));
    expect(logs.single, isNot(contains('/data/user')));

    await tester.tap(find.byKey(const Key('retry_button')));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byKey(const Key('search_field')), findsOneWidget);
  });

  testWidgets('ayar deposu hiç yanıt vermezse zaman aşımıyla hata gösterilir',
      (tester) async {
    await tester.pumpWidget(
      AppBootstrap(
        openStore: () => Completer<SettingsStore>().future,
        playerService: FakePlayerService(),
        timeout: const Duration(milliseconds: 50),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(find.byKey(const Key('retry_button')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
