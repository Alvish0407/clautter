import { asset } from "./site";

export type Project = {
  /** URL slug + Flutter registry id used for the embed deep-link. */
  id: string;
  title: string;
  /** Short tagline shown on the card. */
  blurb: string;
  /** Longer description shown on the project page. */
  description: string;
  tags: string[];
  /** Techniques used, listed on the project page. */
  techniques: string[];
  /** Looping preview clip in /public/previews. */
  video: string;
  /** Background behind the preview/embed (matches the animation's own canvas). */
  previewBg: string;
  /** Whether the preview video should be shown on a dark surface. */
  dark: boolean;
};

export const projects: Project[] = [
  {
    id: "cosmo_gallery",
    title: "3D Cosmo Album Gallery",
    blurb:
      "Spotify album covers arranged in a spinning 3D ring. Each poster is physically rotated in 3D space — side cards appear edge-on, front cards face you. Drag or scroll to spin it.",
    description:
      "A ring of album art posters arranged around a perspective-projected 3D circle. Each card is individually rotated around its Y axis so it faces outward from the ring centre — giving the look of pages on a spinning cylinder. Cards near the sides appear nearly edge-on; front cards face you directly. The ring auto-rotates slowly and responds to drag, swipe, and trackpad scroll. Hover any poster to lift it out of the ring and see a larger preview with title and artist in the top-left corner.",
    tags: ["3D", "Interactive", "Perspective", "Network"],
    techniques: [
      "Per-card Y-axis rotation (Matrix4.rotateY)",
      "Perspective projection (painter's algorithm depth sort)",
      "X-axis ring tilt — viewed from above",
      "TweenAnimationBuilder hover lift",
      "Momentum + friction on drag/scroll",
      "Image.network + RepaintBoundary caching",
      "AnimatedSwitcher preview overlay",
    ],
    video: asset("/previews/3d_cosmo_album_gallery.mp4"),
    previewBg: "#ffffff",
    dark: false,
  },
  {
    id: "morphing_sphere",
    title: "3D Morphing Dot Sphere",
    blurb:
      "800 dots drift around as a messy cloud, then pull together into a perfect sphere. It spins the whole time with a wave of colour rolling through it.",
    description:
      "Eight hundred dots float around as a loose, messy cloud, then snap together into a clean sphere, all while spinning in 3D. A wave of colour rolls down through them from top to bottom. There's a slider inside, so you can drag it and morph between the messy cloud and the sphere yourself.",
    tags: ["3D", "Math", "CustomPaint", "Perspective"],
    techniques: [
      "Spherical coordinate generation",
      "Golden-angle distribution",
      "LERP interpolation",
      "Y-axis rotation matrix",
      "Perspective projection",
      "Painter's algorithm",
      "Staggered colour blending",
    ],
    video: asset("/previews/morphing_sphere.mp4"),
    previewBg: "#000000",
    dark: true,
  },
  {
    id: "spider_dot_grid",
    title: "Spider Dot Grid",
    blurb:
      "A little 8-legged spider that chases your cursor across a grid of dots, planting each foot on the nearest dot as it walks.",
    description:
      "An eight-legged spider that follows your cursor around a grid of dots. Its body eases toward your pointer, and each leg figures out where its knee should bend on every frame. The feet step to the nearest dot with a little hop, and it always keeps at least four feet down so the walk looks natural. Move your mouse over it and it'll come after you.",
    tags: ["IK", "Gait", "CustomPaint", "Interactive"],
    techniques: [
      "Two-bone IK (law of cosines)",
      "Alternating gait groups",
      "Step arc (easeInOut + sinusoidal lift)",
      "Body lerp follow",
      "Cached grid rasterisation (ui.Image)",
      "Pointer events (Listener + MouseRegion)",
    ],
    video: asset("/previews/spider_dot_grid.mp4"),
    previewBg: "#f5f5f5",
    dark: false,
  },
  {
    id: "ripple_dot_grid",
    title: "Ripple Dot Grid",
    blurb:
      "A whole screen of dots. Touch or drag and they scatter out of the way, then bounce back into place with a springy little wobble.",
    description:
      "The screen fills with a tight grid of dots. Drag or tap anywhere and the dots near your pointer get shoved out of the way, then spring back home with a bouncy, damped wobble. It handles several touches at once, so every finger sets off its own ripple.",
    tags: ["Physics", "Interactive", "CustomPaint", "Multi-touch"],
    techniques: [
      "Spring-mass physics",
      "Semi-implicit Euler integration",
      "Radial repulsion",
      "Damped oscillation",
      "Multi-pointer input (Listener)",
      "Idle-skip optimisation",
    ],
    video: asset("/previews/ripple_dot_grid.mp4"),
    previewBg: "#000000",
    dark: true,
  },
];

export function getProject(id: string): Project | undefined {
  return projects.find((p) => p.id === id);
}

/** Deep-link into the embedded Flutter build for a single animation. */
export function embedUrl(id: string): string {
  return asset(`/embeds/clautter/index.html?animation=${encodeURIComponent(id)}`);
}
