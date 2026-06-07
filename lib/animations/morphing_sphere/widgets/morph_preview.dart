import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/dot.dart';
import '../painters/sphere_painter.dart';

/// Controls-free, auto-rotating preview of the morphing sphere.
///
/// Used as the live thumbnail inside the gallery card. Identical rendering to
/// [MorphingSphereAnimation] but with the morph slider removed and a fixed,
/// fully-formed sphere so the card reads cleanly at a glance.
class MorphingSpherePreview extends StatefulWidget {
  const MorphingSpherePreview({super.key});

  @override
  State<MorphingSpherePreview> createState() => _MorphingSpherePreviewState();
}

class _MorphingSpherePreviewState extends State<MorphingSpherePreview>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final List<Dot> _dots;

  double _time = 0.0;
  DateTime? _lastTick;

  // Fewer dots than the full experience — keeps card previews lightweight
  // when several render at once.
  static const int _dotCount = 360;

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
    return LayoutBuilder(
      builder: (_, constraints) => CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: SpherePainter(
          dots: _dots,
          time: _time,
          morphAmount: 100, // always the fully-formed sphere in previews
        ),
      ),
    );
  }
}
