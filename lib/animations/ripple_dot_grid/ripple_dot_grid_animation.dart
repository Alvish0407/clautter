import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'models/dot_particle.dart';
import 'painters/ripple_painter.dart';

// ─── Physics & visual constants ───────────────────────────────────────────────

/// Spacing between dot home positions in logical pixels.
const double _kGridSpacing = 18.0;

/// Rendered radius of each dot.
const double _kDotRadius = 1.8;

/// Radius around an input point inside which dots are repelled.
const double _kRepelRadius = 32.0;

/// Base repulsion acceleration (px/s²) — applied when the cursor is still.
const double _kRepelStrength = 22000.0;

/// Cursor speed (px/s) at which the velocity boost reaches its maximum.
const double _kBoostThreshold = 500.0;

/// Maximum additional repulsion multiplier from cursor velocity.
/// e.g. 1.0 means fast swipes throw dots up to 2× harder than a still press.
const double _kMaxVelocityBoost = 1.0;

/// Spring stiffness (px/s² per px). Higher = snappier return.
const double _kSpring = 28.0;

/// Velocity damping per second. 13 > 2·√28 ≈ 10.6 → overdamped:
/// slow, smooth drift back with no oscillation.
const double _kDamping = 13.0;

// ──────────────────────────────────────────────────────────────────────────────

/// Entry widget for the Ripple Dot Grid animation.
///
/// Dots repel from the cursor/finger. Repulsion force is amplified by how fast
/// the input is moving — aggressive swipes throw dots much further than slow
/// presses. Spring-mass physics (underdamped) pull each dot back to its home
/// with a subtle overshoot that makes the return feel alive.
///
/// Cursor velocity is derived from position deltas between simulation frames,
/// then smoothed with a one-pole low-pass filter to avoid jitter.
///
/// Physics per frame (semi-implicit Euler):
///   boost   = 1 + clamp(cursorSpeed / threshold, 0, maxBoost)
///   F_repel = boost · baseStrength · falloff / dist
///   F_spring = −k · displacement
///   F_damp   = −c · velocity
///   vel     += (F_repel + F_spring + F_damp) · dt
///   pos     += vel · dt
class RippleDotGridAnimation extends StatefulWidget {
  const RippleDotGridAnimation({super.key});

  @override
  State<RippleDotGridAnimation> createState() => _RippleDotGridAnimationState();
}

