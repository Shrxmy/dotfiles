# Dotfiles

Minimal dotfiles setup with safe symlink installation for Linux and macOS.

## What this manages

- `git/config` -> `~/.gitconfig`
- `git/ignore` -> `~/.gitignore_global`
- `shell/bash_aliases` -> `~/.bash_aliases`
- `zsh/zshrc` -> `~/.zshrc`
- `zsh/zprofile` -> `~/.zprofile`
- `oh-my-posh/theme.omp.json` -> `~/.config/oh-my-posh/theme.omp.json`
- `npm/npmrc` -> `~/.npmrc`
- `alacritty/alacritty.toml` -> `~/.config/alacritty/alacritty.toml`
- `konsole/Solyvie.profile` -> `~/.local/share/konsole/Solyvie.profile` (Linux)
- `konsole/Solyvie-Alacritty.colorscheme` -> `~/.local/share/konsole/Solyvie-Alacritty.colorscheme` (Linux)

## Included now

- oh-my-posh: local theme file (no remote theme dependency)
- opencode: PATH integration in `shell/bash_aliases`
- npm: basic npm config from your current setup

## Quick start

From this directory, run:

```bash
chmod +x install.sh
./install.sh
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

## Add more dotfiles

1. Add a file/folder in this repository.
2. Add a `link_file "source" "target"` line in `install.sh`.
3. Run `./install.sh --dry-run` and then `./install.sh`.
