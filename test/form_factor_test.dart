import 'package:burakify/app/layout/form_factor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formFactorFor', () {
    test('Android dar ekran telefon', () {
      expect(
        formFactorFor(width: 411, platform: TargetPlatform.android),
        FormFactor.phone,
      );
    });

    test('Android 600dp ve üstü tablet (çok geniş olsa da masaüstü olmaz)', () {
      expect(
        formFactorFor(width: 600, platform: TargetPlatform.android),
        FormFactor.tablet,
      );
      expect(
        formFactorFor(width: 1600, platform: TargetPlatform.android),
        FormFactor.tablet,
      );
    });

    test('Android bölünmüş ekran dar pencere telefon düzenine döner', () {
      expect(
        formFactorFor(width: 400, platform: TargetPlatform.android),
        FormFactor.phone,
      );
    });

    test('Windows geniş pencere masaüstü, dar pencere kompakt', () {
      expect(
        formFactorFor(width: 1280, platform: TargetPlatform.windows),
        FormFactor.desktop,
      );
      expect(
        formFactorFor(width: 720, platform: TargetPlatform.windows),
        FormFactor.desktop,
      );
      expect(
        formFactorFor(width: 719, platform: TargetPlatform.windows),
        FormFactor.phone,
      );
    });
  });
}
