#!/bin/bash

case "${1:-}" in
    # ----- mpv (ALT + W) -----
    # bind_exec("ALT + W", "$HOME/.config/hypr/scripts/utils.sh mpv")
    mpv)
        SPECIAL="mpv"
        CLASS="mpv"

        EXISTING_SPECIAL=$(hyprctl clients -j | jq -r ".[] | select(.workspace.name == \"special:$SPECIAL\") | .address" | head -1)

        if [ -n "$EXISTING_SPECIAL" ]; then
            hyprctl dispatch "hl.dsp.workspace.toggle_special(\"$SPECIAL\")"
            exit 0
        fi

        DATA=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$CLASS\") | \"\\(.address) \\(.workspace.name)\"" | head -1)

        if [ -n "$DATA" ]; then
            ADDR="${DATA%% *}"
            hyprctl dispatch "hl.dsp.window.move({ workspace = 'special:$SPECIAL', window = 'address:${ADDR}' })"
            exit 0
        fi

        mpv --force-window --idle --fs >/dev/null 2>&1 &
        ;;

    # ----- kitty (ALT + Q) -----
    # bind_exec("ALT + Q", "$HOME/.config/hypr/scripts/utils.sh kitty")
    kitty)
        SPECIAL="kitty"
        CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.name')

        MPV_SPECIAL=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:mpv") | .address' | head -1)
        [ -n "$MPV_SPECIAL" ] && hyprctl dispatch "hl.dsp.window.move({ workspace = '${CURRENT_WS}', window = 'address:${MPV_SPECIAL}' })"

        EXISTING=$(hyprctl clients -j | jq -r '.[] | select(.class == "kitty-float") | .address' | head -1)
        if [ -n "$EXISTING" ]; then
            IN_SPECIAL=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$EXISTING\" and .workspace.name == \"special:$SPECIAL\") | .address")
            if [ -n "$IN_SPECIAL" ]; then
                hyprctl dispatch "hl.dsp.workspace.toggle_special(\"$SPECIAL\")"
            else
                hyprctl dispatch "hl.dsp.window.move({ workspace = 'special:$SPECIAL', window = 'address:${EXISTING}' })"
            fi
            exit 0
        fi
        kitty --class kitty-float &
        PID=$!
        for i in $(seq 1 20); do
            ADDR=$(hyprctl clients -j | jq -r ".[] | select(.pid == $PID) | .address" | head -1)
            [ -n "$ADDR" ] && break
            sleep 0.1
        done
        [ -n "$ADDR" ] && hyprctl dispatch "hl.dsp.window.move({ workspace = 'special:$SPECIAL', window = 'address:${ADDR}' })"
        ;;

    # ----- telegram (ALT + T) -----
    # bind_exec("ALT + T", "$HOME/.config/hypr/scripts/utils.sh toggle")
    toggle)
        CLASS="org.telegram.desktop"
        EXEC="Telegram"
        SPECIAL="telegram"

        if ! pgrep -x "$EXEC" > /dev/null 2>&1; then
            "$EXEC" &
            exit 0
        fi

        DATA=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$CLASS\") | \"\\(.address) \\(.workspace.name)\"" | head -1)

        if [ -z "$DATA" ]; then
            "$EXEC" &
            exit 0
        fi

        ADDR="${DATA%% *}"
        WS="${DATA#* }"

        if [[ "$WS" == special* ]]; then
            hyprctl dispatch "hl.dsp.workspace.toggle_special(\"$SPECIAL\")"
        else
            hyprctl dispatch "hl.dsp.window.move({ workspace = 'special:$SPECIAL', window = 'address:${ADDR}' })"
        fi
        ;;

    # ----- workspace notify -----
    # exec("bash $HOME/.config/hypr/scripts/utils.sh workspace")
    workspace)
        STATE=true
        SHOW_CLASS=true
        # rounded circled digits for a cleaner look
        ICONS=("" ➊ ➋ ➌ ➍ ➎ ➏ ➐ ➑ ➒ ➓)
        COL="#cba6f7"
        socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
            case "$line" in
                workspace\>\>*)
                    $STATE || continue
                    ws="${line#workspace>>}"
                    if [[ "$ws" =~ ^[0-9]+$ ]]; then
                        icon="${ICONS[$ws]}"
                        msg="$icon"
                    else
                        icon="󰣇"
                        msg="$icon  $ws"
                    fi
                    if [ "$SHOW_CLASS" = "true" ]; then
                        sleep 0.1
                        class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')
                        class=${class,,}
                        case "$class" in
                            org.telegram.desktop) class="telegram" ;;
                            dev.zed.zed) class="zed" ;;
                            org.pwmt.zathura|zathura) class="zathura" ;;
                            brave-browser) class="brave" ;;
                            code-oss) class="code" ;;
                            kitty|kitty-float) class="kitty" ;;
                            firefox|librewolf) class="firefox" ;;
                        esac
                        [ -n "$class" ] && msg="$msg  ·  $class"
                    fi
                    hyprctl dismissnotify 1 2>/dev/null
                    hyprctl notify 1 1800 "rgb(cba6f7)" "fontsize:16 $msg" 2>/dev/null
                    ;;
            esac
        done
        ;;

    # ----- window switcher (ALT + E) -----
    # bind_exec("ALT + E", "$HOME/.config/hypr/scripts/utils.sh switcher")
    switcher)
        CACHE_DIR="$HOME/.cache/scripts/switcher"
        mkdir -p "$CACHE_DIR"

        TMP="$CACHE_DIR/tmp"
        ROFI_IN="$CACHE_DIR/rofi"
        ICONS_CACHE="$CACHE_DIR/icons"
        HISTORY="$CACHE_DIR/history"
        MODE_FILE="$CACHE_DIR/mode"

        [ -f "$MODE_FILE" ] || printf 'lru\n' > "$MODE_FILE"
        MODE=$(cat "$MODE_FILE" | tr -d '[:space:]')
        [ -z "$MODE" ] && MODE="lru"

        trap 'rm -f "$TMP" "$ROFI_IN"' EXIT

        hyprctl clients -j > "$TMP"
        [ -s "$TMP" ] || { hyprctl notify 3 2000 "rgb(f38ba8)" "No windows open"; exit 0; }

        COUNT=$(jq 'length' "$TMP")
        [ "$COUNT" -eq 0 ] && { hyprctl notify 3 2000 "rgb(f38ba8)" "No windows"; exit 0; }

        if [ ! -s "$ICONS_CACHE" ]; then
            : > "$ICONS_CACHE"
            for base in "$HOME/.local/share/applications" "/usr/share/applications"; do
                [ -d "$base" ] || continue
                for f in "$base"/*.desktop; do
                    [ -f "$f" ] || continue
                    name=$(basename "$f" .desktop | tr '[:upper:]' '[:lower:]')
                    icon="" wmclass=""
                    in_entry=0
                    while IFS= read -r line; do
                        case "$line" in
                            "[Desktop Entry]") in_entry=1 ;;
                            "["*) in_entry=0 ;;
                        esac
                        [ "$in_entry" -eq 0 ] && continue
                        case "$line" in
                            Icon=*) icon="${line#Icon=}"; icon="${icon%$'\r'}" ;;
                            StartupWMClass=*) wmclass="${line#StartupWMClass=}"; wmclass="${wmclass%$'\r'}" ;;
                        esac
                    done < "$f"
                    [ -z "$icon" ] && continue
                    [ -n "$wmclass" ] && printf '%s\t%s\n' "${wmclass,,}" "$icon" >> "$ICONS_CACHE"
                    printf '%s\t%s\n' "$name" "$icon" >> "$ICONS_CACHE"
                done
            done
        fi

        icon_of() {
            local cls="${1,,}" h=""
            h=$(grep -Fm1 "$cls" "$ICONS_CACHE" 2>/dev/null | cut -f2)
            [ -n "$h" ] && { echo "$h"; return; }
            case "$cls" in
                kitty|kitty-float|alacritty|wezterm) echo "utilities-terminal"; return ;;
                dev.zed.Zed|dev.zed.zed) echo "text-editor"; return ;;
                org.telegram.desktop|telegram-desktop) echo "telegram"; return ;;
                zen-browser) echo "zen-browser"; return ;;
                librewolf) echo "librewolf"; return ;;
                brave-browser) echo "brave"; return ;;
                code-oss|code) echo "code-oss"; return ;;
                vscodium) echo "vscodium"; return ;;
                spotify|ncspot) echo "spotify"; return ;;
                mpv) echo "mpv"; return ;;
                vlc) echo "vlc"; return ;;
                thunar) echo "Thunar"; return ;;
                nautilus) echo "org.gnome.Nautilus"; return ;;
                dolphin) echo "dolphin"; return ;;
                discord|webcord) echo "discord"; return ;;
                obsidian) echo "obsidian"; return ;;
                zathura) echo "org.pwmt.zathura"; return ;;
                evince) echo "org.gnome.Evince"; return ;;
                gimp) echo "gimp"; return ;;
                steam) echo "steam"; return ;;
                lutris) echo "lutris"; return ;;
            esac
            while IFS=$'\t' read -r k v; do
                [[ "$cls" == *"$k"* ]] || [[ "$k" == *"$cls"* ]] && { echo "$v"; return; }
            done < "$ICONS_CACHE"
            echo "application-x-executable"
        }

        ADDR_LIST="$CACHE_DIR/addr_list"
        : > "$ADDR_LIST"
        : > "$ROFI_IN"

        WIN_MAP="$CACHE_DIR/map"
        : > "$WIN_MAP"

        while IFS=$'\t' read -r addr cls title; do
            [ -z "$addr" ] && continue
            [ ${#title} -gt 55 ] && title="${title:0:52}..."
            display="${title}  ·  ${cls}"
            icon=$(icon_of "$cls")
            printf '%s\t%s\t%s\n' "$addr" "$display" "$icon" >> "$WIN_MAP"
        done < <(jq -r '.[] | select(.address != "") | [.address, .class // "?", (.title // .class // "?")] | @tsv' "$TMP")

        [ -s "$WIN_MAP" ] || { hyprctl notify 3 2000 "rgb(f38ba8)" "No valid windows"; exit 0; }

        if [ -s "$HISTORY" ]; then
            if [ "$MODE" = "mru" ]; then
                tac "$HISTORY" | while IFS= read -r haddr; do
                    info=$(grep -Fm1 "$haddr" "$WIN_MAP" 2>/dev/null)
                    [ -z "$info" ] && continue
                    display="$(printf '%s' "$info" | cut -f2)"
                    icon="$(printf '%s' "$info" | cut -f3)"
                    printf '%s\n' "$haddr" >> "$ADDR_LIST"
                    printf '%s\0icon\x1f%s\n' "$display" "$icon" >> "$ROFI_IN"
                    grep -Fv "$haddr" "$WIN_MAP" > "$WIN_MAP.tmp" 2>/dev/null || true
                    mv "$WIN_MAP.tmp" "$WIN_MAP"
                done
            else
                while IFS=$'\t' read -r addr display icon; do
                    if ! grep -Fq "$addr" "$HISTORY"; then
                        printf '%s\n' "$addr" >> "$ADDR_LIST"
                        printf '%s\0icon\x1f%s\n' "$display" "$icon" >> "$ROFI_IN"
                    fi
                done < "$WIN_MAP"

                total=$(wc -l < "$HISTORY")
                if [ "$total" -gt 1 ]; then
                    head -n "$((total - 1))" "$HISTORY" | while IFS= read -r haddr; do
                        info=$(grep -Fm1 "$haddr" "$WIN_MAP" 2>/dev/null)
                        [ -z "$info" ] && continue
                        display="$(printf '%s' "$info" | cut -f2)"
                        icon="$(printf '%s' "$info" | cut -f3)"
                        printf '%s\n' "$haddr" >> "$ADDR_LIST"
                        printf '%s\0icon\x1f%s\n' "$display" "$icon" >> "$ROFI_IN"
                    done
                fi

                last_addr=$(tail -n 1 "$HISTORY")
                info=$(grep -Fm1 "$last_addr" "$WIN_MAP" 2>/dev/null)
                if [ -n "$info" ]; then
                    display="$(printf '%s' "$info" | cut -f2)"
                    icon="$(printf '%s' "$info" | cut -f3)"
                    printf '%s\n' "$last_addr" >> "$ADDR_LIST"
                    printf '%s\0icon\x1f%s\n' "$display" "$icon" >> "$ROFI_IN"
                fi
            fi
        else
            while IFS=$'\t' read -r addr display icon; do
                printf '%s\n' "$addr" >> "$ADDR_LIST"
                printf '%s\0icon\x1f%s\n' "$display" "$icon" >> "$ROFI_IN"
            done < "$WIN_MAP"
        fi

        rm -f "$WIN_MAP"

        [ -s "$ROFI_IN" ] || { hyprctl notify 3 2000 "rgb(f38ba8)" "No valid windows"; exit 0; }

        IDX=$(rofi -dmenu -i -no-custom -selected-row 0 -format i \
            -theme-str '* { font: "JetBrainsMono Nerd Font Medium 11"; bg: rgba(12,4,8,0.75); bg-alt: rgba(255,255,255,0.05); bg-hover: rgba(200,90,120,0.25); fg: #ffe0ec; muted: #b898a8; accent: #f8b4c8; glow: rgba(248,180,200,0.5); }' \
            -theme-str 'window { width: 54%; background-color: @bg; transparency: "real"; border: 2px; border-color: @glow; border-radius: 18px; }' \
            -theme-str 'mainbox { background-color: transparent; padding: 12px; spacing: 6px; }' \
            -theme-str 'inputbar { background-color: rgba(255,255,255,0.07); padding: 8px 12px; border: 1px; border-color: rgba(248,180,200,0.2); border-radius: 10px; children: [ entry ]; }' \
            -theme-str 'entry { background-color: transparent; text-color: @fg; placeholder-color: @muted; cursor-color: @accent; cursor-width: 2px; }' \
            -theme-str 'listview { columns: 1; lines: 10; fixed-height: false; dynamic: true; spacing: 4px; scrollbar: true; scrollbar-width: 4px; }' \
            -theme-str 'scrollbar { background-color: transparent; handle-color: @accent; handle-width: 4px; border-radius: 2px; }' \
            -theme-str 'element { background-color: @bg-alt; text-color: @fg; padding: 6px 12px; height: 36px; border: 1px; border-color: rgba(255,255,255,0.03); border-radius: 8px; }' \
            -theme-str 'element normal.normal { background-color: @bg-alt; text-color: @fg; }' \
            -theme-str 'element alternate.normal { background-color: @bg-alt; text-color: @fg; }' \
            -theme-str 'element selected.normal { background-color: @bg-hover; text-color: @accent; border: 2px; border-color: @accent; }' \
            -theme-str 'element-text { background-color: transparent; text-color: @fg; vertical-align: 0.5; highlight: bold #ffffff; }' \
            -theme-str 'element normal.normal element-text { background-color: transparent; text-color: @fg; }' \
            -theme-str 'element alternate.normal element-text { background-color: transparent; text-color: @fg; }' \
            -theme-str 'element selected.normal element-text { background-color: transparent; text-color: @accent; }' \
            -p "Windows" -show-icons < "$ROFI_IN")

        [ -z "$IDX" ] && exit 0

        ADDR=$(sed -n "$((IDX + 1))p" "$ADDR_LIST")
        [ -z "$ADDR" ] && { hyprctl notify 3 2000 "rgb(f38ba8)" "Failed to find window"; exit 0; }

        if [ "$MODE" = "mru" ]; then
            printf '%s\n' "$ADDR" > "$HISTORY.new"
            if [ -f "$HISTORY" ]; then
                grep -Fvx "$ADDR" "$HISTORY" >> "$HISTORY.new" 2>/dev/null || true
            fi
            mv "$HISTORY.new" "$HISTORY"
        else
            if [ -f "$HISTORY" ]; then
                grep -Fvx "$ADDR" "$HISTORY" > "$HISTORY.new" 2>/dev/null || true
            else
                : > "$HISTORY.new"
            fi
            printf '%s\n' "$ADDR" >> "$HISTORY.new"
            mv "$HISTORY.new" "$HISTORY"
        fi

        hyprctl dispatch "hl.dsp.focus({window = 'address:${ADDR}'})"
        hyprctl dispatch "hl.dsp.exec_cmd('hyprctl dispatch bringactivetotop')"

        win_class=$(hyprctl activewindow -j | jq -r '.class // "?"')
        hyprctl notify 5 1500 "rgb(a6e3a1)" "  $win_class"
        ;;

    *)
        echo "Usage: $0 {mpv|kitty|toggle|workspace|switcher}"
        exit 1
        ;;
esac
