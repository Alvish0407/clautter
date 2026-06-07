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
    video: "/previews/morphing_sphere.mp4",
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
