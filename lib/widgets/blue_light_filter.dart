import 'package:flutter/material.dart';

/// Envuelve [child] con un overlay ámbar semi-transparente
/// que simula un filtro de luz azul. [intensity] va de 0.0 a 1.0.
class BlueLightFilter extends StatelessWidget {
  final Widget child;
  final double intensity;

  const BlueLightFilter({
    super.key,
    required this.child,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    if (intensity <= 0.0) return child;

    // Color ámbar/naranja — absorbe la parte azul del espectro
    final overlayColor = Color.fromARGB(
      (intensity * 120).round().clamp(0, 180), // alpha máx 180 (~70%)
      255,
      160,
      0,
    );

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(color: overlayColor),
          ),
        ),
      ],
    );
  }
}
