-- ─── autostart ───
-- waybar hyprsunset swaync mpv playerctl
hl.on("hyprland.start", function()
    -- helper
    local function exec(cmd)
        hl.exec_cmd(cmd)
    end
    -- -------------------- exec --------------------
    exec("waybar")
    exec("hyprsunset -t 3000")
    exec("swaync")
    exec("hypridle")
    exec("spotify")
    --
    exec("kitty opencode --continue")
    exec("bash ~/.config/hypr/scripts/clipboard.sh daemon")
    exec("bash ~/.config/hypr/scripts/wallpaper.sh daemon")
    exec("bash ~/.config/hypr/scripts/utils.sh workspace")
    exec("fish -c mp3")

    -- ----- xdg desktop portal -----

    -- ----- spotify-mpv -----
    hl.timer(function()
        local status = io.popen("playerctl -p spotify status 2>/dev/null"):read("*l")
        if status == "Playing" then
            exec("pkill -x mpv")
        end
    end, { timeout = 2000, type = "repeat" })

    -- ----- spotify -----
    hl.timer(function()
        local status = io.popen("playerctl -p spotify status 2>/dev/null"):read("*l")
        if status == "Paused" then
            exec("playerctl -p spotify play")
        end
    end, { timeout = 1000, type = "repeat" })
end)

-- ----- single instance apps -----
local function limit_instance(class)
    local count = tonumber(io.popen("pgrep -x " .. class .. " 2>/dev/null | wc -l"):read("*a")) or 0
    if count > 1 then
        hl.exec_cmd("pkill -x -o " .. class)
    end
end

-- ----- mpv -----
hl.on("window.open", function(w)
    if w.class == "mpv" then
        limit_instance("mpv")
    end
end)

-- ----- zathura -----
hl.on("window.open", function(w)
    if w.class == "org.pwmt.zathura" then
        limit_instance("zathura")
    end
end)

-- ----- shutdown cleanup -----
hl.on("hyprland.shutdown", function()
    local function exec(cmd)
        hl.exec_cmd(cmd)
    end
    exec("pkill -x kitty")
    exec("pkill -x zen")
    exec("pkill -x brave-origin")
    exec("pkill -x hypridle")
    exec("pkill -x hyprpaper")
    exec("pkill -x swaync")
    exec("pkill -x waybar")
end)
