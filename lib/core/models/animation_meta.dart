import 'package:flutter/material.dart';

/// Metadata descriptor for a single entry in the animation gallery.
///
/// [builder] produces the root widget of the animation; it is hosted
/// inside a full-screen [Scaffold] by [AnimationViewer].
class AnimationMeta {
  final String id;
  final String title;
  final String description;

  /// One-line summary of techniques used — shown at the bottom of the card.
  final String technicalSummary;

  final List<String> tags;
  final WidgetBuilder builder;

  /// Scaffold background colour for the full-screen viewer.
  /// Defaults to black; override for light-themed animations.
  final Color backgroundColor;

  /// Optional looping video shown as the gallery card thumbnail (asset path,
  /// e.g. `assets/previews/foo.mp4`). Preferred over [previewBuilder] when set —
  /// far cheaper than running many live tickers as the gallery grows.
  final String? previewVideoAsset;

  /// Optional lightweight widget shown as a live preview inside the gallery
  /// card when no [previewVideoAsset] is provided. Falls back to [builder] when
  /// omitted. Use this to strip interactive controls (sliders, buttons) from
  /// the thumbnail so it reads cleanly.
  final WidgetBuilder? previewBuilder;

  /// Background colour for the in-card preview canvas. Defaults to
  /// [backgroundColor].
  final Color? previewBackground;

  const AnimationMeta({
    required this.id,
    required this.title,
    required this.description,
    required this.technicalSummary,
    required this.tags,
    required this.builder,
    this.backgroundColor = Colors.black,
    this.previewVideoAsset,
    this.previewBuilder,
    this.previewBackground,
  });

  /// The widget to render inside the gallery card preview.
  WidgetBuilder get preview => previewBuilder ?? builder;

  /// The background behind the gallery card preview.
  Color get previewBg => previewBackground ?? backgroundColor;
}
