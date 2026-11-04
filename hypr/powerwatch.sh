#!/usr/bin/env bash
# On charger plug/unplug: reload Hyprland (hyprland.lua picks 60/144 Hz, the
# optional look.lua blur/animations) and set brightness 50% on AC / 30% on battery.
# Sleeps inside udevadm until the kernel reports a power_supply event: no polling.
# Started once by hyprland.lua's autostart.
set -u

ac_state() {
  local f
  for f in /sys/class/power_supply/{ACAD,AC,ADP1,AC0}/online; do
    [ -r "$f" ] && { cat "$f"; return; }
  done
  echo 1
}

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/powerwatch.lock"
flock -n 9 || exit 0 # already running (e.g. Hyprland restarted without logging out)

last=$(ac_state)
udevadm monitor --udev --subsystem-match=power_supply 2>/dev/null | while read -r _; do
  now=$(ac_state)
  [ "$now" = "$last" ] && continue # battery level updates also arrive here
  last=$now
  hyprctl reload >/dev/null 2>&1
  # only on the transition, so a level set by hand in between sticks
  if [ "$now" = 1 ]; then brightnessctl -q set 50%; else brightnessctl -q set 30%; fi
  # optional looks hook (u-da-real-ricing: keyboard light), given "ac" or "battery"
  hook="$HOME/.config/hypr/power-hook.sh"
  [ -x "$hook" ] && { "$hook" "$([ "$now" = 1 ] && echo ac || echo battery)" >/dev/null 2>&1 || true; }
done
