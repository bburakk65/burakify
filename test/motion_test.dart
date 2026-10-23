import 'package:burakify/core/animation/motion.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('azaltılmış harekette animasyon süresi kısalır', (tester) async {
    late Duration reduced;
    late Duration normal;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (BuildContext context) {
            reduced = BurakifyMotion.duration(context, BurakifyMotion.slow);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Builder(
          builder: (BuildContext context) {
            normal = BurakifyMotion.duration(context, BurakifyMotion.slow);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(reduced, BurakifyMotion.reducedMax);
    expect(normal, BurakifyMotion.slow);
  });
}
