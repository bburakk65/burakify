import 'package:burakify/core/design/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('uygulama açılır, Ana Sayfa ve boş durum görünür', (tester) async {
    await pumpApp(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(BurakifyLogo), findsOneWidget);
    expect(find.byKey(const Key('search_field')), findsOneWidget);
    expect(find.byKey(const Key('home_add_button')), findsOneWidget);
  });
}
