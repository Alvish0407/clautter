import 'package:flutter/material.dart';
import '../models/particle.dart';

/// Renders the spider-web particle field onto a [Canvas].
///
/// For every pair of particles closer than [_connectThreshold] px, a
/// translucent line is drawn whose opacity falls off linearly with distance.
/// Each particle is also drawn as a small filled circle.
class SpiderPainter extends CustomPainter {
  final List<Particle> particles;

  /// Maximum distance at which two particles will be connected by a line.
  static const double _connectThreshold = 150.0;

  const SpiderPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()..strokeWidth = 1.0;
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.9);

    final n = particles.length;

    // O(n²) pairwise check — acceptable for n ≤ ~100 at 60 fps.
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        final d = (particles[i].position - particles[j].position).distance;
        if (d < _connectThreshold) {
          // Maximum opacity when co-located; zero at the threshold distance.
          linePaint.color =
              Colors.white.withOpacity((1 - d / _connectThreshold) * 0.6);
          canvas.drawLine(
              particles[i].position, particles[j].position, linePaint);
        }
      }
    }

    for (final p in particles) {
      canvas.drawCircle(p.position, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SpiderPainter _) => true;
}
