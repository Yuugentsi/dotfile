-- scrobbler.lua
local mp = require 'mp'
local SCROBBLE_INTERVAL = 30
local SCROBBLE_SCRIPT = os.getenv("HOME") .. "/.cache/mpv/lastfm/scrobble.py"
local BLOCKED_EXTENSIONS = {
    mp4 = true,
    mkv = true,
    webm = true,
    avi = true,
    mov = true,
    flv = true,
    wmv = true,
    m4v = true,
    ts = true,
    mpeg = true,
    mpg = true,
}

local scrobble_timer = nil
local last_scrobbled = nil

local function trim(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function split_icy_title(icy_title)
    if not icy_title or icy_title == "" then
        return nil, nil
    end

    local artist, title = icy_title:match("^(.-)%s+%-%s+(.+)$")
    if artist and title then
        artist = trim(artist)
        title = trim(title)
        if artist ~= "" and title ~= "" then
            return artist, title
        end
    end

    return nil, trim(icy_title)
end

local function should_scrobble()
    local path = mp.get_property("path") or ""
    if path:match("^https?://") then
        return true
    end

    local ext = path:match("%.([%w]+)$")
    if not ext then
        return true
    end

    ext = ext:lower()
    return not BLOCKED_EXTENSIONS[ext]
end

local function get_track_info()
    local artist = mp.get_property("metadata/by-key/artist")
        or mp.get_property("metadata/by-key/Album_Artist")
    local title = mp.get_property("metadata/by-key/title")
    local album = mp.get_property("metadata/by-key/album")
    local icy_title = mp.get_property("metadata/by-key/icy-title")

    if (not artist or artist == "") and icy_title and icy_title ~= "" then
        local icy_artist, icy_track = split_icy_title(icy_title)
        artist = icy_artist or artist
        title = icy_track or title
    end

    if not title or title == "" then
        title = mp.get_property("filename/no-ext")
    end

    if artist then artist = trim(artist) end
    if title then title = trim(title) end
    if album then album = trim(album) end

    return artist, title, album
end

local function send_now_playing()
    if not should_scrobble() then return end
    local artist, title, album = get_track_info()

    if not artist or artist == "" then return end
    if not title or title == "" then return end

    local args = {os.getenv("HOME") .. "/.venv/bin/python3", SCROBBLE_SCRIPT, "--artist", artist, "--title", title, "--mode", "nowplaying"}
    if album and album ~= "" then
        table.insert(args, "--album")
        table.insert(args, album)
    end

    mp.command_native_async({name = "subprocess", args = args, detach = true}, function() end)
end

local function do_scrobble()
    if not should_scrobble() then return end
    local artist, title, album = get_track_info()

    if not artist or artist == "" then return end
    if not title or title == "" then return end

    local track_id = artist .. " - " .. title
    if track_id == last_scrobbled then return end

    local args = {os.getenv("HOME") .. "/.venv/bin/python3", SCROBBLE_SCRIPT, "--artist", artist, "--title", title}
    if album and album ~= "" then
        table.insert(args, "--album")
        table.insert(args, album)
    end

    mp.command_native_async({name = "subprocess", args = args, detach = true}, function(success)
        if success then last_scrobbled = track_id end
    end)
end

local function start_timer()
    if scrobble_timer then scrobble_timer:kill() end
    last_scrobbled = nil
    scrobble_timer = mp.add_periodic_timer(SCROBBLE_INTERVAL, do_scrobble)
end

local function stop_timer()
    if scrobble_timer then scrobble_timer:kill() end
end

mp.register_event("file-loaded", function()
    mp.add_timeout(1, send_now_playing)
    mp.add_timeout(2, start_timer)
end)

mp.register_event("end-file", stop_timer)
mp.register_event("shutdown", stop_timer)

mp.msg.info("Scrobbler: script loaded")
