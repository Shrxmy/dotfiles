-- Hyprland (Lua config, 0.55+) — Retro Clean, flat & sharp
-- amber #cc9166  sand #d9ac8c  text #c6c0b9  muted #8a8a8a  subtle #4d4d4d
-- mauve #b894af  sage #778c73  rose #a97070  slate #8a99a8  base #25222a

---- MONITORS ----
hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "0x0", scale = "1" })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" }) -- external displays

---- PROGRAMS ----
local terminal    = "alacritty"
local fileManager = "dolphin"
local browser     = "brave-origin-stable --password-store=kwallet6" -- same key store as Plasma
local menu        = "fuzzel"

---- AUTOSTART ----
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/share/libpam-kwallet-common/pam_kwallet_init") -- unlock KWallet with the login password (SDDM PAM)
    hl.exec_cmd("waybar")
    hl.exec_cmd("~/.config/hypr/wallpaper.sh restore")
    hl.exec_cmd("dunst")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
end)

---- ENVIRONMENT ----
hl.env("XCURSOR_THEME", "breeze_cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "kde")

---- LOOK AND FEEL ----
hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,
        border_size = 2,
        col = {
            active_border   = "rgb(cc9166)",
            inactive_border = "rgb(3d3d40)",
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 0,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        dim_inactive = true,   -- unfocused windows sit back a little
        dim_strength = 0.12,
        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 10,
            color        = 0xee141216,
        },
        blur = {
            enabled  = true,
            size     = 6,
            passes   = 2,
            vibrancy = 0.17,
        },
    },
    animations = { enabled = true },
})

hl.curve("smooth",    { type = "bezier", points = { {0.22, 1},   {0.1, 1.1} } })
hl.curve("quick",     { type = "bezier", points = { {0.15, 0.85}, {0.25, 1.0} } })
hl.curve("linearish", { type = "bezier", points = { {0.3, 0.0},  {0.7, 1.0} } })

hl.animation({ leaf = "windows",          enabled = true, speed = 4, bezier = "smooth",    style = "popin 95%" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 4, bezier = "smooth",    style = "popin 85%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 3, bezier = "quick",     style = "popin 90%" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 3, bezier = "quick" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 5, bezier = "smooth",    style = "slidefade 20%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "smooth",    style = "slidefadevert 5%" })
hl.animation({ leaf = "layers",           enabled = true, speed = 3, bezier = "quick",     style = "fade" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 3, bezier = "quick",     style = "popin 95%" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 3, bezier = "quick",     style = "popin 95%" })
hl.animation({ leaf = "fadeLayersIn",     enabled = true, speed = 3, bezier = "linearish" })
hl.animation({ leaf = "fadeLayersOut",    enabled = true, speed = 3, bezier = "linearish" })
hl.animation({ leaf = "fade",             enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "border",           enabled = true, speed = 5, bezier = "quick" })

hl.config({ dwindle = { preserve_split = true } })

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        background_color = 0xff25222a,
    },
})

---- INPUT ----
hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            disable_while_typing = true,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

---- KEYBINDINGS ----
local mod = "SUPER"

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + L",      hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + W",      hl.dsp.exec_cmd("~/.config/hypr/wallpaper.sh"))
hl.bind(mod .. " + slash",  hl.dsp.exec_cmd("fuzzel --dmenu --width 82 --lines 24 --prompt 'cheat sheet ❯ ' < ~/.config/hypr/cheatsheet.txt"))
hl.bind(mod .. " + Q",      hl.dsp.window.close())
hl.bind(mod .. " + F",      hl.dsp.window.fullscreen())
hl.bind(mod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P",      hl.dsp.window.pseudo())
hl.bind(mod .. " + J",      hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())

for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mod .. " + " .. dir,             hl.dsp.focus({ direction = dir }))
    hl.bind(mod .. " + SHIFT + " .. dir,     hl.dsp.window.move({ direction = dir }))
end

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- scratchpad
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- screenshots: Print = region, Shift+Print = full screen (saved + copied)
local shot = 'f="$HOME/Pictures/Screenshots/$(date +%F_%H-%M-%S).png"; '
hl.bind("Print",         hl.dsp.exec_cmd(shot .. 'grim -g "$(slurp)" "$f" && wl-copy < "$f"'))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(shot .. 'grim "$f" && wl-copy < "$f"'))

-- media / hardware keys
local held = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      held)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  held)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  held)
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

---- WINDOW RULES ----
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})
hl.window_rule({
    name  = "float-utility-apps",
    match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|nm-connection-editor|blueman-manager)$" },
    float = true,
})
hl.window_rule({
    name  = "terminal-glass", -- let the blurred wallpaper show through terminals
    match = { class = "^(Alacritty|org.kde.konsole)$" },
    opacity = "0.88 0.80",
})
