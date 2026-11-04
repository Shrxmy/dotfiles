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

## battery (lenovo loq)

`tlp/50-battery.conf` turns off turbo on battery, lets the nvidia gpu sleep, starts bluetooth off and keeps the battery at ~60% while plugged in (`sudo tlp fullcharge` for a one-off 100%). it's system-wide, so it's installed by hand:

```bash
sudo install -m 644 tlp/50-battery.conf /etc/tlp.d/ && sudo tlp start
sudo systemctl disable --now nvidia-persistenced   # keeps the gpu awake otherwise
```

unplugging also drops the screen to 60 hz (and the ricing repo turns off blur and animations). `hypr/powerwatch.sh` reloads hyprland when the charger changes.

## adding stuff

drop the file in here, add a `link_file` line to `install.sh`, run it.
