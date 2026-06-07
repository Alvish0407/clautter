import 'package:flutter/material.dart';
import '../core/models/animation_meta.dart';
import '../core/theme/app_theme.dart';

/// Full-screen host for a single animation.
///
/// Renders edge-to-edge with a transparent app bar overlay so the
/// animation canvas fills the entire screen.
class AnimationViewer extends StatelessWidget {
  final AnimationMeta meta;

  const AnimationViewer({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.accent),
        title: Text(
          meta.title,
          style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: meta.builder(context),
    );
  }
}
