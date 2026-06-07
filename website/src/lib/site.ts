// Base path the site is served from.
//
// The site is served from the root of clautter.alvish.in (custom subdomain),
// so there is no path prefix in production. Raw asset URLs (<video src>,
// <iframe src>) are not prefixed automatically by Next, so build those with
// BASE_PATH.  Branch previews override via NEXT_PUBLIC_BASE_PATH (e.g.
// /preview/<branch>). Keep this in sync with next.config.ts.
export const BASE_PATH = process.env.NEXT_PUBLIC_BASE_PATH || "";

/** Prefix a public-asset path (e.g. "/previews/x.mp4") with the base path. */
export function asset(path: string): string {
  return `${BASE_PATH}${path}`;
}
