import 'package:flutter/material.dart';

import '../core/models/animation_meta.dart';

/// Full-screen host for a single animation.
///
/// Renders edge-to-edge with a transparent app bar overlay. The scaffold
/// background colour comes from [AnimationMeta.backgroundColor] so each
/// animation declares its own theme (light vs dark); the back arrow and title
/// adapt their colour to stay legible on either.
class AnimationViewer extends StatelessWidget {
  final AnimationMeta meta;

  const AnimationViewer({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    final onColor =
        ThemeData.estimateBrightnessForColor(meta.backgroundColor) ==
            Brightness.light
        ? Colors.black87
        : Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: meta.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onColor),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back to gallery',
        ),
        title: Text(
          meta.title,
          style: TextStyle(
            color: onColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: meta.builder(context),
    );
  }
}
