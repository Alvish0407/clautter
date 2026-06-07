import 'dart:math';
import 'package:flutter/material.dart';
import 'models/dot.dart';
import 'painters/sphere_painter.dart';
import 'widgets/morph_controls.dart';

/// Entry widget for the 3D Morphing Dot Sphere animation.
///
/// Owns the [Ticker] loop, the immutable [Dot] list, and the mutable
/// [_morphAmount] state. Delegates rendering to [SpherePainter] and
/// interactive controls to [MorphControls].
class MorphingSphereAnimation extends StatefulWidget {
  const MorphingSphereAnimation({super.key});

  @override
  State<MorphingSphereAnimation> createState() =>
      _MorphingSphereAnimationState();
}

class _MorphingSphereAnimationState extends State<MorphingSphereAnimation>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final List<Dot> _dots;

  double _time = 0.0;
  double _morphAmount = 100.0;
  DateTime? _lastTick;

  static const int _dotCount = 800;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _dots = List.generate(_dotCount, (_) => generateRandomDot(rng));
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration _) {
    final now = DateTime.now();
    if (_lastTick != null) {
      _time += now.difference(_lastTick!).inMicroseconds / 1e6;
    }
    _lastTick = now;
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) => CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: SpherePainter(
                dots: _dots,
                time: _time,
                morphAmount: _morphAmount,
              ),
            ),
          ),
        ),
        MorphControls(
          morphAmount: _morphAmount,
          onChanged: (v) => setState(() => _morphAmount = v),
        ),
      ],
    );
  }
}
