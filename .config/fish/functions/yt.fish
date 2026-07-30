# ─────────── yt ───────────
# mp3
# mp4
# yt
# ytl
# ytp
# --

#
if not set -q YT_MP3_THUMBNAIL
    set -g YT_MP3_THUMBNAIL true
end

#
if not set -q YTA_CLEAN_TITLE
    set -g YTA_CLEAN_TITLE true
end

function __yt_mp3_thumbnail_flags --description 'Return thumbnail flags if enabled'
    if not set -q YT_MP3_THUMBNAIL
        set -g YT_MP3_THUMBNAIL true
    end
    if test "$YT_MP3_THUMBNAIL" = true
        echo --embed-thumbnail
        echo --add-metadata
    end
end

function __yt_browser_cookies --description 'Detect browser cookies for yt-dlp'
    if test -d "$HOME/.config/zen"
        echo --cookies-from-browser
        echo firefox:$HOME/.config/zen/
    else if test -d "$HOME/.config/BraveSoftware/Brave-Origin"
        echo --cookies-from-browser
        echo brave:$HOME/.config/BraveSoftware/Brave-Origin
    else if test -d "$HOME/.config/BraveSoftware/Brave-Browser"
        echo --cookies-from-browser
        echo brave:$HOME/.config/BraveSoftware/Brave-Browser
    else if test -d "$HOME/.mozilla/firefox"
        echo --cookies-from-browser
        echo firefox
    else if test -d "$HOME/.var/app/org.mozilla.firefox/config/mozilla/firefox"
        echo --cookies-from-browser
        echo firefox
    else if test -d "$HOME/.config/chromium"
        echo --cookies-from-browser
        echo chromium
    else if test -d "$HOME/.config/google-chrome"
        echo --cookies-from-browser
        echo chrome
    end
end

