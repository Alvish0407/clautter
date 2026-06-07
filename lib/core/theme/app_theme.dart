import 'package:flutter/material.dart';

/// Centralised design tokens and [ThemeData] for Clautter.
///
/// The visual language follows a light, friendly, 60fps.design-inspired system:
/// a soft off-white canvas, near-black text, a single dominant blue accent,
/// generously rounded corners, and the Inter typeface throughout.
abstract final class AppTheme {
  // ── Brand font ────────────────────────────────────────────────────────────
  /// Loaded as a web font in `web/index.html`. Falls back to the platform
  /// sans-serif if unavailable.
  static const String fontFamily = 'Inter';

  // ── Palette ───────────────────────────────────────────────────────────────
  /// Page background / primary canvas.
  static const Color background = Color(0xFFF5F5F5);

  /// Card and elevated-surface fill.
  static const Color surface = Color(0xFFFFFFFF);

  /// Tag chips, subtle fills.
  static const Color surfaceVariant = Color(0xFFEFEFEF);

  /// Primary text — headings and body. (Near-black for softer contrast.)
  static const Color onSurface = Color(0xFF0A0A0A);

  /// Muted text — captions, descriptions, placeholders.
  static const Color onSurfaceMuted = Color(0xFF5C5C5C);

  /// Single dominant brand accent — CTAs, links, interactive highlights.
  static const Color primary = Color(0xFF0061FE);

  /// Back-compat alias used by the full-screen viewer.
  static const Color accent = primary;

  /// Dividers, card outlines.
  static const Color border = Color(0xFFEAEAEA);

  // ── Shape ─────────────────────────────────────────────────────────────────
  static const double radiusCard = 20;
  static const double radiusButton = 12;
  static const double radiusChip = 8;

  // ── Spacing (10px base grid) ──────────────────────────────────────────────
  static const double space1 = 10;
  static const double space2 = 20;
  static const double space3 = 30;
  static const double space4 = 40;

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: primary,
      surface: surface,
      onSurface: onSurface,
    );
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
