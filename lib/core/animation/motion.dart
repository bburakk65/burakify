import 'package:flutter/widgets.dart';

/// Merkezi hareket ayarları. Ekranlar süreyi doğrudan yazmaz, buradan alır.
class BurakifyMotion {
  const BurakifyMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration reducedMax = Duration(milliseconds: 100);
  static const Curve standard = Curves.easeOutCubic;

  /// Sistem "animasyonları azalt/kaldır" ayarı açık mı?
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// Azaltılmış harekette süreyi en çok [reducedMax]'a indirir.
  static Duration duration(BuildContext context, Duration base) {
    if (reduced(context) && base > reducedMax) {
      return reducedMax;
    }
    return base;
  }
}
