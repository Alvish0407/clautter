import 'dart:math';

import 'package:flutter/material.dart';

import '../models/dot.dart';

/// Projected 2D representation of a single dot after 3D → screen transform.
class _DotData {
  final double screenX;
  final double screenY;
  final double rotatedZ; // depth used for back-to-front sort
  final double dotSize;
  final Color color;

  const _DotData({
    required this.screenX,
    required this.screenY,
    required this.rotatedZ,
    required this.dotSize,
    required this.color,
  });
}

/// Renders the 3D morphing sphere onto a [Canvas].
///
/// Pipeline per frame:
/// 1. For each dot, LERP between its random chaos position and a golden-angle
///    sphere target using [morphAmount] as the blend factor.
/// 2. Apply a Y-axis rotation matrix driven by [time].
/// 3. Project to 2D with a perspective divide.
/// 4. Assign colour from a top-to-bottom wave that sweeps through a palette.
/// 5. Sort back-to-front by depth (painter's algorithm).
/// 6. Draw filled circles.
class SpherePainter extends CustomPainter {
  final List<Dot> dots;
  final double time;

  /// Blend factor: 0 = scattered chaos, 100 = perfect sphere.
  final double morphAmount;

  // Five-colour palette cycled by the wave animation.
  static const List<Color> _palette = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.orange,
  ];

  /// Duration of one colour wave sweeping all dots (seconds).
  static const double _fadeDuration = 5.5;

  /// Pause between consecutive waves (seconds).
  static const double _waitDuration = 5.0;

  static const double _cycleDuration = _fadeDuration + _waitDuration;

  const SpherePainter({
    required this.dots,
    required this.time,
    required this.morphAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final n = dots.length;

    final tMorph = morphAmount / 100.0;

    // Continuous Y-axis rotation at 0.5 rad/s.
    final rotation = time * 0.5;
    final cosR = cos(rotation);
    final sinR = sin(rotation);

    // Golden angle: ~137.5° — distributes N points evenly over a sphere surface.
    final goldenAngle = pi * (3 - sqrt(5));

    // Scale contracts as morph progresses: 250 px (chaos) → 100 px (sphere).
    final chaosScale = lerp(250.0, 100.0, tMorph);

    // Colour wave state.
    final timeInCycle = time % _cycleDuration;
    final cycleIndex = (time ~/ _cycleDuration).toInt() % _palette.length;
    final baseColor = _palette[cycleIndex];
    final nextColor = _palette[(cycleIndex + 1) % _palette.length];

    // ── Phase 1: project all dots ────────────────────────────────────────
    final projected = <_DotData>[];
    final scaledYs = List<double>.filled(n, 0);

    for (int i = 0; i < n; i++) {
      final dot = dots[i];

      // Golden-angle sphere target for index i.
      final sy = 1 - (i / (n - 1)) * 2; // y ∈ [-1, 1]
      final radius = sqrt(1 - sy * sy);
      final theta = goldenAngle * i;

      // Interpolate: chaos position → sphere target.
      final x = lerp(dot.randomX, radius * cos(theta), tMorph);
      final y = lerp(dot.randomY, sy, tMorph);
      final z = lerp(dot.randomZ, radius * sin(theta), tMorph);

      final sx = x * chaosScale;
      final scaledY = y * chaosScale;
      final sz = z * chaosScale;

      // Y-axis rotation matrix.
      final rx = sx * cosR - sz * sinR;
      final rz = sx * sinR + sz * cosR;

      // Perspective divide: closer dots appear larger.
      final p = 300.0 / (300.0 + rz);
      scaledYs[i] = scaledY;
      projected.add(
        _DotData(
          screenX: rx * p,
          screenY: scaledY * p,
          rotatedZ: rz,
          dotSize: max(1.0, 3.0 * p),
          color: Colors.white, // placeholder, set in phase 2
        ),
      );
    }

    // ── Phase 2: assign wave colours ─────────────────────────────────────
    final minY = scaledYs.reduce(min);
    final maxY = scaledYs.reduce(max);
    final yRange = maxY - minY;

    final coloured = <_DotData>[];
    for (int i = 0; i < n; i++) {
      final d = projected[i];
      final normY = yRange > 0 ? (scaledYs[i] - minY) / yRange : 0.0;
      // Each dot's wave starts with a delay proportional to its Y position.
      final delay = normY * _fadeDuration;
      final progress = ((timeInCycle - delay) / _fadeDuration).clamp(0.0, 1.0);
      coloured.add(
        _DotData(
          screenX: d.screenX,
          screenY: d.screenY,
          rotatedZ: d.rotatedZ,
          dotSize: d.dotSize,
          color: blendColor(baseColor, nextColor, progress),
        ),
      );
    }

    // ── Phase 3: painter's algorithm — back-to-front sort, then draw ─────
    coloured.sort((a, b) => a.rotatedZ.compareTo(b.rotatedZ));

    final paint = Paint()..style = PaintingStyle.fill;
    for (final d in coloured) {
      paint.color = d.color.withValues(alpha: 0.85);
      canvas.drawCircle(
        Offset(cx + d.screenX, cy + d.screenY),
        d.dotSize / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpherePainter old) =>
      old.time != time || old.morphAmount != morphAmount;
}
