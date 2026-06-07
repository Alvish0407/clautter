import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'gallery/gallery_screen.dart';

void main() {
  runApp(const ClautterApp());
}

/// Root application widget.
class ClautterApp extends StatelessWidget {
  const ClautterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clautter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const GalleryScreen(),
    );
  }
}