# ─── mp3
function mp3 --description 'yt mp3'
    set -l out_dir "$HOME/0/music/yt"
    mkdir -p "$out_dir"
    set -l green (set_color green)
    set -l red (set_color red)
    set -l yellow (set_color yellow)
    set -l reset (set_color normal)

    if not command -v yt-dlp >/dev/null 2>&1
        echo -s $red "yt-dlp not found" $reset
        return 1
    end

    mkdir -p "$out_dir"

    function __mp3_notify --no-scope-shadowing
        if command -v hyprctl >/dev/null 2>&1
            hyprctl notify -1 2200 "rgb(cba6f7)" "$argv[1]" >/dev/null 2>&1
        end
    end

    function __mp3_download --no-scope-shadowing
        set -l url $argv[1]
        set -l out "$out_dir"
        set -l queue "$queue_file"

        # check if already downloaded via .yt.txt
        set -l vid (string match -rg 'v=([A-Za-z0-9_-]{11})' -- "$url")
        test -z "$vid"; and set vid (string match -rg 'youtu\.be/([A-Za-z0-9_-]{11})' -- "$url")
        if test -n "$vid"; and test -f "$out/.yt.txt"; and grep -q -- "$vid" "$out/.yt.txt" 2>/dev/null
            set -l title (grep -B1 -- "$vid" "$out/.yt.txt" 2>/dev/null | head -n 1)
            echo -s $yellow "↻ $title" $reset
            if command -v hyprctl >/dev/null 2>&1
                hyprctl notify 0 3000 "rgb(ff0000)" "↻ $title" >/dev/null 2>&1
            end
            return 0
        end

        command fish -c '
            set -l url $argv[1]
            set -l out $argv[2]
            set -l queue $argv[3]
            set -l green (set_color green)
            set -l red (set_color red)
            set -l yellow (set_color yellow)
            set -l reset (set_color normal)
            set -l before (find "$out" -maxdepth 1 -type f -name "*.mp3" -printf "%f\n")
            set -l title (yt-dlp --no-warnings --no-playlist --no-download-archive --skip-download --print "%(title)s" "$url" 2>/dev/null | head -n 1)
            test -n "$title"; or set title "mp3"

            set -l waiting 0
            if test -f "$queue"
                set waiting (string match -rv "^\s*\$" < "$queue" | count)
            end
            yt-dlp -x \
                --audio-format mp3 \
                --audio-quality 0 \
                (__yt_mp3_thumbnail_flags) \
                --no-playlist \
                --no-download-archive \
                --replace-in-metadata "uploader" " - Topic\$" "" \
                --parse-metadata "uploader:%(artist)s" \
                --parse-metadata "uploader:%(album_artist)s" \
                --replace-in-metadata "title" "(?i)\\s*[\\(\\[]?(?:feat|ft)\\.?\\s*[\\)\\]]?.*\$" "" \
                --add-metadata \
                --quiet \
                --no-warnings \
                --newline \
                --progress \
                --progress-template "%(progress._percent_str)s" \
                -o "$out/%(title)s.%(ext)s" \
                "$url" | while read -l progress
                    set -l percent (string trim -- "$progress")
                    if test -n "$percent"
                        set -l waiting 0
                        if test -f "$queue"
                            set waiting (string match -rv "^\s*\$" < "$queue" | count)
                        end
                        if test $waiting -gt 0
                            printf "\r\033[K󱎫 %s %s 󱐋 %s" "$title" "$percent" "$waiting"
                        else
                            printf "\r\033[K󱎫 %s %s" "$title" "$percent"
                        end
                    end
                end
            echo
            set -l code $status

            if test $code -ne 0
            printf "\033[1A\033[J"
                echo -s $red "󰅙" $reset
                if command -v hyprctl >/dev/null 2>&1
                    hyprctl notify -1 2200 "rgb(cba6f7)" "󰅙" >/dev/null 2>&1
                end
                exit 1
            end

            set -l after (find "$out" -maxdepth 1 -type f -name "*.mp3" -printf "%f\n")
            for f in $after
                if not contains -- "$f" $before
                    set title (string replace -r "\.mp3\$" "" -- "$f")
                    break
                end
            end

            set -l waiting 0
            if test -f "$queue"
                set waiting (string match -rv "^\s*\$" < "$queue" | count)
            end
            printf "\033[1A\033[J"
            echo -s $green "$title" $reset
            if command -v hyprctl >/dev/null 2>&1
                if test $waiting -gt 0
                    hyprctl notify 5 3000 "rgb(00ff00)" "$title | $waiting" >/dev/null 2>&1
                else
                    hyprctl notify 5 3000 "rgb(00ff00)" "$title" >/dev/null 2>&1
                end
            end
            echo "$title" >> "$out/.yt.txt"
            set -l vid (string match -rg "v=([A-Za-z0-9_-]{11})" -- "$url")
            test -z "$vid"; and set vid (string match -rg "youtu\.be/([A-Za-z0-9_-]{11})" -- "$url")
            test -n "$vid"; and set url "https://www.youtube.com/watch?v=$vid"
            echo "$url" >> "$out/.yt.txt"
            echo "----------" >> "$out/.yt.txt"
        ' "$url" "$out" "$queue"
    end

    function __mp3_queue_count --no-scope-shadowing
        set -l active 0
        if test -f "$active_file"
            set active (cat "$active_file")
        end
        set -l waiting 0
        if test -f "$queue_file"
            set waiting (string match -rv '^\s*$' < "$queue_file" | count)
        end
        math $active + $waiting
    end

    function __mp3_show_queue --no-scope-shadowing
        set -l total (__mp3_queue_count)
        echo -s $yellow "queue: $total" $reset
    end

    if test -n "$argv[1]"
        __mp3_download "$argv[1]"
        functions -e __mp3_notify
        functions -e __mp3_download
        return $status
    end

    if not command -v wl-paste >/dev/null 2>&1
        echo -s $red "wl-paste not found" $reset
        return 1
    end

    set -l worker_pid
    set -l state_dir "/tmp/mp3_queue_$fish_pid"
    set -l queue_file "$state_dir/queue"
    set -l seen_file "$state_dir/seen"
    set -l active_file "$state_dir/active"
    set -l current_clip_file "$state_dir/current"
    rm -rf "$state_dir"
    mkdir -p "$state_dir"
    touch "$queue_file" "$seen_file"
    wl-paste -n 2>/dev/null | string trim > "$current_clip_file"

    clear
    echo "󱎫"

    wl-paste --watch fish -c '
        set -l clip (cat | string trim)
        set -l queue_file $argv[1]
        set -l seen_file $argv[2]
        set -l active_file $argv[3]
        set -l current_clip_file $argv[4]

        if not string match -qr "^https?://(www\.|music\.)?(youtube\.com|youtu\.be)/" -- "$clip"
            exit 0
        end

        if test -f "$current_clip_file"
            set -l current_clip (cat "$current_clip_file")
            if test -n "$current_clip"; and test "$clip" = "$current_clip"
                rm -f "$current_clip_file"
                exit 0
            end
        end

        if grep -Fxq -- "$clip" "$seen_file" 2>/dev/null
            exit 0
        end

        echo "$clip" >> "$seen_file"
        echo "$clip" >> "$queue_file"

        set -l waiting (wc -l < "$queue_file" | string trim)
        set -l total $waiting

        if command -v hyprctl >/dev/null 2>&1
            hyprctl notify -1 2200 "rgb(cba6f7)" "󱐋 $total" >/dev/null 2>&1
        end
    ' "$queue_file" "$seen_file" "$active_file" "$current_clip_file" &
    set -l watch_pid $last_pid

    while true
        if test -n "$worker_pid"; and not kill -0 $worker_pid >/dev/null 2>&1
            wait $worker_pid >/dev/null 2>&1
            set -e worker_pid
            echo 0 > "$active_file"
        end

        if test -z "$worker_pid"; and test -s "$queue_file"
            set -l next (head -n 1 "$queue_file")
            tail -n +2 "$queue_file" > "$queue_file.tmp"
            mv "$queue_file.tmp" "$queue_file"

            if test -n "$next"
                echo 1 > "$active_file"
                __mp3_download "$next" &
                set worker_pid $last_pid
            end
        end

        sleep 0.15
    end
