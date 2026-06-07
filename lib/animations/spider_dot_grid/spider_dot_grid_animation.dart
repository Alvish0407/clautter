import 'dart:math';
import 'package:flutter/material.dart';
import 'models/particle.dart';
import 'painters/spider_painter.dart';

/// Entry widget for the Spider Dot Grid animation.
///
/// Uses [LayoutBuilder] to know the canvas size before spawning particles,
/// then drives them forward each frame with Euler integration via a [Ticker].
class SpiderDotGridAnimation extends StatefulWidget {
  const SpiderDotGridAnimation({super.key});

  @override
  State<SpiderDotGridAnimation> createState() => _SpiderDotGridAnimationState();
}

class _SpiderDotGridAnimationState extends State<SpiderDotGridAnimation>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  List<Particle>? _particles;
  Size _canvasSize = Size.zero;
  DateTime? _lastTick;

  // Guard flag: prevents multiple postFrameCallbacks queuing up per frame.
  bool _initPending = false;

  static const int _particleCount = 80;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration _) {
    final now = DateTime.now();
    if (_lastTick != null && _particles != null) {
      final dt = now.difference(_lastTick!).inMicroseconds / 1e6;
      for (final p in _particles!) {
        stepParticle(p, dt, _canvasSize);
      }
    }
    _lastTick = now;
    setState(() {});
  }

  void _initParticles(Size size) {
    final rng = Random();
    _particles =
        List.generate(_particleCount, (_) => randomParticle(rng, size));
    _canvasSize = size;
    _initPending = false;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        if (size.width > 0 &&
            size.height > 0 &&
            (_particles == null || _canvasSize != size) &&
            !_initPending) {
          _initPending = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _initParticles(size));
          });
        }

        return CustomPaint(
          size: size,
          painter: SpiderPainter(particles: _particles ?? const []),
        );
      },
    );
  }
}
