# dotfiles

my setup for debian (also works on mac, or "darwin" as it likes to call itself). everything's themed in a warm retro palette i call **retro clean**.

## what's in here

- **hyprland**: flat, sharp tiling setup with waybar, fuzzel, hyprlock, a wallpaper picker (`super + w`) and a cheat sheet (`super + /`) for when i forget my own keybinds
- **shell**: zsh + oh-my-posh, autosuggestions, `ls` with colored icons (eza), micromamba
- **terminal**: alacritty / konsole, fastfetch with a pixel kirby
- **pi**: my pi agent settings, prompts and themes
- plus git, npm, dunst, gtk, htop, gh and pgcli configs

## install

```bash
./install.sh --dry-run   # see what it'll do first
./bootstrap.sh           # dotfiles + zsh plugins
```

anything already there gets backed up to `~/.dotfiles-backups/` instead of overwritten (unless you pass `--force`).

packages i actually use are in `packages/apt-curated.txt`, so run `./scripts/install-packages-apt-curated.sh` for those. the hyprland stuff comes from trixie-backports.

## adding stuff

drop the file in here, add a `link_file` line to `install.sh`, run it.

## credits

the little cat in the bar uses the font from [waycat](https://github.com/CarloCattano/waycat). it's downloaded on install, not included here.
