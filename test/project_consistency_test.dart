import 'dart:io';

import 'package:burakify/app/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final String pubspec = File('pubspec.yaml').readAsStringSync();

  test('kAppVersion, pubspec.yaml sürümüyle aynı', () {
    final RegExpMatch? m = RegExp(
      r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(m, isNotNull, reason: 'pubspec.yaml içinde MAJOR.MINOR.PATCH+BUILD yok');
    expect(m!.group(1), kAppVersion);
  });

  test('pubspec bağımlılıklarının hepsi kodda kullanılıyor', () {
    // just_audio_windows yalnızca just_audio'nun Windows eklentisidir, import edilmez.
    const Set<String> pluginOnly = <String>{'flutter', 'just_audio_windows'};
    final String section = pubspec
        .split('dependencies:')[1]
        .split('dev_dependencies:')[0];
    final Iterable<String> deps = RegExp(r'^  ([a-z_]+):', multiLine: true)
        .allMatches(section)
        .map((RegExpMatch m) => m.group(1)!)
        .where((String d) => !pluginOnly.contains(d));

    final String allCode = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .map((File f) => f.readAsStringSync())
        .join('\n');

    for (final String dep in deps) {
      expect(allCode, contains('package:$dep/'),
          reason: '$dep pubspec.yaml içinde ama lib/ altında kullanılmıyor');
    }
  });
}
