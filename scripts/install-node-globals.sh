#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NPM_MANIFEST="$ROOT_DIR/packages/npm-global.json"
PNPM_MANIFEST="$ROOT_DIR/packages/pnpm-global.json"

install_from_manifest() {
  local manager="$1"
  local manifest="$2"

  [[ -f "$manifest" ]] || return 0
  command -v python3 >/dev/null 2>&1 || {
    echo "python3 is required to parse $manifest" >&2
    exit 1
  }

  mapfile -t packages < <(python3 - "$manifest" <<'PY'
import json, sys
path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

def emit(d):
    for name, meta in sorted(d.items()):
        if name in {'npm', 'corepack', '@pnpm/exe'}:
            continue
        version = meta.get('version')
        if version:
            print(f"{name}@{version}")
        else:
            print(name)

if isinstance(data, list):
    for item in data:
        emit(item.get('dependencies', {}))
else:
    emit(data.get('dependencies', {}))
PY
)

  if [[ ${#packages[@]} -eq 0 ]]; then
    echo "No packages to install from $manifest"
    return 0
  fi

  echo "Installing with $manager: ${packages[*]}"
  "$manager" add -g "${packages[@]}"
}

if command -v pnpm >/dev/null 2>&1; then
  install_from_manifest pnpm "$PNPM_MANIFEST"
else
  echo "pnpm not found; skipping pnpm globals"
fi

if command -v npm >/dev/null 2>&1; then
  install_from_manifest npm "$NPM_MANIFEST"
else
  echo "npm not found; skipping npm globals"
fi
