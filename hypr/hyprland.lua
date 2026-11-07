-- Hyprland (Lua config, 0.55+): functional core.
-- Looks (borders, blur, animations, wallpaper, glass) come from u-da-real-ricing's look.lua when it's installed;
-- without it this is a plain, fully working Hyprland.

---- POWER ----
-- Read once per config load; hypr/powerwatch.sh reloads Hyprland when the charger is plugged or unplugged.
local function on_ac()
    for _, name in ipairs({ "ACAD", "AC", "ADP1", "AC0" }) do
        local f = io.open("/sys/class/power_supply/" .. name .. "/online")
        if f then
            local v = f:read("l")
            f:close()
            return v == "1"
        end
    end
    return true -- no charger info: treat as plugged in
end
ON_BATTERY = not on_ac() -- global on purpose: look.lua (u-da-real-ricing) drops blur/animations on battery

---- MONITORS ----
-- 60 Hz on battery saves ~1-2 W on this panel; 144 Hz when plugged in
hl.monitor({ output = "eDP-1", mode = ON_BATTERY and "1920x1080@60" or "1920x1080@144", position = "0x0", scale = "1" })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" }) -- external displays

---- PROGRAMS ----
local terminal    = "alacritty"
local fileManager = "dolphin"
local browser     = "brave-origin-stable --password-store=kwallet6 --enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL" -- same key store as Plasma
local menu        = "fuzzel"

local look = {} -- filled below by the optional look.lua (u-da-real-ricing)

---- AUTOSTART ----
-- GPU selection from zsh/zprofile, handed to systemd user services (polkit agent, portals) so they don't load
-- NVIDIA's libraries either; cleared first so an external-screen login doesn't inherit a stale Intel-only value
local gpu_env = "AQ_DRM_DEVICES __EGL_VENDOR_LIBRARY_FILENAMES __GLX_VENDOR_LIBRARY_NAME VK_LOADER_DRIVERS_DISABLE"

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/share/libpam-kwallet-common/pam_kwallet_init") -- unlock KWallet with the login password (SDDM PAM)
    hl.exec_cmd("waybar")
    if not look.notifications then hl.exec_cmd("dunst") end -- the ricing can bring its own notification daemon
    hl.exec_cmd("hypridle")
    hl.exec_cmd("~/.config/hypr/powerwatch.sh") -- reload on charger plug/unplug
    hl.exec_cmd("systemctl --user unset-environment " .. gpu_env .. "; systemctl --user import-environment " .. gpu_env .. "; systemctl --user start hyprpolkitagent")
    hl.exec_cmd("nm-applet --indicator")
    for _, cmd in ipairs(look.autostart or {}) do hl.exec_cmd(cmd) end
end)

---- ENVIRONMENT ----
hl.env("XCURSOR_THEME", "breeze_cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "kde")

---- LOOKS (optional) ----
-- u-da-real-ricing links ~/.config/hypr/look.lua; it styles everything and returns { autostart = {...} }.
local look_path = os.getenv("HOME") .. "/.config/hypr/look.lua"
local look_file = io.open(look_path)
if look_file then
    look_file:close()
    local ok, res = pcall(dofile, look_path)
    if ok then
        look = type(res) == "table" and res or {}
    else
        -- Hyprland's own overlay: needs no notification daemon or extra package
        hl.exec_cmd("hyprctl notify 3 15000 0 " .. string.format("%q", "look.lua failed: " .. tostring(res)))
    end
end

hl.config({
    general = {
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
})

hl.config({ dwindle = { preserve_split = true } })

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        on_focus_under_fullscreen = 1, -- focusing another window makes it take over the maximized spot
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
hl.bind(mod .. " + slash",  hl.dsp.exec_cmd("fuzzel --dmenu --width 82 --lines 24 --prompt 'cheat sheet ❯ ' < ~/.config/hypr/cheatsheet.txt"))
hl.bind(mod .. " + Q",      hl.dsp.window.close())
hl.bind(mod .. " + F",      hl.dsp.window.fullscreen())
hl.bind(mod .. " + M",      hl.dsp.window.fullscreen({ mode = "maximized" }))
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

-- Alt+Tab: cycle windows and raise the chosen one
hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)
hl.bind("ALT + SHIFT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end)

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
    name  = "browser-maximized", -- fill the screen, keep bar and gaps (not true fullscreen)
    match = { class = "^(brave-origin|brave-browser)$" },
    maximize = true,
})
hl.window_rule({
    name  = "chromium-touchpad-scroll", -- Chromium/Electron apps over-scroll on touchpads; tame them to a Windows-like pace
    match = { class = "^(brave-origin|brave-browser|chromium|[Cc]ode|discord|[Ss]potify)$" },
    scroll_touchpad = 0.35,
})
