import 'dart:ui';
import 'package:flutter/rendering.dart';

enum TearSide { left, right }

/// Clips a widget to one side of a jagged tear line.
///
/// The tear reveals outward from [tearOriginRatio] (0–1 along the path)
/// so the rip starts wherever the user touched.
class TearClipper extends CustomClipper<Path> {
  final List<Offset> tearPoints;
  final double tearProgress;
  final TearSide side;
  final double gapOffset;
  final double tearOriginRatio;

  TearClipper({
    required this.tearPoints,
    required this.tearProgress,
    required this.side,
    this.gapOffset = 0,
    this.tearOriginRatio = 0.0,
  });

  @override
  Path getClip(Size size) {
    if (tearProgress <= 0 || tearPoints.isEmpty) {
      return Path()..addRect(Offset.zero & size);
    }

    final n = tearPoints.length;
    final originIndex = (n * tearOriginRatio).round().clamp(0, n - 1);

    // Expand reveal outward from origin
    final pointsAbove = originIndex;
    final pointsBelow = n - 1 - originIndex;
    final topIndex =
        (originIndex - (pointsAbove * tearProgress).round()).clamp(0, n - 1);
    final bottomIndex =
        (originIndex + (pointsBelow * tearProgress).round()).clamp(0, n - 1);

    // If the reveal is too small, show full rect
    if (topIndex >= bottomIndex) {
      return Path()..addRect(Offset.zero & size);
    }

    final topY = tearPoints[topIndex].dy;
    final bottomY = tearPoints[bottomIndex].dy;

    final path = Path();

    if (side == TearSide.left) {
      // Top-left corner
      path.moveTo(0, 0);
      // Full width across top (card intact above tear)
      path.lineTo(size.width, 0);
      // Down right edge to where tear starts
      path.lineTo(size.width, topY);
      // Across to tear line
      path.lineTo(tearPoints[topIndex].dx + gapOffset, topY);

      // Follow tear line downward
      for (int i = topIndex; i < bottomIndex; i++) {
        final cp = tearPoints[i];
        final next = tearPoints[i + 1];
        final midX = (cp.dx + next.dx) / 2 + gapOffset;
        final midY = (cp.dy + next.dy) / 2;
        path.quadraticBezierTo(cp.dx + gapOffset, cp.dy, midX, midY);
      }

      // Back to right edge at bottom of tear
      path.lineTo(tearPoints[bottomIndex].dx + gapOffset, bottomY);
      path.lineTo(size.width, bottomY);
      // Down right edge (card intact below tear)
      path.lineTo(size.width, size.height);
      // Bottom-left
      path.lineTo(0, size.height);
      path.close();
    } else {
      // Top-right corner
      path.moveTo(size.width, 0);
      // Full width across top
      path.lineTo(0, 0);
      // Down left edge to where tear starts
      path.lineTo(0, topY);
      // Across to tear line
      path.lineTo(tearPoints[topIndex].dx + gapOffset, topY);

      // Follow tear line downward
      for (int i = topIndex; i < bottomIndex; i++) {
        final cp = tearPoints[i];
        final next = tearPoints[i + 1];
        final midX = (cp.dx + next.dx) / 2 + gapOffset;
        final midY = (cp.dy + next.dy) / 2;
        path.quadraticBezierTo(cp.dx + gapOffset, cp.dy, midX, midY);
      }

      // Back to left edge at bottom of tear
      path.lineTo(tearPoints[bottomIndex].dx + gapOffset, bottomY);
      path.lineTo(0, bottomY);
      // Down left edge
      path.lineTo(0, size.height);
      // Bottom-right
      path.lineTo(size.width, size.height);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(TearClipper oldClipper) =>
      tearProgress != oldClipper.tearProgress ||
      gapOffset != oldClipper.gapOffset ||
      tearOriginRatio != oldClipper.tearOriginRatio;
}
