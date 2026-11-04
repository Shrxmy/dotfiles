# dotfiles

my setup for debian (also works on mac, or "darwin" as it likes to call itself). this repo is the functional part: it works on its own with plain looks. the ricing (bar, wallpaper, colors, the warm **retro clean** palette) lives in [u-da-real-ricing](https://github.com/Shrxmy/u-da-real-ricing).

## what's in here

- **hyprland**: keybinds, touchpad, autostart and window rules, plus a cheat sheet (`super + /`) for when i forget my own keybinds. it loads the ricing repo's `look.lua` if it's there
- **shell**: zsh, autosuggestions, `ls` with icons (eza), micromamba
- **terminal**: alacritty / konsole
- **pi**: my pi agent settings, prompts and themes
- plus git, npm, gtk, htop, gh and pgcli configs

## install

```bash
./install.sh --dry-run   # see what it'll do first
./bootstrap.sh           # dotfiles + zsh plugins
```

anything already there gets backed up to `~/.dotfiles-backups/` instead of overwritten (unless you pass `--force`).

packages i actually use are in `packages/apt-curated.txt`, so run `./scripts/install-packages-apt-curated.sh` for those. the hyprland stuff comes from trixie-backports.

## adding stuff

drop the file in here, add a `link_file` line to `install.sh`, run it.
