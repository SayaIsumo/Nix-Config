-- Hyprland config (Lua, Hyprland >= 0.57)
-- See https://wiki.hypr.land/configuring/

-- Catppuccin Mocha palette (~/.config/hypr/mocha.lua)
local mocha = require("mocha")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/configuring/core/monitors/
hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@144",
    position = "0x0",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local browser     = "chromium"
local fileManager = "thunar"
local menu        = "rofi -show drun -theme mocha-grid"
local scripts     = "~/.config/hypr/scripts"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/configuring/core/autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("waybar")
    -- kept for the pairing agent; its tray icon is turned off via dconf in default.nix.
    -- no nm-applet: waybar's network/bluetooth modules cover what the tray icons showed
    hl.exec_cmd("blueman-applet")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/configuring/core/environment-variables/
hl.env("XCURSOR_THEME", "catppuccin-mocha-lavender-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- See https://wiki.hypr.land/configuring/core/config-options/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 15,

        border_size = 2,
        -- col = {
        --     active_border   = { colors = { mocha.blue, mocha.green }, angle = 45 },
        --     inactive_border = mocha.surface1,
        -- },

        layout = "dwindle",
    },

    decoration = {
        rounding = 10,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled = true,
            size    = 3,
            passes  = 1,
        },
    },

    animations = {
        enabled = true,
    },

    -- See https://wiki.hypr.land/configuring/layouts/dwindle-layout/
    dwindle = {
        preserve_split = true,
    },
})

-- See https://wiki.hypr.land/configuring/core/animations/
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "de",
        kb_variant = "nodeadkeys",

        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            clickfinger_behavior = true,
        },
    },
})

-- Three-finger horizontal swipe switches workspaces
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- See https://wiki.hypr.land/configuring/core/binds/
local function bind(keys, dispatcher, opts)
    hl.bind(mainMod .. (keys ~= "" and " + " .. keys or ""), dispatcher, opts)
end

-- hyprshot saves here and copies to the clipboard
local screenshot = "hyprshot -o ~/Pictures/Screenshots"

bind("RETURN",         hl.dsp.exec_cmd(terminal))
bind("SHIFT + RETURN", hl.dsp.exec_cmd(terminal .. " --class=floatterm"))
bind("B",              hl.dsp.exec_cmd(browser))
bind("SHIFT + B",      hl.dsp.exec_cmd(browser .. " --incognito"))
bind("Q",              hl.dsp.window.close())
bind("M",              hl.dsp.exit())
bind("E",              hl.dsp.exec_cmd(fileManager))
bind("V",              hl.dsp.window.float({ action = "toggle" }))
bind("D",              hl.dsp.exec_cmd(menu))
-- calculator (rofi-calc): Enter copies the result
bind("C",              hl.dsp.exec_cmd([[rofi -show calc -modi calc -no-show-match -no-sort -calc-command "echo -n '{result}' | wl-copy"]]))
bind("P",              hl.dsp.exec_cmd(screenshot .. " -m output -m active")) -- focused monitor
bind("SHIFT + P",      hl.dsp.exec_cmd(screenshot .. " -m region"))
bind("CTRL + P",       hl.dsp.exec_cmd(screenshot .. " -m window")) -- click a window
bind("ALT + P",        hl.dsp.exec_cmd("hyprshot -m region --raw | satty -f - --copy-command wl-copy --early-exit -o '~/Pictures/Screenshots/%s_satty.png'"))
bind("J",              hl.dsp.layout("togglesplit")) -- dwindle only
bind("F",              hl.dsp.window.fullscreen())
bind("L",              hl.dsp.exec_cmd("hyprlock"))
bind("SHIFT + L",      hl.dsp.exec_cmd("wlogout"))
bind("N",              hl.dsp.exec_cmd("blueman-manager"))

-- Move focus with mainMod + arrow keys
bind("left",  hl.dsp.focus({ direction = "left" }))
bind("right", hl.dsp.focus({ direction = "right" }))
bind("up",    hl.dsp.focus({ direction = "up" }))
bind("down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- workspace 10 is on key 0
    bind(tostring(key),              hl.dsp.focus({ workspace = i }))
    bind("SHIFT + " .. tostring(key), hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
bind("mouse:272", hl.dsp.window.drag(),   { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Audio
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("bash " .. scripts .. "/volume.sh mute"),               { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),        { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("bash " .. scripts .. "/volume.sh up"),                 { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("bash " .. scripts .. "/volume.sh down"),               { locked = true, repeating = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("bash " .. scripts .. "/brightness.sh up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("bash " .. scripts .. "/brightness.sh down"), { locked = true, repeating = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/configuring/core/rules/
hl.window_rule({
    name  = "float-floatterm",
    match = { class = "^(floatterm)$" },
    float = true,
})

hl.window_rule({
    name  = "float-satty",
    match = { class = "^(com.gabm.satty)$" },
    float = true,
})
