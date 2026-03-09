import 'dart:ui';
import 'package:flutter/rendering.dart';

enum TearSide { left, right }

/// Clips a widget to one side of a jagged tear line.
class TearClipper extends CustomClipper<Path> {
  final List<Offset> tearPoints;
  final double tearProgress;
  final TearSide side;
  final double gapOffset;

  TearClipper({
    required this.tearPoints,
    required this.tearProgress,
    required this.side,
    this.gapOffset = 0,
  });

  @override
  Path getClip(Size size) {
    if (tearProgress <= 0) {
      return Path()..addRect(Offset.zero & size);
    }

    final visibleCount =
        (tearPoints.length * tearProgress).round().clamp(0, tearPoints.length);
    final path = Path();

    if (side == TearSide.left) {
      path.moveTo(0, 0);
      path.lineTo(tearPoints.first.dx + gapOffset, 0);

      // Follow tear line with smooth curves
      for (int i = 0; i < visibleCount - 1; i++) {
        final cp = tearPoints[i];
        final next = tearPoints[i + 1];
        final midX = (cp.dx + next.dx) / 2 + gapOffset;
        final midY = (cp.dy + next.dy) / 2;
        path.quadraticBezierTo(cp.dx + gapOffset, cp.dy, midX, midY);
      }
      if (visibleCount > 0) {
        final last = tearPoints[visibleCount - 1];
        path.lineTo(last.dx + gapOffset, last.dy);
      }

      if (visibleCount < tearPoints.length) {
        final lastY =
            tearPoints[visibleCount.clamp(0, tearPoints.length - 1)].dy;
        path.lineTo(size.width, lastY);
        path.lineTo(size.width, size.height);
      } else {
        path.lineTo(tearPoints.last.dx + gapOffset, size.height);
      }
      path.lineTo(0, size.height);
      path.close();
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(tearPoints.first.dx + gapOffset, 0);

      for (int i = 0; i < visibleCount - 1; i++) {
        final cp = tearPoints[i];
        final next = tearPoints[i + 1];
        final midX = (cp.dx + next.dx) / 2 + gapOffset;
        final midY = (cp.dy + next.dy) / 2;
        path.quadraticBezierTo(cp.dx + gapOffset, cp.dy, midX, midY);
      }
      if (visibleCount > 0) {
        final last = tearPoints[visibleCount - 1];
        path.lineTo(last.dx + gapOffset, last.dy);
      }

      if (visibleCount < tearPoints.length) {
        final lastY =
            tearPoints[visibleCount.clamp(0, tearPoints.length - 1)].dy;
        path.lineTo(0, lastY);
        path.lineTo(0, size.height);
      } else {
        path.lineTo(tearPoints.last.dx + gapOffset, size.height);
      }
      path.lineTo(size.width, size.height);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(TearClipper oldClipper) =>
      tearProgress != oldClipper.tearProgress ||
      gapOffset != oldClipper.gapOffset;
}
