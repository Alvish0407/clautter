import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'models/leg.dart';
import 'models/spider_config.dart';
import 'painters/spider_painter.dart';
import 'utils/spider_utils.dart';

/// Entry widget for the Spider Dot Grid animation.
///
/// An 8-legged spider follows the pointer across a square dot grid.
/// Movement is governed by:
/// - **Body**: smooth lerp toward the pointer each frame.
/// - **Gait**: alternating groups — even legs (A) and odd legs (B) never
///   step simultaneously, producing a natural walking rhythm.
/// - **IK**: two-bone inverse kinematics (law of cosines) resolves the
///   knee position from the hip and foot each frame.
/// - **Steps**: when a foot drifts past [kStepThreshold] from its ideal
///   grid position, it arcs to the nearest grid dot via an eased animation.
/// - **Grid**: the dot background is rasterised once into a [ui.Image] and
///   reused every frame — only the spider is painted live.
class SpiderDotGridAnimation extends StatefulWidget {
  const SpiderDotGridAnimation({super.key});

  @override
  State<SpiderDotGridAnimation> createState() => _SpiderDotGridAnimationState();
}

class _SpiderDotGridAnimationState extends State<SpiderDotGridAnimation>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTime = Duration.zero;

  Offset _bodyPosition = Offset.zero;
  Offset _targetPosition = Offset.zero;
  bool _initialized = false;

  late final List<Leg> _legs;
  double _gridSpacing = 50.0;

  ui.Image? _gridImage;
  Size _cachedGridSize = Size.zero;

  late final List<Offset> _plateOffsets;

  @override
  void initState() {
    super.initState();
    _legs = List.generate(8, (_) => Leg(footPosition: Offset.zero));
    _plateOffsets = getPlateOffsets();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _gridImage?.dispose();
    super.dispose();
  }

  void _initializeSpider(Size size) {
    if (_initialized) return;
    _initialized = true;

    // Aim for roughly 12–16 columns of dots across the canvas.
    final cols = size.width / 50.0;
    _gridSpacing = cols < 12
        ? size.width / 12.0
        : cols > 16
        ? size.width / 16.0
        : 50.0;

    final center = Offset(size.width / 2, size.height / 2);
    _bodyPosition = center;
    _targetPosition = center;

    // Place each foot at the nearest grid dot to its ideal rest position.
    for (int i = 0; i < 8; i++) {
      final ideal = Offset(
        center.dx + kLegRestDistance * cos(kLegRestAngles[i]),
        center.dy + kLegRestDistance * sin(kLegRestAngles[i]),
      );
      final snapped = snapToGrid(ideal, _gridSpacing);
      _legs[i].footPosition = snapped;
      _legs[i].footTarget = snapped;
      _legs[i].footOrigin = snapped;
    }
  }

  /// Rasterises the entire dot grid into a [ui.Image] once per canvas size.
  ///
  /// Redrawing hundreds of rectangles per frame is expensive; caching them
  /// as a GPU texture keeps frame time minimal.
  void _buildGridImage(Size size) {
    if (_gridImage != null && _cachedGridSize == size) return;
    _gridImage?.dispose();
    _cachedGridSize = size;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = kGridDotColor;

    final cols = (size.width / _gridSpacing).ceil() + 1;
    final rows = (size.height / _gridSpacing).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(c * _gridSpacing, r * _gridSpacing),
            width: kGridDotSize,
            height: kGridDotSize,
          ),
          paint,
        );
      }
    }

    final picture = recorder.endRecording();
    _gridImage = picture.toImageSync(size.width.ceil(), size.height.ceil());
    picture.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!_initialized) return;
    final dt = _lastTime == Duration.zero
        ? 1 / 60
        : (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;
    _update(dt);
    setState(() {});
  }

  void _update(double dt) {
    // 1. Smooth-follow: body lerps toward the pointer target each frame.
    _bodyPosition = Offset(
      _bodyPosition.dx +
          (_targetPosition.dx - _bodyPosition.dx) * kBodyFollowSpeed,
      _bodyPosition.dy +
          (_targetPosition.dy - _bodyPosition.dy) * kBodyFollowSpeed,
    );

    // 2. Recompute hip attachment points from new body position.
    for (int i = 0; i < 8; i++) {
      _legs[i].hipPoint = _bodyPosition + _plateOffsets[kLegPlateIndex[i]];
    }

    // 3. Alternating gait: group A (even) and group B (odd) never step
    //    at the same time, so at least 4 feet are always on the ground.
    final groupAStepping = [0, 2, 4, 6].any((i) => _legs[i].isStepping);
    final groupBStepping = [1, 3, 5, 7].any((i) => _legs[i].isStepping);

    for (int i = 0; i < 8; i++) {
      if (_legs[i].isStepping) continue;
      final ideal = Offset(
        _bodyPosition.dx + kLegRestDistance * cos(kLegRestAngles[i]),
        _bodyPosition.dy + kLegRestDistance * sin(kLegRestAngles[i]),
      );
      final snapped = snapToGrid(ideal, _gridSpacing);
      if ((_legs[i].footPosition - snapped).distance > kStepThreshold) {
        final inGroupA = i % 2 == 0;
        if (inGroupA && !groupBStepping) _legs[i].startStep(snapped);
        if (!inGroupA && !groupAStepping) _legs[i].startStep(snapped);
      }
    }

    // 4. Advance all active step arcs.
    for (final leg in _legs) {
      leg.updateStep(dt);
    }

    // 5. Solve IK: compute knee positions from hip and foot.
    for (int i = 0; i < 8; i++) {
      _legs[i].kneePoint = computeKnee(
        _legs[i].hipPoint,
        _legs[i].footPosition,
        kUpperLegLength,
        kLowerLegLength,
        bendLeft: kLegBendLeft[i],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initializeSpider(size);
        _buildGridImage(size);

        return Listener(
          onPointerMove: (e) => _targetPosition = e.localPosition,
          onPointerDown: (e) => _targetPosition = e.localPosition,
          child: MouseRegion(
            onHover: (e) => _targetPosition = e.localPosition,
            child: CustomPaint(
              size: size,
              painter: SpiderPainter(
                gridImage: _gridImage,
                bodyPosition: _bodyPosition,
                legs: _legs,
                plateOffsets: _plateOffsets,
              ),
            ),
          ),
        );
      },
    );
  }
}
