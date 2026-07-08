#!/usr/bin/env bash
set -euo pipefail

# Install zsh plugins: fzf, autosuggestions, history-substring-search

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSH_DIR="$HOME/.zsh"

log() {
  printf '%s\n' "$*"
}

mkdir -p "$ZSH_DIR"

# fzf
if [ ! -d "$HOME/.fzf" ]; then
  log "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-fish
else
  log "fzf already installed, updating..."
  (cd "$HOME/.fzf" && git pull --quiet)
fi

# zsh-autosuggestions
if [ ! -d "$ZSH_DIR/zsh-autosuggestions" ]; then
  log "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_DIR/zsh-autosuggestions"
else
  log "zsh-autosuggestions already installed, updating..."
  (cd "$ZSH_DIR/zsh-autosuggestions" && git pull --quiet)
fi

# zsh-history-substring-search
if [ ! -d "$ZSH_DIR/zsh-history-substring-search" ]; then
  log "Installing zsh-history-substring-search..."
  git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_DIR/zsh-history-substring-search"
else
  log "zsh-history-substring-search already installed, updating..."
  (cd "$ZSH_DIR/zsh-history-substring-search" && git pull --quiet)
fi

log "Done! Restart your shell or run: source ~/.zshrc"
