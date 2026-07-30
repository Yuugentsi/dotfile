local mp = require "mp"

-- ─────────── press fast ───────────
local fast_speed = 1.6
local normal_speed = 1.0
local rewind_on_release = 0.5
local active = false

local function handle_fast(event)
    if event.event == "down" then
        if active then
            return
        end
        active = true
        mp.set_property_number("speed", fast_speed)
    elseif event.event == "up" then
        active = false
        mp.commandv("seek", -rewind_on_release, "exact")
        mp.set_property_number("speed", normal_speed)
    end
end

-- ─────────── eta ───────────
local os = require "os"

local function format_time(seconds)
    if not seconds or seconds < 0 then return "--" end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    if h > 0 then
        return string.format("%dh%02dm%02ds", h, m, s)
    else
        return string.format("%dm%02ds", m, s)
    end
end

local function basename(path)
    if not path then return "—" end
    local name = path:match("([^/\\]+)$") or path
    return name:match("(.+)%.[^%.]+$") or name
end

local function show_eta()
    local dur = mp.get_property_number("duration")
    local pos = mp.get_property_number("playback-time")
    if not dur or not pos then
        return
    end

    if pos < 0 then pos = 0 end
    local remaining = dur - pos
    if remaining < 0 then remaining = 0 end

    local now = os.time()
    local end_time = os.date("%H:%M", now + remaining)

    local bar_w = 20
    local p = math.floor((pos / dur) * (bar_w - 1))
    if p < 0 then p = 0 elseif p >= bar_w then p = bar_w - 1 end
    local bar = string.rep("·", p) .. "ᗧ" .. string.rep("·", bar_w - p - 1)

    local current = basename(mp.get_property("filename"))
    local msg = "▶ " .. current .. "\n"
        .. format_time(remaining) .. "  ⌛ " .. end_time .. "\n"
        .. bar

    mp.osd_message(msg, 2000)
    mp.add_timeout(2, function()
        mp.osd_message("", 0)
    end)
end

-- ─────────── night mode ───────────
local ENABLE_NIGHT = true

local night_on = true
local NIGHT_FILTER = "colorchannelmixer=0.85:0.15:0:0:0.15:0.85:0:0:0:0:0.45:0"

local function apply_night()
    if not ENABLE_NIGHT then return end
    mp.command("vf add @night " .. NIGHT_FILTER)
    mp.set_property_number("brightness", -8)
    night_on = true
end

local function remove_night()
    if not ENABLE_NIGHT then return end
    mp.command("vf remove @night")
    mp.set_property_number("brightness", 0)
    night_on = false
end

local function toggle_night()
    if not ENABLE_NIGHT then
        mp.osd_message("night mode disabled", 2000)
        return
    end
    if night_on then
        remove_night()
        mp.osd_message("night mode: off", 2000)
    else
        apply_night()
        mp.osd_message("night mode: on", 2000)
    end
end

-- ─────────── screenshot clipboard ───────────
local ENABLE_CLIPBOARD = true

local function screenshot_clipboard()
    if not ENABLE_CLIPBOARD then
        mp.osd_message("clipboard disabled", 2000)
        return
    end
    local tmp = "/tmp/mpv_clip.jpg"
    mp.commandv("screenshot-to-file", tmp, "video")
    mp.command_native_async({
        name = "subprocess",
        args = { "sh", "-c", "wl-copy -t image/jpeg < " .. tmp },
        playback_only = false,
        detach = true,
    }, function() end)
    mp.osd_message("📋", 300)
    mp.add_timeout(0.3, function()
        mp.osd_message("", 0)
    end)
end

-- ─────────── help ───────────

local function show_help()
    local text = table.concat({
        "SPACE pause",
        "q quit",
        "ENTER fast fwd",
        "[ ] speed",
        "m mute",
        "- = volume",
        "← → seek",
        "↑ ↓ +5s",
        "TAB skip85s",
        ". , frame",
        "i stats",
        "a d prev/next",
        "f fullscreen",
        "b sub",
        "s screenshot",
        "n night",
        "t eta",
        "Ctrl+C clipboard",
        "DEL trash",
    }, "\n")
    mp.osd_message(text, 4000)
    mp.add_timeout(4, function()
        mp.osd_message("", 0)
    end)
end
-- ─────────── bindings ───────────
mp.add_forced_key_binding("ENTER", "press-fast-enter", handle_fast, { complex = true })
mp.add_forced_key_binding("KP_ENTER", "press-fast-kp-enter", handle_fast, { complex = true })
mp.add_forced_key_binding("t", "eta-show", show_eta)
mp.add_forced_key_binding("T", "eta-show-T", show_eta)
mp.add_forced_key_binding("n", "night-toggle", toggle_night)
mp.add_forced_key_binding("Ctrl+c", "screenshot-clipboard", screenshot_clipboard)
mp.add_forced_key_binding("C", "screenshot-clipboard-C", screenshot_clipboard)
mp.add_forced_key_binding("h", "help-show", show_help)
mp.register_event("file-loaded", function()
    apply_night()
    show_eta()
end)