end

# ─── mp4
function mp4 --description 'yt mp4'
    set -l out_dir "$HOME/0/music/yt"
    mkdir -p "$out_dir"
    set -l green (set_color green)
    set -l red (set_color red)
    set -l yellow (set_color yellow)
    set -l reset (set_color normal)

    if not command -v yt-dlp >/dev/null 2>&1
        echo -s $red "yt-dlp not found" $reset
        return 1
    end

    mkdir -p "$out_dir"

    function __mp4_download --no-scope-shadowing
        set -l url $argv[1]
        set -l out "$out_dir"
        set -l queue "$queue_file"

        command fish -c '
            set -l url $argv[1]
            set -l out $argv[2]
            set -l queue $argv[3]
            set -l green (set_color green)
            set -l red (set_color red)
            set -l reset (set_color normal)
            set -l before (find "$out" -maxdepth 1 -type f -name "*.mp4" -printf "%f\n")
            set -l title (yt-dlp --no-warnings --no-playlist --no-download-archive --skip-download --print "%(title)s" "$url" 2>/dev/null | head -n 1)
            test -n "$title"; or set title "mp4"

            yt-dlp \
                -f "bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=720]+bestaudio/best[height<=720]/best" \
                --merge-output-format mp4 \
                --no-playlist \
                --no-download-archive \
                --quiet \
                --no-warnings \
                --newline \
                --progress \
                --progress-template "%(progress._percent_str)s	%(progress._downloaded_bytes_str)s	%(progress._total_bytes_str)s	%(progress._total_bytes_estimate_str)s" \
                -o "$out/%(title)s.%(ext)s" \
                "$url" 2>/dev/null | while read -l progress
                    set -l parts (string split \t -- "$progress")
                    set -l percent (string trim -- "$parts[1]")
                    if test -n "$percent"
                        set -l downloaded (string trim -- "$parts[2]")
                        set -l total (string trim -- "$parts[3]")
                        set -l estimate (string trim -- "$parts[4]")
                        set -l size "$downloaded"
                        if test -n "$total"; and test "$total" != "N/A"
                            set size "$downloaded/$total"
                        else if test -n "$estimate"; and test "$estimate" != "N/A"
                            set size "$downloaded/~$estimate"
                        end

                        set -l waiting 0
                        if test -f "$queue"
                            set waiting (string match -rv "^\s*\$" < "$queue" | count)
                        end
                        if test $waiting -gt 0
                            printf "\r\033[K󱎫 %s 󰦨 %s 󰋊 %s 󱐋 %s" "$title" "$percent" "$size" "$waiting"
                        else
                            printf "\r\033[K󱎫 %s 󰦨 %s 󰋊 %s" "$title" "$percent" "$size"
                        end
                    end
                end
            echo
            set -l code $status

            if test $code -ne 0
                printf "\033[1A\033[J"
                echo -s $red "󰅙" $reset
                if command -v hyprctl >/dev/null 2>&1
                    hyprctl notify -1 2200 "rgb(cba6f7)" "󰅙" >/dev/null 2>&1
                end
                exit 1
            end

            set -l after (find "$out" -maxdepth 1 -type f -name "*.mp4" -printf "%f\n")
            for f in $after
                if not contains -- "$f" $before
                    set title (string replace -r "\.mp4\$" "" -- "$f")
                    break
                end
            end

            set -l waiting 0
            if test -f "$queue"
                set waiting (string match -rv "^\s*\$" < "$queue" | count)
            end

            printf "\033[1A\033[J"
            echo -s $green "$title 󰄬" $reset
            if command -v hyprctl >/dev/null 2>&1
                if test $waiting -gt 0
                    hyprctl notify -1 2200 "rgb(cba6f7)" "󰄬 $title | $waiting" >/dev/null 2>&1
                else
                    hyprctl notify -1 2200 "rgb(cba6f7)" "󰄬 $title" >/dev/null 2>&1
                end
            end
        ' "$url" "$out" "$queue"
    end

    if test -n "$argv[1]"
        __mp4_download "$argv[1]"
        functions -e __mp4_download
        return $status
    end

    if not command -v wl-paste >/dev/null 2>&1
        echo -s $red "wl-paste not found" $reset
        return 1
    end

    set -l worker_pid
    set -l state_dir "/tmp/mp4_queue_$fish_pid"
    set -l queue_file "$state_dir/queue"
    set -l seen_file "$state_dir/seen"
    set -l active_file "$state_dir/active"
    set -l current_clip_file "$state_dir/current"
    rm -rf "$state_dir"
    mkdir -p "$state_dir"
    touch "$queue_file" "$seen_file"
    wl-paste -n 2>/dev/null | string trim > "$current_clip_file"

    clear
    echo "󱎫"

    wl-paste --watch fish -c '
        set -l clip (cat | string trim)
        set -l queue_file $argv[1]
        set -l seen_file $argv[2]
        set -l current_clip_file $argv[3]

        if not string match -qr "^https?://(www\.|music\.)?(youtube\.com|youtu\.be)/" -- "$clip"
            exit 0
        end

        if test -f "$current_clip_file"
            set -l current_clip (cat "$current_clip_file")
            if test -n "$current_clip"; and test "$clip" = "$current_clip"
                rm -f "$current_clip_file"
                exit 0
            end
        end

        if grep -Fxq -- "$clip" "$seen_file" 2>/dev/null
            exit 0
        end

        echo "$clip" >> "$seen_file"
        echo "$clip" >> "$queue_file"

        set -l total (wc -l < "$queue_file" | string trim)
        if command -v hyprctl >/dev/null 2>&1
            hyprctl notify -1 2200 "rgb(cba6f7)" "󱐋 $total" >/dev/null 2>&1
        end
    ' "$queue_file" "$seen_file" "$current_clip_file" &

    while true
        if test -n "$worker_pid"; and not kill -0 $worker_pid >/dev/null 2>&1
            wait $worker_pid >/dev/null 2>&1
            set -e worker_pid
            echo 0 > "$active_file"
        end

        if test -z "$worker_pid"; and test -s "$queue_file"
            set -l next (head -n 1 "$queue_file")
            tail -n +2 "$queue_file" > "$queue_file.tmp"
            mv "$queue_file.tmp" "$queue_file"

            if test -n "$next"
                echo 1 > "$active_file"
                __mp4_download "$next" &
                set worker_pid $last_pid
            end
        end

        sleep 0.15
    end
