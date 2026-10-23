import 'package:flutter/material.dart';

/// Burakify logo alanı: vurgu renginde yuvarlatılmış kare ve ses dalgası simgesi.
/// (Geçici logo; son tasarım sonraki aşamada gelecek. Harici görsel dosyası yok.)
class BurakifyLogo extends StatelessWidget {
  const BurakifyLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Burakify logosu',
      image: true,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.3),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[scheme.primary, scheme.tertiary],
            ),
          ),
          child: Icon(
            Icons.graphic_eq,
            size: size * 0.6,
            color: scheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
