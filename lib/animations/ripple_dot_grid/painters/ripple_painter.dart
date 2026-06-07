import 'package:flutter/material.dart';

import '../models/dot_particle.dart';

/// Renders the displaced dot grid each frame.
///
/// Every dot is drawn as a small filled circle at its current [DotParticle.pos].
/// No caching — all dots move independently so a static raster is not viable.
class RipplePainter extends CustomPainter {
  final List<DotParticle> dots;
  final double dotRadius;

  RipplePainter({required this.dots, required this.dotRadius});

  static final _dotPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    for (final dot in dots) {
      canvas.drawCircle(dot.pos, dotRadius, _dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter old) => true;
}