end

# ─── yt
function yt
    set -l CHANNEL_NAME_IN_FILENAME true
    set -l MP3_DIR "$HOME/0/music/yt"
    set -l MP4_DIR "$HOME/0/music/yt"

    set -l R (set_color red)
    set -l G (set_color green)
    set -l P (set_color cba6f7)
    set -l D (set_color brblack)
    set -l N (set_color normal)

    echo "$D󱎫 Download$N"
    echo "  [1] $G mp3$N"
    echo "  [2] $R mp4$N"
    echo "$D  [0] 󰜺 exit$N"
    read -P "→ " choice

    test "$choice" = 0 && return 0
    if test "$choice" != 1 -a "$choice" != 2
        return 1
    end

    set -l out_dir
    if test "$choice" = 1
        set out_dir $MP3_DIR
    else
        set out_dir $MP4_DIR
    end
    mkdir -p "$out_dir"

    function __yt_download --no-scope-shadowing
        set -l url $argv[1]
        set -l out $argv[2]
        set -l type $argv[3]
        set -l with_channel $argv[4]

        set -l name_template "%(title)s.%(ext)s"
        if test "$with_channel" = true
            set name_template "%(uploader)s - %(title)s.%(ext)s"
        end

        if test "$type" = mp3
            yt-dlp --no-config (__yt_browser_cookies) -x --audio-format mp3 --audio-quality 0 (__yt_mp3_thumbnail_flags) --no-playlist --no-video -o "$out/$name_template" "$url"
        else
            yt-dlp --no-config (__yt_browser_cookies) -f "bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=720]+bestaudio/best[height<=720]/best" --merge-output-format mp4 --no-playlist -o "$out/$name_template" "$url"
        end
    end

    function __yt_queue_count --no-scope-shadowing
        set -l active 0
        if test -f "$active_file"
            set active (cat "$active_file")
        end
        set -l waiting 0
        if test -f "$queue_file"
            set waiting (string match -rv '^\s*$' < "$queue_file" | count)
        end
        math $active + $waiting
    end

    set -l worker_pid
    set -l state_dir "/tmp/yt_queue_$fish_pid"
    set -l queue_file "$state_dir/queue"
    set -l seen_file "$state_dir/seen"
    set -l active_file "$state_dir/active"
    set -l current_clip_file "$state_dir/current"
    rm -rf "$state_dir"
    mkdir -p "$state_dir"
    touch "$queue_file" "$seen_file"
    wl-paste -n 2>/dev/null | string trim > "$current_clip_file"

    clear
    echo "󱎫"

    wl-paste --watch fish -c '
        set -l clip (cat | string trim)
        set -l queue_file $argv[1]
        set -l seen_file $argv[2]
        set -l current_clip_file $argv[3]

        if not string match -qr "^https?://(www\.|music\.)?(youtube\.com|youtu\.be)/" -- "$clip"
            exit 0
        end

        if test -f "$current_clip_file"
            set -l current_clip (cat "$current_clip_file")
            if test -n "$current_clip"; and test "$clip" = "$current_clip"
                rm -f "$current_clip_file"
                exit 0
            end
        end

        if grep -Fxq -- "$clip" "$seen_file" 2>/dev/null
            exit 0
        end

        echo "$clip" >> "$seen_file"
        echo "$clip" >> "$queue_file"

        set -l total (wc -l < "$queue_file" | string trim)
        if command -v hyprctl >/dev/null 2>&1
            hyprctl notify -1 2200 "rgb(cba6f7)" "󱐋 $total" >/dev/null 2>&1
        end
    ' "$queue_file" "$seen_file" "$current_clip_file" &
    set -l watch_pid $last_pid

    while true
        if test -n "$worker_pid"; and not kill -0 $worker_pid >/dev/null 2>&1
            wait $worker_pid >/dev/null 2>&1
            set -e worker_pid
            echo 0 > "$active_file"
        end

        if test -z "$worker_pid"; and test -s "$queue_file"
            set -l next (head -n 1 "$queue_file")
            tail -n +2 "$queue_file" > "$queue_file.tmp"
            mv "$queue_file.tmp" "$queue_file"

            if test -n "$next"
                echo 1 > "$active_file"
                set -l remaining (string match -rv '^\s*$' < "$queue_file" | count)
                printf '\033[H\033[J'
                if test $remaining -gt 0
                    echo "󱐋 $remaining"
                    echo ""
                end
                if test "$choice" = 1
                    __yt_download "$next" "$out_dir" mp3 $CHANNEL_NAME_IN_FILENAME
                else
                    __yt_download "$next" "$out_dir" mp4 $CHANNEL_NAME_IN_FILENAME
                end
            end
        end

        sleep 0.15
    end

    functions -e __yt_download
    functions -e __yt_queue_count
