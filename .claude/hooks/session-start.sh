#!/bin/bash
set -euo pipefail

# Only run in remote Claude Code environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

FLUTTER_VERSION=$(python3 -c "import json; print(json.load(open('$CLAUDE_PROJECT_DIR/.fvmrc'))['flutter'])")
FLUTTER_DIR="/opt/flutter"
FLUTTER_BIN="$FLUTTER_DIR/bin/flutter"

# ── 1. Flutter SDK ────────────────────────────────────────────────────────────
# Skip if already installed at the right version (container cache hit)
if "$FLUTTER_BIN" --version 2>/dev/null | grep -qF "$FLUTTER_VERSION"; then
  echo "✓ Flutter $FLUTTER_VERSION already installed"
else
  echo "› Installing Flutter $FLUTTER_VERSION..."
  ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${ARCHIVE}"
  wget -q --show-progress "$URL" -O /tmp/flutter.tar.xz
  rm -rf "$FLUTTER_DIR"
  tar -xf /tmp/flutter.tar.xz -C /opt
  rm /tmp/flutter.tar.xz
  echo "✓ Flutter $FLUTTER_VERSION installed"
fi

# Persist Flutter in PATH for the entire session
echo "export PATH=\"$FLUTTER_DIR/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
export PATH="$FLUTTER_DIR/bin:$PATH"

# Flutter complains about running as root; suppress the warning
export FLUTTER_SUPPRESS_ROOT_WARNING=true
echo "export FLUTTER_SUPPRESS_ROOT_WARNING=true" >> "$CLAUDE_ENV_FILE"

# Git refuses to access the flutter SDK dir when owned by a different user
git config --global --add safe.directory "$FLUTTER_DIR"

# Disable telemetry in CI/remote
flutter config --no-analytics 2>/dev/null || true

# ── 2. Flutter web artifacts ──────────────────────────────────────────────────
echo "› flutter precache --web..."
flutter precache --web

# ── 3. Dart / pub dependencies ────────────────────────────────────────────────
echo "› flutter pub get..."
cd "$CLAUDE_PROJECT_DIR"
flutter pub get

# ── 4. Website Node dependencies ─────────────────────────────────────────────
echo "› npm install (website)..."
cd "$CLAUDE_PROJECT_DIR/website"
npm install

echo "✓ All dependencies ready — Flutter $FLUTTER_VERSION + website node_modules"
