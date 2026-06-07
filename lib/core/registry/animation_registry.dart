import '../models/animation_meta.dart';
import '../../animations/morphing_sphere/morphing_sphere_animation.dart';
import '../../animations/spider_dot_grid/spider_dot_grid_animation.dart';

/// The single source of truth for every animation in Clautter.
///
/// To add a new animation:
/// 1. Create its folder under lib/animations/<name>/
/// 2. Build the entry widget following the existing pattern.
/// 3. Add an [AnimationMeta] entry here — the gallery picks it up automatically.
final List<AnimationMeta> animationRegistry = [
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
    builder: (_) => const MorphingSphereAnimation(),
  ),
  AnimationMeta(
    id: 'spider_dot_grid',
    title: 'Spider Dot Grid',
    description:
        'Particles drift across the canvas and weave ephemeral connections '
        'whenever they wander close enough — like threads of a spider\'s web '
        'appearing and dissolving.',
    technicalSummary:
        'Ticker · CustomPaint · Euler integration · velocity-bounce '
        'boundaries · pairwise distance check · opacity falloff.',
    tags: const ['Particles', 'Physics', 'CustomPaint'],
    builder: (_) => const SpiderDotGridAnimation(),
  ),
];
