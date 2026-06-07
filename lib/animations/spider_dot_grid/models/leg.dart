import 'dart:math';
import 'package:flutter/material.dart';
import 'spider_config.dart';

/// A single leg of the spider, defined by three animated points.
///
/// When the foot drifts too far from its ideal grid position, [startStep]
/// begins an arc animation toward the new target grid dot. [updateStep]
/// advances the arc each tick using eased interpolation plus a sinusoidal
/// vertical lift so the foot visibly picks up off the surface.
class Leg {
  Offset footPosition;
  Offset footTarget;
  Offset footOrigin;

  /// World-space attachment point on the body plate (updated every frame).
  Offset hipPoint;

  /// IK-solved elbow point (updated every frame).
  Offset kneePoint;

  /// 0.0 = step just started, 1.0 = foot has arrived / at rest.
  double stepProgress;

  Leg({required this.footPosition})
    : footTarget = footPosition,
      footOrigin = footPosition,
      hipPoint = Offset.zero,
      kneePoint = Offset.zero,
      stepProgress = 1.0;

  bool get isStepping => stepProgress < 1.0;

  /// Begins an animated step arc toward [newTarget].
  void startStep(Offset newTarget) {
    footOrigin = footPosition;
    footTarget = newTarget;
    stepProgress = 0.0;
  }

  /// Advances the step animation by [dt] seconds.
  ///
  /// The foot traces an arc: horizontal position is eased-LERPed between
  /// origin and target while a sin curve provides the vertical lift.
  void updateStep(double dt) {
    if (!isStepping) return;
    stepProgress = (stepProgress + dt / kStepDuration).clamp(0.0, 1.0);
    final t = Curves.easeInOut.transform(stepProgress);
    final lift = kStepLiftHeight * sin(t * pi);
    final lerped = Offset.lerp(footOrigin, footTarget, t)!;
    footPosition = Offset(lerped.dx, lerped.dy - lift);
  }
}
