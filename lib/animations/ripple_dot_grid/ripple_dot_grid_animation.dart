import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'models/dot_particle.dart';
import 'painters/ripple_painter.dart';

// ─── Physics & visual constants ───────────────────────────────────────────────

/// Spacing between dot home positions in logical pixels.
const double _kGridSpacing = 28.0;

/// Rendered radius of each dot.
const double _kDotRadius = 2.2;

/// Radius around a touch point inside which dots are repelled.
const double _kRepelRadius = 90.0;

/// Peak repulsion acceleration (px/s²) at zero distance.
const double _kRepelStrength = 18000.0;

/// Spring stiffness constant (px/s² per px of displacement).
const double _kSpring = 180.0;

/// Linear velocity damping factor per second.
const double _kDamping = 9.0;

// ──────────────────────────────────────────────────────────────────────────────

/// Entry widget for the Ripple Dot Grid animation.
///
/// A uniform grid of dots fills the canvas. Every dot is a spring-mass
/// particle with a rest position at its grid cell. Touch or drag events inject
/// a radial repulsion force; when the finger lifts, the dots spring back to
/// their home positions via damped oscillation.
///
/// Physics per frame (semi-implicit Euler):
///   F = repulsion(touch) − spring·displacement − damping·velocity
///   vel += F · dt
///   pos += vel · dt
class RippleDotGridAnimation extends StatefulWidget {
  const RippleDotGridAnimation({super.key});

  @override
  State<RippleDotGridAnimation> createState() =>
      _RippleDotGridAnimationState();
}

class _RippleDotGridAnimationState extends State<RippleDotGridAnimation>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTime = Duration.zero;

  List<DotParticle> _dots = [];
  Size _builtSize = Size.zero;

  /// Active pointer positions keyed by pointer ID.
  final Map<int, Offset> _pointers = {};

  /// Whether all dots are at rest and no pointers are active.
  bool _allAtRest = true;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // ─── Grid construction ─────────────────────────────────────────────────────

  void _buildGrid(Size size) {
    if (size == _builtSize) return;
    _builtSize = size;

    // Offset the grid by half a spacing so dots don't sit on the very edge.
    final startX = _kGridSpacing / 2;
    final startY = _kGridSpacing / 2;
    final cols = ((size.width - startX) / _kGridSpacing).ceil() + 1;
    final rows = ((size.height - startY) / _kGridSpacing).ceil() + 1;

    _dots = [
      for (int r = 0; r < rows; r++)
        for (int c = 0; c < cols; c++)
          DotParticle(
            Offset(startX + c * _kGridSpacing, startY + r * _kGridSpacing),
          ),
    ];
    _allAtRest = true;
  }

  // ─── Ticker ────────────────────────────────────────────────────────────────

  void _onTick(Duration elapsed) {
    // Skip physics when nothing is happening.
    if (_allAtRest && _pointers.isEmpty) return;

    final dt = _lastTime == Duration.zero
        ? 1 / 60
        : min((elapsed - _lastTime).inMicroseconds / 1e6, 1 / 15);
    _lastTime = elapsed;

    _simulate(dt);
    setState(() {});
  }

  void _simulate(double dt) {
    bool anyMoving = false;

    for (final dot in _dots) {
      var fx = 0.0;
      var fy = 0.0;

      // Repulsion from every active touch point.
      for (final touch in _pointers.values) {
        final dx = dot.pos.dx - touch.dx;
        final dy = dot.pos.dy - touch.dy;
        final distSq = dx * dx + dy * dy;
        final dist = sqrt(distSq);
        if (dist > 0 && dist < _kRepelRadius) {
          // Force falls off linearly from centre to edge of radius.
          final t = 1.0 - dist / _kRepelRadius;
          final mag = t * t * _kRepelStrength / dist;
          fx += dx * mag;
          fy += dy * mag;
        }
      }

      // Spring force: pulls dot back to home.
      fx -= (dot.pos.dx - dot.home.dx) * _kSpring;
      fy -= (dot.pos.dy - dot.home.dy) * _kSpring;

      // Damping.
      fx -= dot.vel.dx * _kDamping;
      fy -= dot.vel.dy * _kDamping;

      // Semi-implicit Euler integration.
      final vx = dot.vel.dx + fx * dt;
      final vy = dot.vel.dy + fy * dt;
      dot.vel = Offset(vx, vy);
      dot.pos = Offset(dot.pos.dx + vx * dt, dot.pos.dy + vy * dt);

      if (!dot.isAtRest) anyMoving = true;
    }

    _allAtRest = !anyMoving && _pointers.isEmpty;
    if (_allAtRest) {
      // Snap every dot exactly to home to avoid floating-point drift.
      for (final dot in _dots) {
        dot.reset();
      }
    }
  }

  // ─── Pointer handling ──────────────────────────────────────────────────────

  void _onPointerDown(PointerDownEvent e) {
    _pointers[e.pointer] = e.localPosition;
    _allAtRest = false;
  }

  void _onPointerMove(PointerMoveEvent e) {
    _pointers[e.pointer] = e.localPosition;
    _allAtRest = false;
  }

  void _onPointerUp(PointerUpEvent e) => _pointers.remove(e.pointer);
  void _onPointerCancel(PointerCancelEvent e) => _pointers.remove(e.pointer);

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _buildGrid(size);

        return Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: CustomPaint(
            size: size,
            painter: RipplePainter(dots: _dots, dotRadius: _kDotRadius),
          ),
        );
      },
    );
  }
}
