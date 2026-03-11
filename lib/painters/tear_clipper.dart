import 'dart:ui';
import 'package:flutter/rendering.dart';

enum TearSide { left, right }

/// Clips a widget to one side of a jagged tear line.
///
/// The visible tear spans from [tearTopRatio] to [tearBottomRatio] (both 0–1
/// along the tear path). Outside this range the card is shown at full width.
class TearClipper extends CustomClipper<Path> {
  final List<Offset> tearPoints;
  final double tearTopRatio;
  final double tearBottomRatio;
  final TearSide side;
  final double gapOffset;

  TearClipper({
    required this.tearPoints,
    required this.tearTopRatio,
    required this.tearBottomRatio,
    required this.side,
    this.gapOffset = 0,
  });

  @override
  Path getClip(Size size) {
    final n = tearPoints.length;
    if (n == 0 || tearTopRatio >= tearBottomRatio) {
      return Path()..addRect(Offset.zero & size);
    }

    final topIndex = (n * tearTopRatio).round().clamp(0, n - 1);
    final bottomIndex = (n * tearBottomRatio).round().clamp(0, n - 1);

    if (topIndex >= bottomIndex) {
      return Path()..addRect(Offset.zero & size);
    }

    final topY = tearPoints[topIndex].dy;
    final bottomY = tearPoints[bottomIndex].dy;

    final path = Path();

    if (side == TearSide.left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, topY);
      path.lineTo(tearPoints[topIndex].dx + gapOffset, topY);

      for (int i = topIndex; i < bottomIndex; i++) {
        final cp = tearPoints[i];
        final next = tearPoints[i + 1];
        final midX = (cp.dx + next.dx) / 2 + gapOffset;
        final midY = (cp.dy + next.dy) / 2;
        path.quadraticBezierTo(cp.dx + gapOffset, cp.dy, midX, midY);
      }

      path.lineTo(tearPoints[bottomIndex].dx + gapOffset, bottomY);
      path.lineTo(size.width, bottomY);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, topY);
      path.lineTo(tearPoints[topIndex].dx + gapOffset, topY);

      for (int i = topIndex; i < bottomIndex; i++) {
        final cp = tearPoints[i];
        final next = tearPoints[i + 1];
        final midX = (cp.dx + next.dx) / 2 + gapOffset;
        final midY = (cp.dy + next.dy) / 2;
        path.quadraticBezierTo(cp.dx + gapOffset, cp.dy, midX, midY);
      }

      path.lineTo(tearPoints[bottomIndex].dx + gapOffset, bottomY);
      path.lineTo(0, bottomY);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(TearClipper oldClipper) =>
      tearTopRatio != oldClipper.tearTopRatio ||
      tearBottomRatio != oldClipper.tearBottomRatio ||
      gapOffset != oldClipper.gapOffset;
}
