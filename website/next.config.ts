import type { NextConfig } from "next";

// Served as a GitHub Pages project site at https://alvish0407.github.io/clautter.
// Keep `basePath` in sync with BASE_PATH in src/lib/site.ts.
const nextConfig: NextConfig = {
  output: "export", // static HTML export → out/, deployable to GitHub Pages
  basePath: "/clautter",
  trailingSlash: true, // emit work/<id>/index.html so Pages serves clean URLs
  images: { unoptimized: true }, // no image optimisation server on Pages
};

export default nextConfig;
