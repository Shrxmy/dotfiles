#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false
FORCE=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --dry-run   Show planned actions without changing files
  --force     Overwrite existing files/symlinks without backup
  -h, --help  Show this help

This script links dotfiles from this repository into your home directory.
EOF
}

log() {
  printf '%s\n' "$*"
}

run_cmd() {
  if [[ "$DRY_RUN" == true ]]; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

detect_os() {
  case "$(uname -s)" in
    Linux) log "Detected OS: Linux" ;;
    Darwin) log "Detected OS: macOS" ;;
    *)
      log "Unsupported OS: $(uname -s)"
      log "This script supports Linux and macOS only."
      exit 1
      ;;
  esac
}

ensure_backup_dir() {
  if [[ "$FORCE" == false && "$DRY_RUN" == false ]]; then
    mkdir -p "$BACKUP_DIR"
  fi
}

backup_path() {
  local target="$1"

  if [[ "$FORCE" == true ]]; then
    run_cmd rm -rf "$target"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log "[dry-run] mv \"$target\" \"$BACKUP_DIR/$(basename "$target")\""
    return
  fi

  mv "$target" "$BACKUP_DIR/$(basename "$target")"
}

link_file() {
  local source="$1"
  local target="$2"
  local target_dir

  target_dir="$(dirname "$target")"

  if [[ ! -e "$source" ]]; then
    log "Skipping missing source: $source"
    return
  fi

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    log "Already linked: $target -> $source"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    log "Existing target found: $target"
    backup_path "$target"
  fi

  run_cmd mkdir -p "$target_dir"
  run_cmd ln -s "$source" "$target"
  if [[ "$DRY_RUN" == true ]]; then
    log "Planned link: $target -> $source"
  else
    log "Linked: $target -> $source"
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        DRY_RUN=true
        ;;
      --force)
        FORCE=true
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        log "Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"
  detect_os

  log "Dotfiles directory: $DOTFILES_DIR"
  ensure_backup_dir

  # Git
  link_file "$DOTFILES_DIR/git/config" "$HOME/.gitconfig"
  link_file "$DOTFILES_DIR/git/ignore" "$HOME/.gitignore_global"

  # Bash
  link_file "$DOTFILES_DIR/bash/bashrc" "$HOME/.bashrc"
  link_file "$DOTFILES_DIR/bash/profile" "$HOME/.profile"

  # Zsh
  link_file "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/zsh/zprofile" "$HOME/.zprofile"

  # Shell tools
  link_file "$DOTFILES_DIR/shell/bash_aliases" "$HOME/.bash_aliases"

  # oh-my-posh
  link_file "$DOTFILES_DIR/oh-my-posh/theme.omp.json" "$HOME/.config/oh-my-posh/theme.omp.json"

  # npm
  link_file "$DOTFILES_DIR/npm/npmrc" "$HOME/.npmrc"

  # fastfetch
  link_file "$DOTFILES_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"

  # dunst (Linux notification daemon)
  if [[ "$(uname -s)" == "Linux" ]]; then
    link_file "$DOTFILES_DIR/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
  fi

  # htop
  link_file "$DOTFILES_DIR/htop/htoprc" "$HOME/.config/htop/htoprc"

  # GitHub CLI
  link_file "$DOTFILES_DIR/gh/config.yml" "$HOME/.config/gh/config.yml"

  # pgcli
  link_file "$DOTFILES_DIR/pgcli/config" "$HOME/.config/pgcli/config"

  # GTK & fonts (Linux only)
  if [[ "$(uname -s)" == "Linux" ]]; then
    link_file "$DOTFILES_DIR/gtk/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
    link_file "$DOTFILES_DIR/gtk/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
    link_file "$DOTFILES_DIR/gtk/gtkrc-2.0" "$HOME/.gtkrc-2.0"
    link_file "$DOTFILES_DIR/fontconfig/fonts.conf" "$HOME/.fonts.conf"
  fi

  if [[ "$FORCE" == false ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      log "[dry-run] Backup directory would be: $BACKUP_DIR"
    else
      log "Backups saved in: $BACKUP_DIR"
    fi
  fi

  log "Done."
}

main "$@"
