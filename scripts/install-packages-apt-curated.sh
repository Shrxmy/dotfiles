#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$ROOT_DIR/packages/apt-curated.txt"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found. This script is for Debian/Ubuntu-like systems." >&2
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "Missing manifest: $MANIFEST" >&2
  exit 1
fi

mapfile -t packages < <(grep -vE '^\s*(#|$)' "$MANIFEST")

if [[ ${#packages[@]} -eq 0 ]]; then
  echo "No packages found in $MANIFEST" >&2
  exit 1
fi

sudo apt-get update
sudo apt-get install -y "${packages[@]}"
