import 'package:flutter/material.dart';

/// Centralised design tokens and [ThemeData] for Clautter.
abstract final class AppTheme {
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceVariant = Color(0xFF1E1E1E);
  static const Color onSurface = Color(0xFFE8E8E8);
  static const Color onSurfaceMuted = Color(0xFF888888);
  static const Color accent = Color(0xFFFFFFFF);

  static ThemeData get dark => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          surface: surface,
          onSurface: onSurface,
        ),
      );
}
