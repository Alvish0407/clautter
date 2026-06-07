# Clautter

> A curated, open-source collection of Flutter animations — structured for readability, documented for understanding, and built for web embedding.

---

## What is Clautter?

Clautter is a living gallery of Flutter animations. Each animation lives in its own self-contained package under `lib/animations/`, with:

- **Separated concerns** — `models/`, `painters/`, `utils/`, and `widgets/` each have their own files.
- **Documented source** — every non-obvious decision (math, invariants, performance trade-offs) is explained inline.
- **Web-embedding ready** — the Flutter web build plugs into any JS framework via the [Flutter web embedding API](https://docs.flutter.dev/platform-integration/web/embedding-flutter-web).
- **Registry-driven gallery** — add one entry to `animation_registry.dart` and the animation appears in the gallery automatically.

---

## Animations

### 3D Morphing Dot Sphere

Eight hundred dots transition between a scattered chaotic cloud and a geometrically perfect sphere, rotating continuously in 3D. A colour wave sweeps top-to-bottom through a five-colour palette. An interactive slider lets you blend between the two states in real time.

**Techniques:** spherical coordinate generation · golden-angle distribution · LERP interpolation · Y-axis rotation matrix · perspective projection · painter's algorithm · staggered colour blending

### Spider Dot Grid

An 8-legged spider follows your cursor (or touch) across a square dot grid. The body smooth-follows the pointer via lerp. Each of the eight legs uses two-bone inverse kinematics (law of cosines) to resolve the knee position from the hip and foot every frame. Feet snap to the nearest grid dot via an arc animation (eased horizontal lerp + sinusoidal vertical lift). An alternating gait, where even legs and odd legs never step simultaneously, ensures at least four feet are grounded at all times.

**Techniques:** two-bone IK (law of cosines) · alternating gait groups · step arc animation (easeInOut + sinusoidal lift) · body lerp follow · cached grid rasterisation (`ui.Image`) · `Listener` + `MouseRegion` pointer events

### Ripple Dot Grid

A dense grid of dots fills the screen. Touch or drag anywhere and the dots nearby scatter away from your pointer, then spring back to their home positions with a damped, springy wobble. Multi-touch is fully supported, so every finger pushes its own ripple.

**Techniques:** spring-mass physics · semi-implicit Euler integration · radial repulsion · damped oscillation · multi-pointer `Listener` · idle-skip optimisation

---

## Project Structure

```
lib/
├── main.dart                                    # App entry → ClautterApp
├── core/
│   ├── models/
│   │   └── animation_meta.dart                  # AnimationMeta descriptor
│   ├── registry/
│   │   └── animation_registry.dart              # Central list of all animations
│   └── theme/
│       └── app_theme.dart                       # Design tokens + ThemeData
├── animations/
│   ├── morphing_sphere/
│   │   ├── morphing_sphere_animation.dart        # Entry widget (Ticker owner)
│   │   ├── models/
│   │   │   └── dot.dart                         # Dot · generateRandomDot · lerp · blendColor
│   │   ├── painters/
│   │   │   └── sphere_painter.dart              # SpherePainter (CustomPainter)
│   │   └── widgets/
│   │       └── morph_controls.dart              # Chaos ↔ Sphere slider
│   └── spider_dot_grid/
│       ├── spider_dot_grid_animation.dart        # Entry widget (Ticker + pointer events)
│       ├── models/
│       │   ├── spider_config.dart               # All kConstants + per-leg config arrays
│       │   └── leg.dart                         # Leg · startStep · updateStep
│       ├── painters/
│       │   └── spider_painter.dart              # SpiderPainter (CustomPainter)
│       └── utils/
│           └── spider_utils.dart               # computeKnee · snapToGrid · getPlateOffsets
├── gallery/
│   ├── gallery_screen.dart                      # Scrollable animation catalogue
│   └── animation_viewer.dart                    # Full-screen single-animation host
└── shared/
    └── widgets/
        └── animation_card.dart                  # Gallery card component
```

---

## Adding a New Animation

1. Create `lib/animations/<your_name>/` and add:
   - `<your_name>_animation.dart` — the stateful entry widget that owns the `Ticker`.
   - `models/` — plain Dart data classes and pure functions.
   - `painters/` — `CustomPainter` subclass(es).
   - `utils/` — pure helper functions (math, geometry, etc.).
   - `widgets/` — any interactive controls (sliders, buttons).
2. Register it in `lib/core/registry/animation_registry.dart` — the gallery picks it up automatically.

---

## Running Locally

```sh
# Install dependencies
flutter pub get

# Run on desktop (fastest iteration)
flutter run -d macos        # or linux / windows

# Run in Chrome
flutter run -d chrome

# Production web build
flutter build web --release
```

---

## Web Embedding

After `flutter build web --release`, embed the output in any JavaScript site:

```html
<!-- 1. Load the Flutter bootstrap script from your build/web output -->
<script src="flutter.js" defer></script>

<!-- 2. Target element — size it however you like -->
<div id="flutter-target" style="width: 100%; height: 600px;"></div>

<script>
  window.addEventListener('load', function () {
    _flutter.loader.load({
      config: { renderer: 'canvaskit' },
      onEntrypointLoaded: async function (engineInitializer) {
        const appRunner = await engineInitializer.initializeEngine({
          hostElement: document.getElementById('flutter-target'),
        });
        await appRunner.runApp();
      },
    });
  });
</script>
```

See the [Flutter web embedding docs](https://docs.flutter.dev/platform-integration/web/embedding-flutter-web) for deep-linking into a specific animation, message channels between Flutter and JS, and iframe isolation patterns.

---

## Contributing

Contributions are welcome. Open an issue to propose a new animation, or submit a PR following the structure above. The only requirement is that your animation lives entirely in its own folder and registers through `animation_registry.dart`.

---

## License

MIT