end

# ─── ytl
function ytl
    set -l CHANNEL_NAME_IN_FILENAME true

    set -l R (set_color red)
    set -l G (set_color green)
    set -l D (set_color brblack)
    set -l N (set_color normal)

    echo "$D󱎫 Download$N"
    echo "  [1] $G mp3$N"
    echo "  [2] $R mp4$N"
    echo "$D  [0] exit$N"
    read -P "→ " choice

    test "$choice" = 0 && return 0
    if test "$choice" != 1 -a "$choice" != 2
        return 1
    end

    set -l type mp4
    if test "$choice" = 1
        set type mp3
    end

    function __ytl_download --no-scope-shadowing
        set -l url $argv[1]
        set -l out $argv[2]
        set -l dl_type $argv[3]
        set -l with_channel $argv[4]

        set -l name_template "%(title)s.%(ext)s"
        if test "$with_channel" = true
            set name_template "%(uploader)s - %(title)s.%(ext)s"
        end

        set -l cookies_arg
        if test -d ~/.termux -o -n "$TERMUX_VERSION"
            set cookies_arg
        else
            set cookies_arg (__yt_browser_cookies)
        end

        if test "$dl_type" = mp3
            yt-dlp --no-config $cookies_arg -x --audio-format mp3 --audio-quality 0 (__yt_mp3_thumbnail_flags) --no-playlist --no-video -o "$out/$name_template" "$url"
        else
            yt-dlp --no-config $cookies_arg -f "bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=720]+bestaudio/best[height<=720]/best" --merge-output-format mp4 --no-playlist -o "$out/$name_template" "$url"
        end
    end

    set -l queue
    set -l worker_pid

    echo "paste links (empty enter to check queue, Ctrl+D to exit)"

    while read -l url
        set url (string trim -c '"' -- "$url")
        set url (string trim -c "'" -- "$url")
        set url (string trim -- "$url")
        if test -n "$url"
            set -a queue "$url"
        end

        if test -n "$worker_pid"; and not kill -0 $worker_pid >/dev/null 2>&1
            wait $worker_pid >/dev/null 2>&1
            set -e worker_pid
        end

        if test -z "$worker_pid"; and test (count $queue) -gt 0
            set -l next $queue[1]
            set -e queue[1]
            __ytl_download "$next" "$PWD" $type $CHANNEL_NAME_IN_FILENAME &
            set worker_pid $last_pid
            set -l waiting (count $queue)
            if test "$waiting" -gt 0
                echo "󱐋 $waiting"
            end
        end
    end

    if test -n "$worker_pid"
        wait $worker_pid >/dev/null 2>&1
    end

    while test (count $queue) -gt 0
        set -l next $queue[1]
        set -e queue[1]
        __ytl_download "$next" "$PWD" $type $CHANNEL_NAME_IN_FILENAME
    end

    functions -e __ytl_download
