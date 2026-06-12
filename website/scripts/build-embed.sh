#!/usr/bin/env bash
#
# Rebuild the embeddable Flutter web bundle into website/public/embeds/clautter.
#
# Run from anywhere; paths are resolved relative to this script.
#
# base-href note:
#   The site is served from a custom subdomain (clautter.alvish.in) at the root,
#   so the embed lives at /embeds/clautter/. Branch previews override this via
#   preview.yml's sed rewrite, which expects exactly this base-href value.
#
# Why we delete canvaskit/ afterwards:
#   `flutter build web` (dart2js + CanvasKit renderer) always ships a full local
#   CanvasKit distribution (~38 MB) as an offline fallback: base canvaskit,
#   chromium variant, skwasm, skwasm_heavy, wimp, experimental_webparagraph.
#   At runtime, with the default config (useLocalCanvasKit = false), the engine
#   loads CanvasKit from the gstatic CDN instead and never touches the local
#   folder (verified via a headless-Chrome net-log). So the whole folder is dead
#   weight and we drop it, taking the embed from ~42 MB to ~3.5 MB.
set -euo pipefail

BASE_HREF="/embeds/clautter/"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EMBED_DIR="$REPO_ROOT/website/public/embeds/clautter"

cd "$REPO_ROOT"
echo "› flutter build web (base-href $BASE_HREF)…"
flutter build web --release --base-href "$BASE_HREF"

echo "› copying build → website/public/embeds/clautter…"
rm -rf "$EMBED_DIR"
mkdir -p "$REPO_ROOT/website/public/embeds"
cp -R "$REPO_ROOT/build/web" "$EMBED_DIR"

echo "› stripping unused local CanvasKit (loaded from gstatic CDN at runtime)…"
rm -rf "$EMBED_DIR/canvaskit"

# The embed is only ever loaded with ?animation=<id>, which boots straight into a
# single animation, never the gallery/video-preview cards. So the preview clips
# bundled into the Flutter build are never requested here (the website serves its
# own copies from public/previews/ for the cards). Drop them (~2 MB).
echo "› stripping unused preview videos from embed assets…"
rm -rf "$EMBED_DIR/assets/assets/previews"

echo "✓ embed rebuilt: $(du -sh "$EMBED_DIR" | cut -f1)"
