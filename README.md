# Dotfiles

Minimal dotfiles setup with safe symlink installation for Linux and macOS.

## What this manages

- `git/config` -> `~/.gitconfig`
- `git/ignore` -> `~/.gitignore_global`
- `shell/bash_aliases` -> `~/.bash_aliases`
- `shell/common.sh` -> `~/.config/shell/common.sh`
- `shell/linux.sh` -> `~/.config/shell/linux.sh`
- `shell/macos.sh` -> `~/.config/shell/macos.sh`
- `zsh/zshrc` -> `~/.zshrc`
- `zsh/zprofile` -> `~/.zprofile`
- `oh-my-posh/theme.omp.json` -> `~/.config/oh-my-posh/theme.omp.json`
- `npm/npmrc` -> `~/.npmrc`
- `alacritty/alacritty.toml` -> `~/.config/alacritty/alacritty.toml`
- `konsole/Solyvie.profile` -> `~/.local/share/konsole/Solyvie.profile` (Linux)
- `konsole/Solyvie-Alacritty.colorscheme` -> `~/.local/share/konsole/Solyvie-Alacritty.colorscheme` (Linux)
- `pi/agent/settings.json` -> `~/.pi/agent/settings.json`
- `pi/agent/keybindings.json` -> `~/.pi/agent/keybindings.json`
- `pi/agent/prompts/commit.md` -> `~/.pi/agent/prompts/commit.md`
- `pi/agent/themes/*.json` -> `~/.pi/agent/themes/*.json`

## Included now

- oh-my-posh: local theme file (no remote theme dependency)
- shell: shared cross-platform shell setup with Linux/macOS split
- opencode: PATH integration in `shell/bash_aliases`
- npm: basic npm config from your current setup
- pi: settings, keybindings, custom prompts, and themes (auth/sessions are not managed)
- local overrides: optional non-git shell overrides via `~/.config/shell/local.sh`

## Zsh plugins

The bootstrap automatically installs these zsh plugins:

- [fzf](https://github.com/junegunn/fzf) - fuzzy finder (Ctrl+R for history, Ctrl+T for files)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - autosuggestions from history
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) - arrow key history search

Plugins are installed to `~/.fzf` and `~/.zsh/`. To reinstall manually:

```bash
./scripts/install-zsh-plugins.sh
```

## Quick start

From this directory, run:

```bash
chmod +x install.sh bootstrap.sh scripts/install-zsh-plugins.sh
./install.sh
```

Or use the bootstrap flow (installs dotfiles + zsh plugins):

```bash
./bootstrap.sh
```

## Safer first run

Preview all actions without changing anything:

```bash
./install.sh --dry-run
```

## Options

```bash
./install.sh --help
```

- `--dry-run`: print actions only
- `--force`: overwrite existing files instead of backing them up

## Backups

When a target file already exists, it is moved to:

`~/.dotfiles-backups/YYYYMMDD-HHMMSS/`

unless you use `--force`.

## Package manifests

This repo can export package manifests for reproducibility:

```bash
./scripts/export-packages.sh
```

Current supported exports (when available on the system):
- `packages/apt-manual.txt`
- `packages/flatpak-apps.txt`
- `packages/pnpm-global.json`
- `packages/npm-global.json`
- `packages/pipx.json`
- `packages/cargo-install-list.txt`

Restore helpers:
- `./scripts/install-packages-apt.sh`
- `./scripts/install-packages-apt-curated.sh`
- `./scripts/install-node-globals.sh`
- see `packages/README.md` for notes and source categories

## Add more dotfiles

1. Add a file/folder in this repository.
2. Add a `link_file "source" "target"` line in `install.sh`.
3. Run `./install.sh --dry-run` and then `./install.sh`.