end
#
function __extra_cnf
    if not string match -qr '^https?://(www\.|music\.)?(youtube\.com|youtu\.be)/' -- $argv[1]; return 1; end
    if not command -v yt-dlp >/dev/null 2>&1; echo "yt-dlp not found"; return 1; end
    set -l Y (set_color yellow); set -l N (set_color normal); set -l G (set_color green); set -l R (set_color red)
    echo "  [1] $G mp3$N  [2] $R mp4$N"
    read -P "→ " c
    set -l title (yt-dlp --no-warnings --no-playlist --skip-download --print "%(title)s" $argv[1] 2>/dev/null | head -n 1)
    test -n "$title"; or set title "?"
    if test "$c" = 1
        set -l d $HOME/0/music/yt; mkdir -p $d
        yt-dlp --no-config (__yt_browser_cookies) --concurrent-fragments 16 --throttled-rate 100K (__yt_mp3_thumbnail_flags) -x --audio-format mp3 --audio-quality 0 --no-playlist --no-video -o "$d/%(title)s.%(ext)s" $argv[1]
    else if test "$c" = 2
        set -l d $HOME/0/music/yt; mkdir -p $d
        yt-dlp --no-config (__yt_browser_cookies) --concurrent-fragments 16 --throttled-rate 100K --embed-thumbnail --add-metadata --sponsorblock-remove sponsor,selfpromo,interaction,preview,filler,intro,outro -f "bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=720]+bestaudio/best[height<=720]/best" --merge-output-format mp4 --no-playlist -o "$d/%(title)s.%(ext)s" $argv[1]
    else; return 1; end
    clear; echo -s $G "$title 󰄬" $N
    return 0
