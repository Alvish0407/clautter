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

  const AnimationMeta({
    required this.id,
    required this.title,
    required this.description,
    required this.technicalSummary,
    required this.tags,
    required this.builder,
    this.backgroundColor = Colors.black,
  });
}