class _RippleDotGridAnimationState extends State<RippleDotGridAnimation>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTime = Duration.zero;

  List<DotParticle> _dots = [];
  Size _builtSize = Size.zero;

  // ── Input positions (current frame) ────────────────────────────────────────
  final Map<int, Offset> _pointers = {};
  Offset? _mouseHover;

  // ── Previous-frame positions for velocity derivation ───────────────────────
  final Map<int, Offset> _prevPointers = {};
  Offset? _prevMouseHover;

  // ── Smoothed cursor velocities (low-pass filtered) ─────────────────────────
  final Map<int, Offset> _pointerVels = {};
  Offset _mouseHoverVel = Offset.zero;

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

    final startX = _kGridSpacing / 2;
    final startY = _kGridSpacing / 2;
    final cols = ((size.width - startX) / _kGridSpacing).ceil() + 1;
    final rows = ((size.height - startY) / _kGridSpacing).ceil() + 1;

    _dots = [
      for (int r = 0; r < rows; r++)
        for (int c = 0; c < cols; c++)
          DotParticle(Offset(startX + c * _kGridSpacing, startY + r * _kGridSpacing)),
    ];
    _allAtRest = true;
  }

  // ─── Ticker ────────────────────────────────────────────────────────────────

  void _onTick(Duration elapsed) {
    if (_allAtRest && _pointers.isEmpty && _mouseHover == null) return;

    final dt = _lastTime == Duration.zero
        ? 1 / 60
        : min((elapsed - _lastTime).inMicroseconds / 1e6, 1 / 15);
    _lastTime = elapsed;

    _updateInputVelocities(dt);
    _simulate(dt);
    setState(() {});
  }

  // ─── Cursor velocity (smoothed with a one-pole low-pass) ───────────────────

  void _updateInputVelocities(double dt) {
    // Low-pass smoothing factor — higher = more responsive, lower = smoother.
    const alpha = 0.6;

    for (final id in _pointers.keys) {
      final prev = _prevPointers[id];
      if (prev != null && dt > 0) {
        final raw = (_pointers[id]! - prev) / dt;
        final old = _pointerVels[id] ?? Offset.zero;
        _pointerVels[id] = old * (1 - alpha) + raw * alpha;
      } else {
        _pointerVels[id] = Offset.zero;
      }
      _prevPointers[id] = _pointers[id]!;
    }
    // Clear velocities for pointers that lifted.
    _pointerVels.removeWhere((id, _) => !_pointers.containsKey(id));
    _prevPointers.removeWhere((id, _) => !_pointers.containsKey(id));

    if (_mouseHover != null && _prevMouseHover != null && dt > 0) {
      final raw = (_mouseHover! - _prevMouseHover!) / dt;
      _mouseHoverVel = _mouseHoverVel * (1 - alpha) + raw * alpha;
    } else {
      _mouseHoverVel = Offset.zero;
    }
    _prevMouseHover = _mouseHover;
  }

  // ─── Physics ───────────────────────────────────────────────────────────────

  void _simulate(double dt) {
    // Build the list of (position, velocity) pairs for all active inputs.
    final inputs = <(Offset, Offset)>[
      for (final id in _pointers.keys) (_pointers[id]!, _pointerVels[id] ?? Offset.zero),
      if (_mouseHover != null) (_mouseHover!, _mouseHoverVel),
    ];

    bool anyMoving = false;

    for (final dot in _dots) {
      var fx = 0.0;
      var fy = 0.0;

      for (final (touch, inputVel) in inputs) {
        final dx = dot.pos.dx - touch.dx;
        final dy = dot.pos.dy - touch.dy;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist > 0 && dist < _kRepelRadius) {
          final t = 1.0 - dist / _kRepelRadius;
          // Smoothstep falloff: zero-derivative at both ends → no abrupt edge.
          final smooth = t * t * (3.0 - 2.0 * t);

          // Velocity boost: faster cursor = slightly stronger throw.
          final speed = inputVel.distance;
          final boost = 1.0 + (speed / _kBoostThreshold).clamp(0.0, _kMaxVelocityBoost);

          final mag = boost * smooth * _kRepelStrength / dist;
          fx += dx * mag;
          fy += dy * mag;
        }
      }

      // Spring: pull back to home.
      fx -= (dot.pos.dx - dot.home.dx) * _kSpring;
      fy -= (dot.pos.dy - dot.home.dy) * _kSpring;

      // Damping.
      fx -= dot.vel.dx * _kDamping;
      fy -= dot.vel.dy * _kDamping;

      // Semi-implicit Euler.
      final vx = dot.vel.dx + fx * dt;
      final vy = dot.vel.dy + fy * dt;
      dot.vel = Offset(vx, vy);
      dot.pos = Offset(dot.pos.dx + vx * dt, dot.pos.dy + vy * dt);

      if (!dot.isAtRest) anyMoving = true;
    }

    _allAtRest = !anyMoving && _pointers.isEmpty && _mouseHover == null;
    if (_allAtRest) {
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

  void _onPointerUp(PointerUpEvent e) {
    _pointers.remove(e.pointer);
    _prevPointers.remove(e.pointer);
    _pointerVels.remove(e.pointer);
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _pointers.remove(e.pointer);
    _prevPointers.remove(e.pointer);
    _pointerVels.remove(e.pointer);
  }

  void _onMouseHover(PointerHoverEvent e) {
    _mouseHover = e.localPosition;
    _allAtRest = false;
  }

  void _onMouseExit(PointerExitEvent e) {
    _mouseHover = null;
    _prevMouseHover = null;
    _mouseHoverVel = Offset.zero;
  }

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
          onPointerHover: _onMouseHover,
          child: MouseRegion(
            onExit: _onMouseExit,
            child: CustomPaint(
              size: size,
              painter: RipplePainter(dots: _dots, dotRadius: _kDotRadius),
            ),
          ),
        );
      },
    );
  }
}
