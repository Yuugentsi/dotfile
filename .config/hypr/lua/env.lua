-- ─── env ───
local env_vars = {
    -- cursor
    XCURSOR_THEME                       = "Vanilla-DMZ",
    XCURSOR_SIZE                        = "12",
    HYPRCURSOR_SIZE                     = "1",

    -- session
    XDG_CURRENT_DESKTOP                 = "Hyprland",
    XDG_SESSION_TYPE                    = "wayland",
    XDG_SESSION_DESKTOP                 = "Hyprland",

    -- toolkit
    GDK_BACKEND                         = "wayland,x11,*",
    QT_QPA_PLATFORM                     = "wayland;xcb",
    QT_AUTO_SCREEN_SCALE_FACTOR         = "1",
    QT_QPA_PLATFORMTHEME                = "qt6ct",
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",

    -- browser
    MOZ_ENABLE_WAYLAND                  = "1",

    -- SDL / Electron
    SDL_VIDEODRIVER                     = "wayland,x11",
    ELECTRON_OZONE_PLATFORM_HINT        = "auto",
}

for k, v in pairs(env_vars) do
    hl.env(k, v)
end

-- ─── theme ───
local themes = {
    -- xcursor-vanilla-dmz | adapta-gtk-theme | obsidian-icon-theme
    ["org.gnome.desktop.interface gtk-theme"]  = "Adapta-Nokto",
    ["org.gnome.desktop.interface icon-theme"] = "Obsidian-Purple",
}

for key, val in pairs(themes) do
    hl.exec_cmd("GSETTINGS_BACKEND=dconf gsettings set " .. key .. " '" .. val .. "'")
end
