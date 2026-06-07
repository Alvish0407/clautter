import type { NextConfig } from "next";

// Served from a custom subdomain (clautter.alvish.in) at the root; branch
// previews override via NEXT_PUBLIC_BASE_PATH (e.g. /preview/<branch>).
// Keep this in sync with src/lib/site.ts.
const basePath = process.env.NEXT_PUBLIC_BASE_PATH || "";

const nextConfig: NextConfig = {
  output: "export", // static HTML export → out/, deployable to GitHub Pages
  basePath,
  trailingSlash: true, // emit work/<id>/index.html so Pages serves clean URLs
  images: { unoptimized: true }, // no image optimisation server on Pages
};

export default nextConfig;
