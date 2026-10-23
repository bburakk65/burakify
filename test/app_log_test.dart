import 'package:burakify/core/errors/app_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLog.redact', () {
    test('Unix dosya yollarını gizler', () {
      expect(
        AppLog.redact('Dosya açılamadı: /storage/emulated/0/Music/ozel sarki.mp3'),
        isNot(contains('/storage')),
      );
      expect(AppLog.redact('hata /data/user/0/x/y.db sonu'), 'hata <yol> sonu');
    });

    test('Windows dosya yollarını gizler', () {
      expect(
        AppLog.redact(r'açılamadı C:\Users\Ali\Music\a.mp3 tekrar'),
        'açılamadı <yol> tekrar',
      );
    });

    test('token ve parola benzeri değerleri gizler', () {
      expect(AppLog.redact('token=abc123xyz'), 'token=<gizli>');
      expect(AppLog.redact('Password: hunter2'), 'Password=<gizli>');
    });

    test('sıradan metne dokunmaz', () {
      expect(AppLog.redact('oynatma durdu'), 'oynatma durdu');
    });
  });

  test('AppLog.error olay adını ve hata türünü yazar, yolu yazmaz', () {
    final List<String> lines = <String>[];
    final void Function(String) previous = AppLog.sink;
    AppLog.sink = lines.add;
    addTearDown(() => AppLog.sink = previous);

    AppLog.error('track_load_failed', StateError('yok: /sdcard/gizli.mp3'));

    expect(lines, hasLength(1));
    expect(lines.single, contains('track_load_failed'));
    expect(lines.single, contains('StateError'));
    expect(lines.single, isNot(contains('/sdcard')));
  });
}
