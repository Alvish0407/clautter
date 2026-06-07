import 'dart:math';
import 'package:flutter/material.dart';
import '../models/spider_config.dart';

/// Computes the knee (elbow) position for a two-bone IK chain.
///
/// Uses the law of cosines to find the angle at the hip, then rotates by
/// that angle around the hip→foot axis. [bendLeft] selects which of the
/// two geometrically valid solutions to use.
Offset computeKnee(
  Offset hip,
  Offset foot,
  double upperLen,
  double lowerLen, {
  bool bendLeft = true,
}) {
  final dx = foot.dx - hip.dx;
  final dy = foot.dy - hip.dy;
  final dist = sqrt(dx * dx + dy * dy);

  // Clamp distance to the reachable range so acos never receives >1 or <-1.
  final clampedDist = dist.clamp(
    (upperLen - lowerLen).abs() + 0.1,
    upperLen + lowerLen - 0.1,
  );

  final cosAngle =
      (upperLen * upperLen + clampedDist * clampedDist - lowerLen * lowerLen) /
      (2 * upperLen * clampedDist);
  final angle = acos(cosAngle.clamp(-1.0, 1.0));

  final baseAngle = atan2(dy, dx);
  final kneeAngle = bendLeft ? baseAngle - angle : baseAngle + angle;
  return Offset(
    hip.dx + upperLen * cos(kneeAngle),
    hip.dy + upperLen * sin(kneeAngle),
  );
}

/// Snaps [position] to the nearest grid intersection.
Offset snapToGrid(Offset position, double gridSpacing) {
  return Offset(
    (position.dx / gridSpacing).round() * gridSpacing,
    (position.dy / gridSpacing).round() * gridSpacing,
  );
}

/// Returns the four body plate attachment offsets in N, E, S, W order.
List<Offset> getPlateOffsets() {
  return const [
    Offset(0, -kBodyPlateOffset), // N
    Offset(kBodyPlateOffset, 0), // E
    Offset(0, kBodyPlateOffset), // S
    Offset(-kBodyPlateOffset, 0), // W
  ];
}
