-- ─── appearance ───
hl.config({ xwayland = { force_zero_scaling = true } })

-- -------------------- general --------------------
hl.config({
    general = {
        gaps_in          = 2,
        gaps_out         = 8,

        border_size      = 2,

        col              = {
            active_border   = { colors = { "rgba(a855f7ee)", "rgba(402759ee)" }, angle = 45 },
            inactive_border = "rgba(29183add)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "scrolling",
        snap             = {
            enabled    = true,
            window_gap = 10,
        },
    },
})

-- -------------------- layouts --------------------
-- ----- master -----
hl.config({
    master = {
        new_status = "slave",
    },
})

-- ----- scrolling -----
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
        column_width = 0.97,
        focus_fit_method = 0,
        follow_focus = true,
        follow_min_visible = 0.4,
        explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
        wrap_focus = true,
        wrap_swapcol = true,
        direction = "right",
    },
})

-- -------------------- misc --------------------
hl.config({
    misc = {
        force_default_wallpaper  = -1,
        disable_hyprland_logo    = false,
        disable_splash_rendering = true,
    },
})

-- -------------------- decoration --------------------
hl.config({
    decoration = {
        rounding         = 10,
        rounding_power   = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.94,

        dim_inactive     = true,
        dim_strength     = 0.12,

        -- ----- shadow -----
        shadow           = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        -- ----- blur -----
        blur             = {
            enabled   = true,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },

        -- ----- glow -----
        glow             = {
            enabled      = false,
            range        = 10,
            render_power = 3,
            color        = 0xeea855f7,
        },
    },
})

-- -------------------- animations --------------------
-- ----- bezier -----
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- ----- spring -----
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

-- ----- entries -----
hl.animation({ leaf = "global", enabled = false, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = false, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = false, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = false, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = false, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = false, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = false, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = false, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = false, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = false, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = false, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = false, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = false, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = false, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = false, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = false, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = false, speed = 7, bezier = "quick" })
