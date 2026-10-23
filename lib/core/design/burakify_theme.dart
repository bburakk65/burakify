import 'package:flutter/material.dart';

/// Burakify renk token'ları (bkz. docs/03-DESIGN-SYSTEM.md).
class BurakifyColors {
  const BurakifyColors._();

  static const Color accentDark = Color(0xFFFFB547);
  // Açık temada beyaz metinle ~5:1 kontrast için docs'taki değerden koyulaştırıldı.
  static const Color accentLight = Color(0xFFA35F00);
  static const Color surfaceDark = Color(0xFF0E1020);
  static const Color surfaceLight = Color(0xFFF7F6F3);
}

class BurakifyTheme {
  const BurakifyTheme._();

  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color accent =
        isDark ? BurakifyColors.accentDark : BurakifyColors.accentLight;
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    ).copyWith(
      primary: accent,
      onPrimary: isDark ? const Color(0xFF1A1200) : Colors.white,
      surface: isDark ? BurakifyColors.surfaceDark : BurakifyColors.surfaceLight,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
