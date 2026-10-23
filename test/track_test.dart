import 'package:burakify/core/audio/format.dart';
import 'package:burakify/core/audio/track.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isSupportedAudioPath', () {
    test('desteklenen uzantılar (büyük/küçük harf fark etmez)', () {
      expect(isSupportedAudioPath('/m/a.mp3'), isTrue);
      expect(isSupportedAudioPath(r'C:\Music\b.FLAC'), isTrue);
      expect(isSupportedAudioPath('c.M4A'), isTrue);
    });

    test('desteklenmeyen veya uzantısız', () {
      expect(isSupportedAudioPath('/m/a.txt'), isFalse);
      expect(isSupportedAudioPath('/m/a'), isFalse);
      expect(isSupportedAudioPath('/m/a.'), isFalse);
      expect(isSupportedAudioPath(r'C:\my.dir\file'), isFalse);
    });
  });

  group('titleFromPath', () {
    test('uzantıyı atar, alt çizgiyi boşluğa çevirir', () {
      expect(titleFromPath('/m/my_song.mp3'), 'my song');
      expect(titleFromPath(r'C:\Music\Şarkı Adı.wav'), 'Şarkı Adı');
    });
  });

  group('formatDuration', () {
    test('dakika:saniye ve saat', () {
      expect(formatDuration(const Duration(seconds: 7)), '0:07');
      expect(formatDuration(const Duration(minutes: 3, seconds: 7)), '3:07');
      expect(
        formatDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
      expect(formatDuration(const Duration(seconds: -5)), '0:00');
    });
  });
}
