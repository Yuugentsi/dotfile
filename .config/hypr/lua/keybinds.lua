-- ─── keybinds ───
local mainMod = "SUPER"

-- ─── programs ───
local terminal    = "kitty"
local fileManager = "thunar"
--local browser     = "zen-browser"
local browser     = "brave-origin"
local menu        = "rofi -show drun -show-icons"

-- apps
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))

-- hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(fileManager, { float = true }))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("bash -c 'pkill -x zed-editor 2>/dev/null; zeditor'"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))
--hl.bind("ALT + F", hl.dsp.exec_cmd(browser .. " -private-window"))
hl.bind("ALT + F", hl.dsp.exec_cmd(browser .. " --incognito"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(menu))

-- ─── keybinds ───
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind("ALT + C", hl.dsp.window.kill())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
-- hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind("F11", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + B", hl.dsp.window.center())
-- hl.bind(mainMod .. " + SHIFT + I", hl.dsp.window.pin())

-- groups
hl.bind("ALT + down", hl.dsp.window.close())
hl.bind("ALT + up", hl.dsp.group.toggle())

-- system
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock --config $HOME/.config/hypr/conf/hyprlock.conf"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
-- hl.bind("ALT + W", hl.dsp.exec_cmd("pkill -x waybar || waybar"))
hl.bind("ALT + W", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/utils.sh mpv"))
hl.bind("ALT + Q", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/utils.sh kitty"))
hl.bind("ALT + T", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/utils.sh toggle"))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/tr.sh"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -C && hyprctl notify -1 2000 0 '🔔 Notifications cleared'"))

-- screenshots
local shot_region = "hyprshot -m region -z -t 500 -o $HOME/0/pictures/screenshots -f $(date +'%H-%M-%S_%m-%d-%Y').png"
local shot_output = "hyprshot -m output -m active -z -t 500 -o $HOME/0/pictures/screenshots -f $(date +'%H-%M-%S_%m-%d-%Y').png"

hl.bind("F4",     hl.dsp.exec_cmd(shot_region))
hl.bind("ALT + F4", hl.dsp.exec_cmd(shot_output))

-- float small
hl.bind("F10", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.resize({ x = 900, y = 600 }))
    hl.dispatch(hl.dsp.window.center())
end)

-- audio
local vol_mute = "bash -c 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; state=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo \"󰖁\" || echo \"\"); hyprctl dismissnotify 1; hyprctl notify -1 2000 \"rgb(ff3333)\" \"fontsize:18 $state\"'"
local vol_down = "bash -c 'v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk \"{print int(\\$2*100)}\"); [ $v -le 15 ] && v=15 || v=$((v-5)); wpctl set-volume @DEFAULT_AUDIO_SINK@ ${v}%; hyprctl dismissnotify 1; hyprctl notify -1 2000 \"rgb(ffaa00)\" \"fontsize:18  ${v}%\"'"
local vol_up   = "bash -c 'v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk \"{print int(\\$2*100)}\"); v=$((v+5)); [ $v -gt 100 ] && v=100; wpctl set-volume @DEFAULT_AUDIO_SINK@ ${v}%; hyprctl dismissnotify 1; hyprctl notify -1 2000 \"rgb(33ff33)\" \"fontsize:18 󰕾 ${v}%\"'"

hl.bind("F6", hl.dsp.exec_cmd(vol_mute), { repeating = true })
hl.bind("F7", hl.dsp.exec_cmd(vol_down), { repeating = true })
hl.bind("F8", hl.dsp.exec_cmd(vol_up),   { repeating = true })
hl.bind("XF86AudioMute",    hl.dsp.exec_cmd(vol_mute),                          { repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })

-- brightness
local brightness_down = "bash -c 'v=$(brightnessctl get); max=$(brightnessctl max); current=$((v * 100 / max)); [ $current -le 30 ] && current=30 || current=$((current-5)); brightnessctl set ${current}%; hyprctl dismissnotify 1; [ $current -le 30 ] && icon=\"󰃞\" || { [ $current -le 70 ] && icon=\"󰃟\" || icon=\"󰃠\"; }; hyprctl notify -1 2000 0 \"fontsize:18 $icon ${current}%\"'"
local brightness_up   = "bash -c 'v=$(brightnessctl get); max=$(brightnessctl max); current=$((v * 100 / max)); [ $current -ge 90 ] && current=90 || current=$((current+5)); brightnessctl set ${current}%; hyprctl dismissnotify 1; [ $current -le 30 ] && icon=\"󰃞\" || { [ $current -le 70 ] && icon=\"󰃟\" || icon=\"󰃠\"; }; hyprctl notify -1 2000 0 \"fontsize:18 $icon ${current}%\"'"

hl.bind("F2", hl.dsp.exec_cmd(brightness_down), { repeating = true })
hl.bind("F3", hl.dsp.exec_cmd(brightness_up),   { repeating = true })

-- hyprsunset
local sunset_down = "bash -c 'pgrep -x hyprsunset >/dev/null || hyprsunset & v=$(hyprctl hyprsunset temperature); v=$((v-300)); [ $v -lt 1200 ] && v=1200; hyprctl hyprsunset temperature $v; hyprctl dismissnotify 1; [ $v -le 2000 ] && icon=\"󰃛\" || icon=\"󰃜\"; hyprctl notify -1 2000 0 \"fontsize:18 $icon ${v}K\"'"
local sunset_up   = "bash -c 'pgrep -x hyprsunset >/dev/null || hyprsunset & v=$(hyprctl hyprsunset temperature); v=$((v+300)); [ $v -gt 2700 ] && v=2700; hyprctl hyprsunset temperature $v; hyprctl dismissnotify 1; [ $v -le 2000 ] && icon=\"󰃛\" || icon=\"󰃜\"; hyprctl notify -1 2000 0 \"fontsize:18 $icon ${v}K\"'"

hl.bind("ALT + F2", hl.dsp.exec_cmd(sunset_down), { repeating = true })
hl.bind("ALT + F3", hl.dsp.exec_cmd(sunset_up),   { repeating = true })

-- toggle
local sunset_toggle = "bash -c 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.7; brightnessctl set 60%; hyprctl dismissnotify 1; hyprctl notify -1 2000 0 \"fontsize:18 󰕾 70% 󰃟 60%\"; if pgrep -x hyprsunset >/dev/null; then pkill -x hyprsunset; else hyprsunset & sleep 0.2; hyprctl hyprsunset temperature 1600; fi; hyprctl dismissnotify 1; hyprctl notify -1 2000 0 \"fontsize:18 󰃛 1600K\"'"
hl.bind("F9", hl.dsp.exec_cmd(sunset_toggle))

-- playerctl
hl.bind("ALT + K", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("ALT + J", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("ALT + H", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind("insert", hl.dsp.exec_cmd("bash -c 'url=$(playerctl metadata --format \"{{xesam:url}}\" 2>/dev/null); if [ -n \"$url\" ]; then title=$(playerctl metadata --format \"{{title}}\" 2>/dev/null); printf \"%s\" \"$url\" | wl-copy; hyprctl notify -1 3000 \"rgb(cba6f7)\" \"fontsize:18 󰖟 ${title:-link}\"; fi'"), { locked = true })
hl.bind("F1",             hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("ALT + F1", hl.dsp.exec_cmd("bash -c 'pkill -x mpv 2>/dev/null; sleep 0.1; track=$(find $HOME/0/music -type f \\( -iname \"*.mp3\" -o -iname \"*.flac\" -o -iname \"*.ogg\" -o -iname \"*.opus\" -o -iname \"*.m4a\" \\) 2>/dev/null | shuf -n1); [ -n \"$track\" ] && mpv --no-video \"$track\" >/dev/null 2>&1 &'"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/.config/hypr/scripts/websites.sh"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("~/.config/hypr/scripts/music.sh"))
hl.bind("ALT + G", hl.dsp.exec_cmd("~/.config/hypr/scripts/video.sh"))
hl.bind("ALT + E", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/utils.sh switcher"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/clipboard.sh"))
hl.bind("ALT + V", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/clipboard.sh images"))

-- focus
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- mouse
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- scrolling columns
hl.bind(mainMod .. " + left",  hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + right", hl.dsp.layout("move +col"))

hl.bind("CTRL + apostrophe", hl.dsp.focus({ workspace = "m+1" }))

-- scrolling
hl.bind(mainMod .. " + period",         hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + comma",          hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + comma",  hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + p",              hl.dsp.layout("promote"))

-- special workspace
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
