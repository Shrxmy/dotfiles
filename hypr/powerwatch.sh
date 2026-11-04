#!/usr/bin/env bash
# Reload Hyprland when the charger is plugged in or unplugged: hyprland.lua (60/144 Hz) and the
# optional look.lua (blur, animations) read the power state each time the config loads.
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
done
