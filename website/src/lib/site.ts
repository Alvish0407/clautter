// Base path the site is served from.
//
// This is a GitHub Pages project site at https://alvish0407.github.io/clautter,
// so everything lives under /clautter. Next prefixes <Link> hrefs and the router
// automatically; raw asset URLs (<video src>, <iframe src>) are not prefixed, so
// build those with BASE_PATH.
//
// Keep this in sync with `basePath` in next.config.ts.
export const BASE_PATH = "/clautter";

/** Prefix a public-asset path (e.g. "/previews/x.mp4") with the base path. */
export function asset(path: string): string {
  return `${BASE_PATH}${path}`;
}
