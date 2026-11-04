#!/usr/bin/env bash
# Wallpaper picker for Hyprland, with accent colors taken from the wallpaper.
#   wallpaper.sh           fullscreen preview (imv): arrows browse, Enter applies, Esc/q cancels
#   wallpaper.sh set FILE  apply FILE and recolor the accents
#   wallpaper.sh restore   re-apply the saved wallpaper and accents (run at login)
set -euo pipefail

dir="$HOME/Pictures/Wallpapers"
state="${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper"
current="$state/current" # symlink; hyprlock reads it too
default="$dir/Space Wide.jpg"
here="$(dirname "$(readlink -f "$0")")"

apply() {
  pkill -x swaybg || true
  setsid -f swaybg -m fill -i "$1" >/dev/null 2>&1
}

save() {
  mkdir -p "$state"
  ln -sfn "$1" "$current"
}

# Generated files the apps read: Waybar CSS import, Fuzzel include, Hyprland border (hyprland.lua).
write_accent() { # ACCENT SAND (hex, no '#')
  mkdir -p "$state"
  echo "$1 $2" >"$state/accent"
  printf '@define-color amber #%s;\n@define-color sand #%s;\n' "$1" "$2" >"$state/accent.css"
  printf '[colors]\nprompt=%sff\ninput=%sff\nmatch=%sff\nselection-text=%sff\nselection-match=%sff\nborder=%sff\n' \
    "$1" "$2" "$1" "$2" "$1" "$1" >"$state/fuzzel.ini"
}

# Live recolor; each app may not be running, so none of this is fatal.
push_accent() { # ACCENT SAND
  hyprctl eval "hl.config({ general = { col = { active_border = \"rgb($1)\" } } })" >/dev/null 2>&1 || true
  pkill -USR2 -x waybar || true # reload style
  local cava="$HOME/.config/cava/config"
  if [ -f "$cava" ]; then
    sed -i -e "s/^gradient_color_4 = .*/gradient_color_4 = '#$1'/" \
      -e "s/^gradient_color_5 = .*/gradient_color_5 = '#$2'/" "$cava"
    pkill -USR1 -x cava || true # reload config
  fi
}

case "${1:-}" in
  set)
    img=$(readlink -f "${2:?usage: wallpaper.sh set FILE}")
    [ -f "$img" ] || exit 1
    save "$img"
    apply "$img"
    # shellcheck disable=SC2046 # two hex words
    set -- $(python3 -I "$here/accent.py" "$img")
    write_accent "$1" "$2"
    push_accent "$1" "$2"
    ;;
  restore)
    img=$(readlink -f "$current" 2>/dev/null || true)
    [ -f "$img" ] || { img=$default; save "$img"; }
    apply "$img"
    read -r accent sand 2>/dev/null <"$state/accent" || { accent=cc9166; sand=d9ac8c; }
    # always: Fuzzel won't start if its include is missing. No push_accent: at login Waybar is
    # still starting and SIGUSR2 before its handler is installed kills it; apps read the files at start.
    write_accent "$accent" "$sand"
    ;;
  "")
    mapfile -t files < <(find "$dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort)
    [ "${#files[@]}" -gt 0 ] || exit 0
    start=$(readlink -f "$current" 2>/dev/null || echo "${files[0]}")
    # Binds only for this launch; no ';' inside a bind (imv would run it as a separate command).
    exec imv-wayland -f -n "$start" \
      -c 'bind <Escape> quit' \
      -c "bind <Return> exec '$here/wallpaper.sh' set \"\$imv_current_file\" && imv-msg \"\$imv_pid\" quit" \
      "${files[@]}"
    ;;
  *)
    echo "usage: wallpaper.sh [set FILE | restore]" >&2
    exit 2
    ;;
esac
