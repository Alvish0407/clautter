import 'dart:math';
import 'package:flutter/material.dart';

/// A procedurally generated placeholder photo so no asset file is needed.
/// Draws a warm-toned landscape scene.
class PlaceholderPhoto extends StatelessWidget {
  final double width;
  const PlaceholderPhoto({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PhotoPainter(),
      size: Size(width, width * 4 / 3),
    );
  }
}

class _PhotoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sky gradient
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.6);
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF87CEEB),
        const Color(0xFFE8D5B7),
      ],
    );
    canvas.drawRect(
      skyRect,
      Paint()..shader = skyGradient.createShader(skyRect),
    );

    // Sun
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.2),
      size.width * 0.08,
      Paint()..color = const Color(0xFFFFF4CC),
    );

    // Hills
    final hillPaint = Paint()..color = const Color(0xFF8FBC8F);
    final hillPath = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.6, size.width, size.height * 0.48)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    // Foreground
    final fgPaint = Paint()..color = const Color(0xFF6B8E6B);
    final fgPath = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
          size.width * 0.3, size.height * 0.62, size.width * 0.6, size.height * 0.68)
      ..quadraticBezierTo(
          size.width * 0.85, size.height * 0.74, size.width, size.height * 0.65)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fgPath, fgPaint);

    // Simple tree
    final trunkPaint = Paint()..color = const Color(0xFF8B7355);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.58),
        width: size.width * 0.03,
        height: size.height * 0.12,
      ),
      trunkPaint,
    );

    final treePaint = Paint()..color = const Color(0xFF2E8B57);
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.48),
      size.width * 0.08,
      treePaint,
    );

    // Flowers in foreground
    final flowerPaint = Paint()..color = const Color(0xFFE85D6F);
    final rng = Random(42);
    for (int i = 0; i < 6; i++) {
      final fx = size.width * (0.1 + rng.nextDouble() * 0.8);
      final fy = size.height * (0.75 + rng.nextDouble() * 0.15);
      canvas.drawCircle(Offset(fx, fy), 3, flowerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
