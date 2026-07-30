local mp = require "mp"
local assdraw = require "mp.assdraw"

local function paste_and_play(fmt)
    mp.command_native_async({
        name = "subprocess",
        args = { "sh", "-c", "timeout 2 wl-paste 2>/dev/null || echo ''" },
        playback_only = false,
        capture_stdout = true,
    }, function(_, res)
        local url = ""
        if res and res.stdout then
            url = res.stdout:gsub("^%s*(.-)%s*$", "%1")
        end
        if url == "" then
            mp.osd_message("empty", 1000)
            return
        end
        mp.set_property("ytdl-format", fmt)
        mp.commandv("loadfile", url, "replace")
    end)
end

local function paste_360() paste_and_play("best[height<=360]") end
local function paste_720() paste_and_play("best[height<=720]") end

mp.add_forced_key_binding("k", "paste-360", paste_360)
mp.add_forced_key_binding("Ctrl+k", "paste-720", paste_720)

local button = {
    x = 48, y = 48, size = 36,
    visible = false,
}

local function show()
    if button.visible then return end
    local ass = assdraw.ass_new()
    ass:draw_start()
    ass:append("{\\bord0\\shad0\\1c&H222222&\\alpha&H88&}")
    ass:rect_cw(button.x, button.y, button.x + button.size, button.y + button.size)
    ass:draw_stop()
    ass:pos(button.x + button.size / 2, button.y + button.size / 2)
    ass:append("{\\fnSymbola\\fs18\\bord0\\shad0\\1c&HFFFFFF&}")
    ass:append("\239\157\145")
    mp.set_osd_ass(0, 0, ass.text)
    button.visible = true
end

local function hide()
    if not button.visible then return end
    mp.set_osd_ass(0, 0, "")
    button.visible = false
end

mp.add_key_binding("u", "toggle-paste-button", function()
    if button.visible then hide() else show() end
end)

mp.add_key_binding("mouse_btn0", "pasteurl-click", function()
    if not button.visible then return end
    local cp = mp.get_property_native("cursor-position")
    if cp and cp.x >= button.x and cp.x <= button.x + button.size
        and cp.y >= button.y and cp.y <= button.y + button.size then
        paste_360()
    end
end)

mp.add_key_binding("mouse_btn2", "pasteurl-hide", function()
    if button.visible then hide() end
end)
