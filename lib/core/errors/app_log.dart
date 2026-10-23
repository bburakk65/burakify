import 'package:flutter/foundation.dart';

/// Geliştirici günlüğü. Dosya yolları ve parola/token benzeri değerler
/// yazılmadan önce gizlenir; yayın (release) derlemesinde hiçbir şey yazmaz.
class AppLog {
  const AppLog._();

  /// Testlerde değiştirilebilir.
  static void Function(String line) sink = _defaultSink;

  static void _defaultSink(String line) {
    if (kDebugMode) {
      debugPrint(line);
    }
  }

  static final RegExp _secretPattern = RegExp(
    r'(token|password|parola|secret|apikey|api_key)\s*[=:]\s*\S+',
    caseSensitive: false,
  );

  // Windows (C:\...) ve Unix (/...) yolları ile URL parçalarını yakalar.
  static final RegExp _pathPattern = RegExp(r'''(?:[A-Za-z]:\\|/)[^\s'"]+''');

  /// Hassas olabilecek parçaları gizler.
  static String redact(String input) {
    final String noSecrets = input.replaceAllMapped(
      _secretPattern,
      (Match m) => '${m[1]}=<gizli>',
    );
    return noSecrets.replaceAll(_pathPattern, '<yol>');
  }

  static void error(String event, Object error) {
    sink('[burakify] $event (${error.runtimeType}): ${redact(error.toString())}');
  }

  static void info(String event) {
    sink('[burakify] ${redact(event)}');
  }
}
