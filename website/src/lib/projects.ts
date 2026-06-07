export type Project = {
  /** URL slug + Flutter registry id used for the embed deep-link. */
  id: string;
  title: string;
  /** Short tagline shown on the card. */
  blurb: string;
  /** Longer description shown on the project page. */
  description: string;
  tags: string[];
  /** Techniques used — listed on the project page. */
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
    id: "morphing_sphere",
    title: "3D Morphing Dot Sphere",
    blurb:
      "800 dots melt between a chaotic cloud and a perfect sphere, rotating in 3D with a sweeping colour wave.",
    description:
      "Eight hundred dots transition between a scattered chaotic cloud and a geometrically perfect sphere, rotating continuously in 3D. A colour wave sweeps top-to-bottom through a five-colour palette. Drag the slider inside to blend between the two states in real time.",
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
    video: "/previews/morphing_sphere.mp4",
    previewBg: "#000000",
    dark: true,
  },
  {
    id: "spider_dot_grid",
    title: "Spider Dot Grid",
    blurb:
      "An 8-legged spider chases your cursor across a dot grid, each foot snapping to the nearest dot with a natural gait.",
    description:
      "An 8-legged spider follows your cursor across a square dot grid. The body smooth-follows the pointer; each leg uses two-bone inverse kinematics to resolve its knee every frame. Feet snap to the nearest grid dot via an arc animation, and an alternating gait keeps at least four feet grounded at all times. Move your mouse over it.",
    tags: ["IK", "Gait", "CustomPaint", "Interactive"],
    techniques: [
      "Two-bone IK (law of cosines)",
      "Alternating gait groups",
      "Step arc (easeInOut + sinusoidal lift)",
      "Body lerp follow",
      "Cached grid rasterisation (ui.Image)",
      "Pointer events (Listener + MouseRegion)",
    ],
    video: "/previews/spider_dot_grid.mp4",
    previewBg: "#f5f5f5",
    dark: false,
  },
];

export function getProject(id: string): Project | undefined {
  return projects.find((p) => p.id === id);
}

/** Deep-link into the embedded Flutter build for a single animation. */
export function embedUrl(id: string): string {
  return `/embeds/clautter/index.html?animation=${encodeURIComponent(id)}`;
}
