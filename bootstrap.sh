#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [options]

Options:
  --dry-run   Preview dotfile linking without changing files
  -h, --help  Show this help

What it does:
  1. Exports package manifests for the current system
  2. Installs/symlinks dotfiles via install.sh
  3. Installs zsh plugins (fzf, autosuggestions, history-substring-search)

Note: package installation is intentionally not automated yet.
EOF
}

DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1"; usage; exit 1 ;;
  esac
  shift
done

bash "$ROOT_DIR/scripts/export-packages.sh"

if [[ "$DRY_RUN" == true ]]; then
  bash "$ROOT_DIR/install.sh" --dry-run
  bash "$ROOT_DIR/scripts/install-zsh-plugins.sh"
else
  bash "$ROOT_DIR/install.sh"
  bash "$ROOT_DIR/scripts/install-zsh-plugins.sh"
fi
