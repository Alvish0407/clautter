import 'package:flutter/material.dart';

import 'core/registry/animation_registry.dart';
import 'core/theme/app_theme.dart';
import 'gallery/animation_viewer.dart';
import 'gallery/gallery_screen.dart';

void main() {
  runApp(const ClautterApp());
}

/// Root application widget.
///
/// When loaded with an `?animation=<id>` query parameter (used when a single
/// animation is embedded in an external site via iframe), the app boots
/// directly into that animation full-screen, with no gallery chrome. Otherwise
/// it shows the full gallery.
class ClautterApp extends StatelessWidget {
  const ClautterApp({super.key});

  /// The animation id requested via the page URL, if it resolves to a
  /// registered animation.
  static String? get embeddedId {
    final id = Uri.base.queryParameters['animation'];
    if (id == null) return null;
    return animationRegistry.any((m) => m.id == id) ? id : null;
  }

  @override
  Widget build(BuildContext context) {
    final id = embeddedId;

    return MaterialApp(
      title: 'Clautter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: id != null
          ? AnimationViewer(
              meta: animationRegistry.firstWhere((m) => m.id == id),
              embedded: true,
            )
          : const GalleryScreen(),
    );
  }
}