end

# ─── ytp
function ytp --description 'yt mp3 clip'
    set -l out_dir "$HOME/0/music/yt"
    mkdir -p "$out_dir"
    set -l CHANNEL_NAME_IN_FILENAME true
    set -l green (set_color green)
    set -l red (set_color red)
    set -l yellow (set_color yellow)
    set -l reset (set_color normal)

    if not command -v yt-dlp >/dev/null 2>&1
        echo -s $red "yt-dlp not found" $reset
        return 1
    end

    mkdir -p "$out_dir"

    function __ytp_download --no-scope-shadowing
        set -l url $argv[1]
        set -l out "$out_dir"
        set -l title (yt-dlp --no-config --no-warnings --no-playlist --skip-download --print "%(title)s" "$url" 2>/dev/null | head -n 1)
        test -n "$title"; or set title "ytp"

        yt-dlp \
            --no-config \
            (__yt_browser_cookies) \
            -x \
            --audio-format mp3 \
            --audio-quality 0 \
            (__yt_mp3_thumbnail_flags) \
            --no-playlist \
            -o "$out/%(uploader)s - %(title)s.%(ext)s" \
            "$url"
        set -l code $status

        if test $code -ne 0
            if command -v hyprctl >/dev/null 2>&1
                hyprctl notify -1 2200 "rgb(cba6f7)" "fontsize:18 󰅙" >/dev/null 2>&1
            end
        else
            if command -v hyprctl >/dev/null 2>&1
                hyprctl notify 5 3000 "rgb(00ff00)" "fontsize:18 $title" >/dev/null 2>&1
            end
        end

        return $code
    end

    if test -n "$argv[1]"
        __ytp_download "$argv[1]"
        functions -e __ytp_download
        return $status
    end

    if not command -v wl-paste >/dev/null 2>&1
        echo -s $red "wl-paste not found" $reset
        return 1
    end

    set -l worker_pid
    set -l state_dir "/tmp/ytp_queue_$fish_pid"
    set -l queue_file "$state_dir/queue"
    set -l seen_file "$state_dir/seen"
    set -l active_file "$state_dir/active"
    set -l current_clip_file "$state_dir/current"
    rm -rf "$state_dir"
    mkdir -p "$state_dir"
    touch "$queue_file" "$seen_file"
    wl-paste -n 2>/dev/null | string trim > "$current_clip_file"

    clear
    echo "󱎫"

    wl-paste --watch fish -c '
        set -l clip (cat | string trim)
        set -l queue_file $argv[1]
        set -l seen_file $argv[2]
        set -l active_file $argv[3]
        set -l current_clip_file $argv[4]

        if not string match -qr "^https?://(www\.|music\.)?(youtube\.com|youtu\.be)/" -- "$clip"
            exit 0
        end

        if test -f "$current_clip_file"
            set -l current_clip (cat "$current_clip_file")
            if test -n "$current_clip"; and test "$clip" = "$current_clip"
                rm -f "$current_clip_file"
                exit 0
            end
        end

        if grep -Fxq -- "$clip" "$seen_file" 2>/dev/null
            exit 0
        end

        echo "$clip" >> "$seen_file"
        echo "$clip" >> "$queue_file"

        set -l total (wc -l < "$queue_file" | string trim)
        if command -v hyprctl >/dev/null 2>&1
            hyprctl notify -1 2200 "rgb(cba6f7)" "fontsize:18 󱐋 $total" >/dev/null 2>&1
        end
    ' "$queue_file" "$seen_file" "$active_file" "$current_clip_file" &
    set -l watch_pid $last_pid

    while true
        if test -n "$worker_pid"; and not kill -0 $worker_pid >/dev/null 2>&1
            wait $worker_pid >/dev/null 2>&1
            set -e worker_pid
            echo 0 > "$active_file"
        end

        if test -z "$worker_pid"; and test -s "$queue_file"
            set -l next (head -n 1 "$queue_file")
            tail -n +2 "$queue_file" > "$queue_file.tmp"
            mv "$queue_file.tmp" "$queue_file"

            if test -n "$next"
                echo 1 > "$active_file"
                clear
                __ytp_download "$next"
            end
        end

        sleep 0.15
    end
