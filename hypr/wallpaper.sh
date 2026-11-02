#!/usr/bin/env bash
# Wallpaper picker for Hyprland.
#   wallpaper.sh          pick from ~/Pictures/Wallpapers with Fuzzel
#   wallpaper.sh restore  re-apply the saved wallpaper (run at login)
set -euo pipefail

dir="$HOME/Pictures/Wallpapers"
current="${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper/current" # symlink; hyprlock reads it too
default="$dir/Space Wide.jpg"

apply() {
  pkill -x swaybg || true
  setsid -f swaybg -m fill -i "$1" >/dev/null 2>&1
}

save() {
  mkdir -p "$(dirname "$current")"
  ln -sfn "$1" "$current"
}

if [ "${1:-}" = restore ]; then
  img=$(readlink -f "$current" 2>/dev/null || true)
  [ -f "$img" ] || { img=$default; save "$img"; }
  apply "$img"
  exit 0
fi

choice=$(find "$dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%f\n' \
  | sort | fuzzel --dmenu --prompt 'wallpaper ❯ ') || exit 0
[ -n "$choice" ] && [ -f "$dir/$choice" ] || exit 0
save "$dir/$choice"
apply "$dir/$choice"
