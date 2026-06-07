# Clautter

> A curated, open-source collection of Flutter animations — structured for readability, documented for understanding, and built for web embedding.

---

## What is Clautter?

Clautter is a living gallery of Flutter animations. Each animation lives in its own self-contained package under `lib/animations/`, with:

- **Separated concerns** — `models/`, `painters/`, and `widgets/` each have their own files.
- **Documented source** — every non-obvious decision (math, invariants, performance trade-offs) is explained inline.
- **Web-embedding ready** — the Flutter web build plugs into any JS framework via the [Flutter web embedding API](https://docs.flutter.dev/platform-integration/web/embedding-flutter-web).
- **Registry-driven gallery** — add one entry to `animation_registry.dart` and the animation appears in the gallery automatically.

---

## Animations

### 3D Morphing Dot Sphere

Eight hundred dots transition between a scattered chaotic cloud and a geometrically perfect sphere, rotating continuously in 3D. A colour wave sweeps top-to-bottom through a five-colour palette. An interactive slider lets you blend between the two states in real time.

**Techniques:** spherical coordinate generation · golden-angle distribution · LERP interpolation · Y-axis rotation matrix · perspective projection · painter's algorithm · staggered colour blending

### Spider Dot Grid

Eighty particles drift across the canvas and bounce off edges. Whenever two particles wander within 150 px of each other, a translucent line forms between them — the closer they are, the more opaque the line — evoking threads of a spider's web appearing and dissolving.

**Techniques:** Euler particle integration · velocity-bounce boundaries · pairwise O(n²) distance check · linear opacity falloff

---

## Project Structure

```
lib/
├── main.dart                                 # App entry → ClautterApp
├── core/
│   ├── models/
│   │   └── animation_meta.dart               # AnimationMeta descriptor
│   ├── registry/
│   │   └── animation_registry.dart           # Central list of all animations
│   └── theme/
│       └── app_theme.dart                    # Design tokens + ThemeData
├── animations/
│   ├── morphing_sphere/
│   │   ├── morphing_sphere_animation.dart    # Entry widget (Ticker owner)
│   │   ├── models/
│   │   │   └── dot.dart                      # Dot · generateRandomDot · lerp · blendColor
│   │   ├── painters/
│   │   │   └── sphere_painter.dart           # SpherePainter (CustomPainter)
│   │   └── widgets/
│   │       └── morph_controls.dart           # Chaos ↔ Sphere slider
│   └── spider_dot_grid/
│       ├── spider_dot_grid_animation.dart    # Entry widget (Ticker owner)
│       ├── models/
│       │   └── particle.dart                 # Particle · randomParticle · stepParticle
│       └── painters/
│           └── spider_painter.dart           # SpiderPainter (CustomPainter)
├── gallery/
│   ├── gallery_screen.dart                   # Scrollable animation catalogue
│   └── animation_viewer.dart                 # Full-screen single-animation host
└── shared/
    └── widgets/
        └── animation_card.dart               # Gallery card component
```

---

## Adding a New Animation

1. Create `lib/animations/<your_name>/` and add:
   - `<your_name>_animation.dart` — the stateful entry widget that owns the `Ticker`.
   - `models/` — plain Dart data classes and pure functions.
   - `painters/` — `CustomPainter` subclass(es).
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

## Design System

| Token | Value | Usage |
|---|---|---|
| `AppTheme.background` | `#0A0A0A` | Scaffold background |
| `AppTheme.surface` | `#141414` | Cards |
| `AppTheme.surfaceVariant` | `#1E1E1E` | Tag chips |
| `AppTheme.onSurface` | `#E8E8E8` | Primary text |
| `AppTheme.onSurfaceMuted` | `#888888` | Secondary text, icons |
| `AppTheme.accent` | `#FFFFFF` | App bar title, back arrow |

---

## Contributing

Contributions are welcome. Open an issue to propose a new animation, or submit a PR following the structure above. The only requirement is that your animation lives entirely in its own folder and registers through `animation_registry.dart`.

---

## License

MIT