end

# ─── yta
function yta -d "yt album/playlist downloader"
    set -l url
    if test -n "$argv[1]"
        set url "$argv[1]"
    else
        if not command -v wl-paste >/dev/null 2>&1
            echo "yta: wl-paste not found"
            return 1
        end
        set url (wl-paste -n 2>/dev/null | string trim)
    end

    if not string match -qr '^https?://(www\.|music\.)?(youtube\.com|youtu\.be)/' -- "$url"
        echo "yta: no valid youtube link"
        return 1
    end

    if not command -v yt-dlp >/dev/null 2>&1
        echo "yta: yt-dlp not found"
        return 1
    end

    set -l out_dir "$HOME/0/music/yt"
    mkdir -p "$out_dir"

    set -l clean_title_arg
    if test "$YTA_CLEAN_TITLE" = true
        set -a clean_title_arg --replace-in-metadata
        set -a clean_title_arg title
        set -a clean_title_arg '(?i)\\s*[\\(\\[]?(?:feat|ft)\\.?\\s*[\\)\\]]?.*$'
        set -a clean_title_arg ''
    end

    set -l tmpfile "/tmp/yta_files_$fish_pid"
    rm -f "$tmpfile"

    yt-dlp --no-config \
        (__yt_browser_cookies) \
        -x \
        --audio-format mp3 \
        --audio-quality 0 \
        (__yt_mp3_thumbnail_flags) \
        --replace-in-metadata "uploader" " - Topic\$" "" \
        $clean_title_arg \
        --parse-metadata "playlist_index:%(track_number)s" \
        --parse-metadata "uploader:%(artist)s" \
        --parse-metadata "uploader:%(album_artist)s" \
        --add-metadata \
        --yes-playlist \
        --no-video \
        --print-to-file after_move:filepath "$tmpfile" \
        -o "$out_dir/%(uploader)s/%(album)s/%(title)s.%(ext)s" \
        "$url"

    set -l code $status

    if test "$YTA_CLEAN_TITLE" = true; and test -f "$tmpfile"
        for filepath in (cat "$tmpfile")
            set -l title (ffprobe -v error -show_entries format_tags=title -of default=noprint_wrappers=1 "$filepath" 2>/dev/null | string replace -r '^TAG:title=' '')
            set -l clean (string replace -ri '(?i)\s*[\(\[]?(?:feat|ft)\.?\s*[\)\]]?.*$' '' -- "$title")
            if test "$title" != "$clean"; and test -n "$clean"
                ffmpeg -loglevel quiet -y -i "$filepath" -c copy -metadata title="$clean" "$filepath.tmp.mp3"
                if test $status -eq 0
                    mv -f "$filepath.tmp.mp3" "$filepath"
                end
            end
        end
    end

    rm -f "$tmpfile"
    return $code
end
