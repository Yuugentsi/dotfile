-- ─── input ───
-- gestures
-- hl.gesture({ fingers = 2, direction = "pinch", action = "cursorZoom", zoom_level = "1", mode = "live" })
hl.gesture({ fingers = 3, direction = "swipe", action = "scroll_move" })
hl.gesture({
    fingers   = 4,
    direction = "horizontal",
    action    = "workspace",
})

-- keyboard / mouse / touchpad
local input_cfg = {
    kb_layout    = "br",
    kb_variant   = "",
    kb_model     = "",
    kb_options   = "",
    kb_rules     = "",
    follow_mouse = 1,
    sensitivity  = 0.70,
    touchpad     = {
        natural_scroll = false,
    },
}

hl.config({ input = input_cfg })

-- device override
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = 1,
})
