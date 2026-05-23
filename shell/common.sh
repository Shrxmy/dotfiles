# Shared interactive shell setup for bash and zsh

path_prepend() {
  [ -n "${1:-}" ] || return 0
  [ -d "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

path_dedupe() {
  PATH="$(printf '%s' "$PATH" | awk -v RS=: '!a[$0]++ { if (NR == 1) printf "%s", $0; else printf ":%s", $0 }')"
}

# Shared aliases/helpers
if [ -f "$HOME/.bash_aliases" ]; then
  . "$HOME/.bash_aliases"
fi

# Homebrew (cross-platform)
if [ "$(uname -s)" = "Darwin" ]; then
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# opencode
path_prepend "$HOME/.opencode/bin"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
path_prepend "$PNPM_HOME/bin"

# Prefer user-local bins early
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"

# Deduplicate PATH after shared setup mutations
path_dedupe
export PATH

# Conda / Mamba (portable if installed in this location)
if [ -f "$HOME/Environment/miniforge3/etc/profile.d/conda.sh" ]; then
  . "$HOME/Environment/miniforge3/etc/profile.d/conda.sh"
fi

if [ -x "$HOME/Environment/miniforge3/bin/mamba" ]; then
  export MAMBA_EXE="$HOME/Environment/miniforge3/bin/mamba"
  export MAMBA_ROOT_PREFIX="$HOME/Environment/miniforge3"
fi

# Prompt (oh-my-posh)
if command -v oh-my-posh >/dev/null 2>&1 && [ -f "$HOME/.config/oh-my-posh/theme.omp.json" ]; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(oh-my-posh init zsh --config "$HOME/.config/oh-my-posh/theme.omp.json")"
  else
    eval "$(oh-my-posh init bash --config "$HOME/.config/oh-my-posh/theme.omp.json")"
  fi
fi

# Optional local-only overrides (not managed in git)
if [ -f "$HOME/.config/shell/local.sh" ]; then
  . "$HOME/.config/shell/local.sh"
  path_dedupe
  export PATH
fi
