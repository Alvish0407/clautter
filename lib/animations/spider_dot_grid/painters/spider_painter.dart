import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/leg.dart';
import '../models/spider_config.dart';

/// Renders the spider and the dot grid onto a [Canvas].
///
/// The dot grid is drawn from a pre-rasterised [ui.Image] cached by the
/// owning widget, so only the spider itself is redrawn every frame.
///
/// Draw order (back to front):
/// 1. Cached grid image
/// 2. Leg segments  (hip → knee → foot)
/// 3. Knee joint squares
/// 4. Foot squares
/// 5. Body plate squares
/// 6. Body core rectangle
class SpiderPainter extends CustomPainter {
  final ui.Image? gridImage;
  final Offset bodyPosition;
  final List<Leg> legs;
  final List<Offset> plateOffsets;

  SpiderPainter({
    required this.gridImage,
    required this.bodyPosition,
    required this.legs,
    required this.plateOffsets,
  });

  // Static paints avoid per-frame allocation.
  static final _legPaint = Paint()
    ..color = kLegColor
    ..strokeWidth = kLegStrokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static final _bodyPaint = Paint()..color = kBodyColor;
  static final _footPaint = Paint()..color = kFootColor;
  static final _kneePaint = Paint()..color = kGridDotColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid (cached raster)
    if (gridImage != null) {
      canvas.drawImage(gridImage!, Offset.zero, Paint());
    }

    // 2. Leg segments: hip → knee → foot
    for (final leg in legs) {
      canvas.drawPath(
        Path()
          ..moveTo(leg.hipPoint.dx, leg.hipPoint.dy)
          ..lineTo(leg.kneePoint.dx, leg.kneePoint.dy)
          ..lineTo(leg.footPosition.dx, leg.footPosition.dy),
        _legPaint,
      );
    }

    // 3. Knee joints
    for (final leg in legs) {
      canvas.drawRect(
        Rect.fromCenter(
          center: leg.kneePoint,
          width: kKneeJointSize,
          height: kKneeJointSize,
        ),
        _kneePaint,
      );
    }

    // 4. Feet
    for (final leg in legs) {
      canvas.drawRect(
        Rect.fromCenter(
          center: leg.footPosition,
          width: kFootSize,
          height: kFootSize,
        ),
        _footPaint,
      );
    }

    // 5. Body plates
    for (final offset in plateOffsets) {
      canvas.drawRect(
        Rect.fromCenter(
          center: bodyPosition + offset,
          width: kBodyPlateSize,
          height: kBodyPlateSize,
        ),
        _bodyPaint,
      );
    }

    // 6. Body core
    canvas.drawRect(
      Rect.fromCenter(
        center: bodyPosition,
        width: kBodyWidth,
        height: kBodyHeight,
      ),
      _bodyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SpiderPainter _) => true;
}
