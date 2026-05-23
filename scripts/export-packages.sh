#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$ROOT_DIR/packages"
mkdir -p "$PACKAGES_DIR"

log() {
  printf '%s\n' "$*"
}

if command -v apt-mark >/dev/null 2>&1; then
  apt-mark showmanual | sort > "$PACKAGES_DIR/apt-manual.txt"
  log "Wrote $PACKAGES_DIR/apt-manual.txt"
fi

if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app --columns=application | sort > "$PACKAGES_DIR/flatpak-apps.txt"
  log "Wrote $PACKAGES_DIR/flatpak-apps.txt"
fi

if command -v pnpm >/dev/null 2>&1; then
  pnpm list -g --depth=0 --json > "$PACKAGES_DIR/pnpm-global.json"
  log "Wrote $PACKAGES_DIR/pnpm-global.json"
fi

if command -v npm >/dev/null 2>&1; then
  npm list -g --depth=0 --json > "$PACKAGES_DIR/npm-global.json"
  log "Wrote $PACKAGES_DIR/npm-global.json"
fi

if command -v pipx >/dev/null 2>&1; then
  pipx list --json > "$PACKAGES_DIR/pipx.json"
  log "Wrote $PACKAGES_DIR/pipx.json"
fi

if command -v cargo >/dev/null 2>&1; then
  cargo install --list > "$PACKAGES_DIR/cargo-install-list.txt"
  log "Wrote $PACKAGES_DIR/cargo-install-list.txt"
fi

log "Package export complete."
