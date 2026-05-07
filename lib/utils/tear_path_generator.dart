import 'dart:math';
import 'dart:ui';

/// Generates a jagged tear path running from top-center to bottom of [cardRect].
///
/// Uses a random walk with mean reversion so the path wobbles organically
/// but doesn't drift too far from the vertical center.
List<Offset> generateTearPath(
  Rect cardRect,
  int seed, {
  int segmentCount = 50,
  double maxWobble = 30.0,
  double meanReversion = 0.25,
}) {
  final random = Random(seed);
  final points = <Offset>[];

  final centerX = cardRect.center.dx;
  final topY = cardRect.top;
  final bottomY = cardRect.bottom;
  final segmentHeight = (bottomY - topY) / segmentCount;

  double currentX = centerX;

  for (int i = 0; i <= segmentCount; i++) {
    final y = topY + i * segmentHeight;

    final wobble = (random.nextDouble() - 0.5) * maxWobble;
    final drift = (currentX - centerX) * meanReversion;
    currentX = currentX + wobble - drift;

    currentX = currentX.clamp(
      cardRect.left + cardRect.width * 0.25,
      cardRect.right - cardRect.width * 0.25,
    );

    points.add(Offset(currentX, y));
  }

  return points;
}

/// Adds micro-jitter to tear points for a fibrous paper-edge effect.
List<Offset> addFibrousEdge(
  List<Offset> tearPoints,
  double amplitude,
  int seed,
) {
  final random = Random(seed);
  return tearPoints.map((p) {
    final jitter = (random.nextDouble() - 0.5) * amplitude;
    return Offset(p.dx + jitter, p.dy);
  }).toList();
}
