import 'package:flutter/material.dart';
import '../core/models/animation_meta.dart';
import '../core/theme/app_theme.dart';

/// Full-screen host for a single animation.
///
/// Renders edge-to-edge with a transparent app bar overlay.
/// The scaffold background colour comes from [AnimationMeta.backgroundColor]
/// so each animation can declare its own theme (e.g. light vs dark).
class AnimationViewer extends StatelessWidget {
  final AnimationMeta meta;

  const AnimationViewer({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: meta.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          // Use a dark icon on light backgrounds, white on dark.
          color: ThemeData.estimateBrightnessForColor(meta.backgroundColor) ==
                  Brightness.light
              ? Colors.black87
              : AppTheme.accent,
        ),
        title: Text(
          meta.title,
          style: TextStyle(
            color: ThemeData.estimateBrightnessForColor(meta.backgroundColor) ==
                    Brightness.light
                ? Colors.black87
                : AppTheme.accent,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: meta.builder(context),
    );
  }
}
