import 'package:flutter/material.dart';

import '../../animations/book_page_flip/book_page_flip_animation.dart';
import '../../animations/cosmo_gallery/cosmo_gallery_animation.dart';
import '../../animations/morphing_sphere/morphing_sphere_animation.dart';
import '../../animations/ripple_dot_grid/ripple_dot_grid_animation.dart';
import '../../animations/morphing_sphere/widgets/morph_preview.dart';
import '../../animations/spider_dot_grid/models/spider_config.dart';
import '../../animations/spider_dot_grid/spider_dot_grid_animation.dart';
import '../models/animation_meta.dart';

/// The single source of truth for every animation in Clautter.
///
/// To add a new animation:
/// 1. Create its folder under lib/animations/[name]/
/// 2. Build the entry widget following the existing pattern.
/// 3. Add an [AnimationMeta] entry here — the gallery picks it up automatically.
final List<AnimationMeta> animationRegistry = [
  AnimationMeta(
    id: 'book_page_flip',
    title: 'Book Page Flip',
    description:
        'An open book with real text content. Drag a page from the right '
        'to fold it over with a geometric perpendicular-bisector fold. '
        'The folded region reveals the next page underneath while the '
        'turned portion reflects across the fold line.',
    technicalSummary:
        'AnimationController · CustomPaint · perpendicular-bisector fold '
        'geometry · polygon clipping · matrix reflection transform · '
        'GestureDetector pan · fold-line shadow & highlight.',
    tags: const ['Geometry', 'CustomPaint', 'Interactive', 'Animation'],
    backgroundColor: const Color(0xFFBBBBBB),
    previewBackground: const Color(0xFFBBBBBB),
    builder: (_) => const BookPageFlipAnimation(),
  ),
  AnimationMeta(
    id: 'cosmo_gallery',
    title: '3D Cosmo Album Gallery',
    description:
        'A ring of Spotify album covers arranged in a perspective-projected 3-D '
        'circle. Auto-rotates slowly; drag, swipe, or scroll to spin it fast. '
        'Hover any poster to lift it and preview the artwork in the top-left corner.',
    technicalSummary:
        'Ticker · perspective projection · painter\'s algorithm depth sort · '
        'X-axis ring tilt · TweenAnimationBuilder hover lift · '
        'PointerScrollEvent trackpad · Image.network with RepaintBoundary.',
    tags: const ['3D', 'Interactive', 'Perspective', 'Network'],
    backgroundColor: Colors.white,
    previewBackground: Colors.white,
    builder: (_) => const CosmoGalleryAnimation(),
  ),
  AnimationMeta(
    id: 'morphing_sphere',
    title: '3D Morphing Dot Sphere',
    description:
        'Eight hundred dots transition between a scattered chaotic cloud and '
        'a geometrically perfect sphere, rotating continuously in 3D. '
        'A colour wave sweeps top-to-bottom through a five-colour palette.',
    technicalSummary:
        'Ticker · CustomPaint · spherical coordinates · golden-angle '
        'distribution · LERP · Y-axis rotation matrix · perspective '
        'projection · painter\'s algorithm · staggered colour blending.',
    tags: const ['3D', 'Math', 'CustomPaint', 'Perspective'],
    backgroundColor: Colors.black,
    previewBackground: Colors.black,
    previewVideoAsset: 'assets/previews/morphing_sphere.mp4',
    previewBuilder: (_) => const MorphingSpherePreview(),
    builder: (_) => const MorphingSphereAnimation(),
  ),
  AnimationMeta(
    id: 'ripple_dot_grid',
    title: 'Ripple Dot Grid',
    description:
        'A dense grid of dots fills the screen. Touch or drag anywhere to '
        'push dots aside — each dot springs back to its home position with '
        'satisfying damped oscillation. Multi-touch is fully supported.',
    technicalSummary:
        'Ticker · CustomPaint · spring-mass physics · semi-implicit Euler '
        'integration · radial repulsion · damped oscillation · multi-pointer '
        'Listener · idle-skip optimisation.',
    tags: const ['Physics', 'Interactive', 'CustomPaint', 'Multi-touch'],
    builder: (_) => const RippleDotGridAnimation(),
  ),
  AnimationMeta(
    id: 'spider_dot_grid',
    title: 'Spider Dot Grid',
    description:
        'An 8-legged spider follows your cursor across a square dot grid. '
        'Each foot snaps to the nearest grid dot via an arc animation, '
        'and an alternating gait ensures at least four feet are always grounded.',
    technicalSummary:
        'Ticker · CustomPaint · two-bone IK (law of cosines) · '
        'alternating gait groups · step arc (easeInOut + sin lift) · '
        'body lerp follow · cached grid rasterisation (ui.Image) · '
        'Listener + MouseRegion pointer events.',
    tags: const ['IK', 'Gait', 'CustomPaint', 'Interactive'],
    backgroundColor: kBackgroundColor,
    previewBackground: kBackgroundColor,
    previewVideoAsset: 'assets/previews/spider_dot_grid.mp4',
    builder: (_) => const SpiderDotGridAnimation(),
  ),
];
