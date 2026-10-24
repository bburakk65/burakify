import 'package:flutter/widgets.dart';

import 'motion.dart';

/// Öğeyi ilk göründüğünde hafifçe yukarı kayarak ve solarak gösterir.
/// [index] büyüdükçe başlangıç biraz gecikir (en çok 8 basamak), böylece liste
/// dalga gibi belirir. Sistem "animasyonları azalt" ayarı açıksa animasyon yoktur.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  static const int _stepMs = 40;
  static const int _baseMs = 240;

  @override
  Widget build(BuildContext context) {
    if (BurakifyMotion.reduced(context)) {
      return child;
    }
    final int step = index < 0 ? 0 : (index > 8 ? 8 : index);
    final int totalMs = _baseMs + step * _stepMs;
    final double begin = (step * _stepMs) / totalMs;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(begin, 1.0, curve: BurakifyMotion.standard),
      child: child,
      builder: (BuildContext context, double v, Widget? c) {
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, (1 - v) * 8), child: c),
        );
      },
    );
  }
}
