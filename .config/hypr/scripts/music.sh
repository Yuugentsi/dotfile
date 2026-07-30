#!/bin/bash
# bind_exec("SUPER + G", "$HOME/.config/hypr/scripts/music.sh")
MUSIC_DIR="${MUSIC_DIR:-${HOME}/0/music}"
CACHE_FILE="${HOME}/.cache/scripts/music/cache.txt"
CACHE_MTIME_FILE="${HOME}/.cache/scripts/music/cache-mtime.txt"

for b in zen-browser firefox brave librewolf chromium; do
    if command -v "$b" &>/dev/null; then
        BROWSER="$b"
        break
    fi
done

run_mpv() {
    pgrep -x mpv | grep -v $$ | xargs -r kill -9 2>/dev/null
    sleep 0.1
    [[ -f "$1" ]] && true
    local args=()
    for f in "$@"; do
        if [[ "$f" =~ \.(opus|flac|mp3)$ ]]; then
            args+=(--no-resume-playback)
            break
        fi
    done
    /usr/bin/mpv "${args[@]}" "$@"
}

get_mtime() {
    local dir_hash
    dir_hash=$(find "$1" -type d | xargs stat --format="%Y %n" 2>/dev/null | sort | md5sum)
    local file_count
    file_count=$(find "$1" -type f \( \
        -iname "*.mp3" -o -iname "*.flac" -o -iname "*.ogg" -o \
        -iname "*.wav" -o -iname "*.aac" -o -iname "*.opus" -o \
        -iname "*.m4a" -o -iname "*.wma" \
    \) 2>/dev/null | wc -l)
    echo "$dir_hash $file_count" | md5sum
}

build_cache() {
    local tmp
    tmp=$(mktemp)
    mkdir -p "$(dirname "$CACHE_FILE")"

    while IFS= read -r artist_dir; do
        local artist_name artist_count
        artist_name=$(basename "$artist_dir")
        artist_count=$(find "$artist_dir" -type f \( \
            -iname "*.mp3" -o -iname "*.flac" -o -iname "*.ogg" -o \
            -iname "*.wav" -o -iname "*.aac" -o -iname "*.opus" -o \
            -iname "*.m4a" -o -iname "*.wma" \
        \) 2>/dev/null | wc -l)
        [[ "$artist_count" -eq 0 ]] && continue

        printf 'artist\t%s\t%s\n' "$artist_name" "$artist_count" >> "$tmp"

        while IFS= read -r album_dir; do
            local album_name album_count
            album_name=$(basename "$album_dir")
            album_count=$(find "$album_dir" -type f \( \
                -iname "*.mp3" -o -iname "*.flac" -o -iname "*.ogg" -o \
                -iname "*.wav" -o -iname "*.aac" -o -iname "*.opus" -o \
                -iname "*.m4a" -o -iname "*.wma" \
            \) 2>/dev/null | wc -l)
            [[ "$album_count" -eq 0 ]] && continue
            printf 'album\t%s\t%s\t%s\n' "$artist_name" "$album_name" "$album_count" >> "$tmp"
        done < <(find "$artist_dir" -mindepth 1 -maxdepth 1 -type d | sort)

    done < <(find "$MUSIC_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

    local root_count
    root_count=$(find "$MUSIC_DIR" -maxdepth 1 -type f \( \
        -iname "*.mp3" -o -iname "*.flac" -o -iname "*.ogg" -o \
        -iname "*.wav" -o -iname "*.aac" -o -iname "*.opus" -o \
        -iname "*.m4a" -o -iname "*.wma" \
    \) 2>/dev/null | wc -l)

    if [[ "$root_count" -gt 0 ]]; then
        printf 'artist\t%s\t%s\n' 'Various' "$root_count" >> "$tmp"
    fi

    mv "$tmp" "$CACHE_FILE"
    get_mtime "$MUSIC_DIR" > "$CACHE_MTIME_FILE"
}

refresh_cache_if_needed() {
    if [[ ! -f "$CACHE_FILE" ]] || [[ ! -f "$CACHE_MTIME_FILE" ]]; then
        build_cache
        return
    fi
    local current_mtime
    current_mtime=$(get_mtime "$MUSIC_DIR")
    local cached_mtime
    cached_mtime=$(cat "$CACHE_MTIME_FILE")
    if [[ "$current_mtime" != "$cached_mtime" ]]; then
        build_cache
    fi
}

get_artist_count() {
    grep -m1 $'^artist\t'"$1"$'\t' "$CACHE_FILE" | cut -f3
}

get_album_count() {
    grep -m1 $'^album\t'"$1"$'\t'"$2"$'\t' "$CACHE_FILE" | cut -f4
}

get_total_count() {
    grep $'^artist\t' "$CACHE_FILE" | awk -F'\t' '{sum+=$3} END{print sum}'
}

run_music_picker() {
    pkill -x rofi 2>/dev/null
    sleep 0.1

    refresh_cache_if_needed

    local RANDOM_PLAYED="/tmp/music-picker-random-played.txt"

    local ROFI_MUSIC_THEME=(
        -theme-str '* { font: "JetBrainsMono Nerd Font Medium 10.5"; bg: rgba(12,4,8,0.75); bg-alt: rgba(255,255,255,0.05); bg-hover: rgba(200,90,120,0.25); fg: #ffe0ec; muted: #b898a8; accent: #f8b4c8; glow: rgba(248,180,200,0.5); }'
        -theme-str 'window { width: 54%; background-color: @bg; transparency: "real"; border: 2px; border-color: @glow; border-radius: 18px; }'
        -theme-str 'mainbox { background-color: transparent; padding: 8px; spacing: 4px; }'
        -theme-str 'inputbar { background-color: rgba(255,255,255,0.07); padding: 6px 10px; border: 1px; border-color: rgba(248,180,200,0.2); border-radius: 10px; children: [ entry ]; }'
        -theme-str 'entry { background-color: transparent; text-color: @fg; placeholder-color: @muted; cursor-color: @accent; cursor-width: 2px; }'
        -theme-str 'listview { background-color: transparent; columns: 1; lines: 12; fixed-height: false; dynamic: true; spacing: 2px; scrollbar: true; scrollbar-width: 4px; }'
        -theme-str 'scrollbar { background-color: transparent; handle-color: @accent; handle-width: 4px; border-radius: 2px; }'
        -theme-str 'element { background-color: @bg-alt; text-color: @fg; padding: 4px 8px; height: 28px; border: 1px; border-color: rgba(255,255,255,0.03); border-radius: 8px; }'
        -theme-str 'element normal.normal { background-color: @bg-alt; text-color: @fg; }'
        -theme-str 'element alternate.normal { background-color: @bg-alt; text-color: @fg; }'
        -theme-str 'element selected.normal { background-color: @bg-hover; text-color: @accent; border: 2px; border-color: @accent; }'
        -theme-str 'element-text { background-color: transparent; text-color: @fg; vertical-align: 0.5; highlight: bold #ffffff; }'
        -theme-str 'element normal.normal element-text { background-color: transparent; text-color: @fg; }'
        -theme-str 'element alternate.normal element-text { background-color: transparent; text-color: @fg; }'
        -theme-str 'element selected.normal element-text { background-color: transparent; text-color: @accent; }'
    )

    rofi_menu() {
        rofi -dmenu -i -no-custom \
            "${ROFI_MUSIC_THEME[@]}" \
            -p "$1"
    }

    rofi_custom_menu() {
        rofi -dmenu -i -kb-custom-1 "Control+t" -kb-custom-2 "Control+r" \
            "${ROFI_MUSIC_THEME[@]}" \
            -p "$1"
    }

    list_tracks() {
        find "$1" -type f \( \
            -iname "*.mp3" -o \
            -iname "*.flac" -o \
            -iname "*.ogg" -o \
            -iname "*.wav" -o \
            -iname "*.aac" -o \
            -iname "*.opus" -o \
            -iname "*.m4a" -o \
            -iname "*.wma" \
        \) 2>/dev/null
    }

    play_random_no_repeat() {
        local tmp_all tmp_unplayed random_track

        tmp_all=$(mktemp /tmp/music-picker-all-XXXX.txt)
        tmp_unplayed=$(mktemp /tmp/music-picker-unplayed-XXXX.txt)

        list_tracks "$MUSIC_DIR" | sort > "$tmp_all"
        touch "$RANDOM_PLAYED"

        grep -Fxv -f "$RANDOM_PLAYED" "$tmp_all" > "$tmp_unplayed"

        if [[ ! -s "$tmp_unplayed" ]]; then
            : > "$RANDOM_PLAYED"
            cp "$tmp_all" "$tmp_unplayed"
        fi

        random_track=$(shuf -n1 "$tmp_unplayed")

        rm -f "$tmp_all" "$tmp_unplayed"

        [[ -z "$random_track" ]] && exit 0

        printf '%s\n' "$random_track" >> "$RANDOM_PLAYED"
        run_mpv --no-video "$random_track" >/dev/null 2>&1 &
        exit 0
    }

    if ! pgrep -x mpv > /dev/null; then
        local random_track
        random_track=$(list_tracks "$MUSIC_DIR" | shuf -n1)
        run_mpv --no-video "$random_track" >/dev/null 2>&1 &
    fi

    local now_playing=""
    local np_artist=""

    if playerctl status 2>/dev/null | grep -q "Playing\|Paused"; then
        local np_title
        np_title=$(playerctl metadata title 2>/dev/null)
        np_artist=$(playerctl metadata artist 2>/dev/null)
        [[ -n "$np_title" ]] && now_playing="󰎇  $np_artist — $np_title"
    fi

    local all_count
    all_count=$(get_total_count)

    local ALL_OPTION="󰒓  ALL ($all_count)"
    local TRACKLIST_OPTION="󰎸  Tracklist ($all_count)"

    local artist_entries
    artist_entries=$(
        grep $'^artist\t' "$CACHE_FILE" \
            | awk -F'\t' '{print $3"\t󰎈  "$2" ("$3")"}' \
            | sort -k1,1nr -k2,2f \
            | cut -f2-
    )

    local chosen_artist
    chosen_artist=$(printf '%s\n%s\n%s\n%s' "${now_playing:+$now_playing}" "$ALL_OPTION" "$TRACKLIST_OPTION" "$artist_entries" \
        | sed '/^$/d' \
        | rofi_custom_menu "󰝚  Artist:")
    local artist_status=$?

    if [[ "$artist_status" -eq 11 ]]; then
        play_random_no_repeat
    fi

    [[ -z "$chosen_artist" ]] && exit 0

    if [[ "$chosen_artist" == "$now_playing" ]] && [[ -n "$np_artist" ]]; then
        run_mpv --shuffle --no-video "$MUSIC_DIR/$np_artist"/**/* >/dev/null 2>&1 &
        exit 0
    fi

    if [[ "$chosen_artist" == "$ALL_OPTION" ]]; then
        : > "$RANDOM_PLAYED"
        run_mpv --shuffle --no-video "$MUSIC_DIR"/**/* >/dev/null 2>&1 &
        exit 0
    fi

    if [[ "$chosen_artist" == "$TRACKLIST_OPTION" ]]; then
        local all_tracks
        all_tracks=$(list_tracks "$MUSIC_DIR" | sort)

        local -a track_paths=()
        local -a track_display_list=()

        while IFS= read -r path; do
            local rel="${path#$MUSIC_DIR/}"
            local artist_dir="${rel%%/*}"
            local rest="${rel#*/}"
            if [[ "$rest" == */* ]]; then
                local alb="${rest%%/*}"
                local file="${rest#*/}"
                local name="${file%.*}"
                track_display_list+=("$artist_dir - $alb / $name")
            else
                local name="${rest%.*}"
                track_display_list+=("$artist_dir - $name")
            fi
            track_paths+=("$path")
        done <<< "$all_tracks"

        local display_text
        display_text=$(printf '%s\n' "${track_display_list[@]}" | rofi_menu "  Track:")
        [[ -z "$display_text" ]] && exit 0

        local sel_idx=-1
        for i in "${!track_display_list[@]}"; do
            if [[ "${track_display_list[$i]}" == "$display_text" ]]; then
                sel_idx=$i
                break
            fi
        done

        [[ $sel_idx -eq -1 ]] && exit 0

        local track_path="${track_paths[$sel_idx]}"

        local tmp_playlist
        tmp_playlist=$(mktemp /tmp/mpv-playlist-XXXX.m3u)

        echo "$track_path" > "$tmp_playlist"

        if [[ $((sel_idx + 1)) -lt ${#track_paths[@]} ]]; then
            printf '%s\n' "${track_paths[@]:$((sel_idx + 1))}" >> "$tmp_playlist"
        fi

        run_mpv --no-video --playlist="$tmp_playlist" >/dev/null 2>&1 &
        exit 0
    fi

    local artist
    artist=$(echo "$chosen_artist" | sed 's/^󰎈  //' | sed 's/ ([0-9]\+)$//')

    local is_virtual=false
    [[ "$artist" == "Various" ]] && is_virtual=true

    if ! $is_virtual && [[ ! -d "$MUSIC_DIR/$artist" ]]; then
        exit 0
    fi

    if [[ "$artist_status" -eq 10 ]]; then
        if $is_virtual; then
            run_mpv --shuffle --no-video "$MUSIC_DIR"/* >/dev/null 2>&1 &
        else
            run_mpv --shuffle --no-video "$MUSIC_DIR/$artist"/**/* >/dev/null 2>&1 &
        fi
        exit 0
    fi

    sleep 0.1

    local artist_total
    artist_total=$(get_artist_count "$artist")

    local ARTIST_ALL_OPTION="󰒓  ALL ($artist_total)"
    local TRACKLIST_OPTION="󰎸  Tracklist ($artist_total)"

    local album_entries
    album_entries=$(
        grep $'^album\t'"$artist"$'\t' "$CACHE_FILE" \
            | awk -F'\t' '{print $4"\t󰀥  "$3" ("$4")"}' \
            | sort -k1,1nr -k2,2f \
            | cut -f2-
    )

    local album_count
    album_count=$(grep -c $'^album\t'"$artist"$'\t' "$CACHE_FILE" 2>/dev/null)
    [[ -z "$album_count" ]] && album_count=0

    if [[ "$album_count" -eq 1 ]]; then
        local single_album
        single_album=$(echo "$album_entries" | sed 's/^󰀥  //' | sed 's/ ([0-9]\+)$//')
        run_mpv --shuffle --no-video "$MUSIC_DIR/$artist/$single_album"/* >/dev/null 2>&1 &
        exit 0
    fi

    if [[ "$album_count" -eq 0 ]]; then
        run_mpv --shuffle --no-video "$MUSIC_DIR/$artist"/* >/dev/null 2>&1 &
        exit 0
    fi

    local album
    local album_status=0
    if $is_virtual; then
        album="$TRACKLIST_OPTION"
    else
        album=$(printf '%s\n%s\n%s' "$ARTIST_ALL_OPTION" "$TRACKLIST_OPTION" "$album_entries" \
            | sed '/^$/d' \
            | rofi_custom_menu "󰀥  Album:")
        album_status=$?
    fi

    if [[ "$album_status" -eq 11 ]]; then
        play_random_no_repeat
    fi

    [[ -z "$album" ]] && exit 0

    if [[ "$album" == "$ARTIST_ALL_OPTION" ]]; then
        if $is_virtual; then
            run_mpv --shuffle --no-video "$MUSIC_DIR"/* >/dev/null 2>&1 &
        else
            run_mpv --shuffle --no-video "$MUSIC_DIR/$artist"/**/* >/dev/null 2>&1 &
        fi
        exit 0
    fi

    if [[ "$album" == "$TRACKLIST_OPTION" ]]; then
        sleep 0.1

        local all_tracks
        if $is_virtual; then
            all_tracks=$(list_tracks "$MUSIC_DIR" | sort)
        else
            all_tracks=$(list_tracks "$MUSIC_DIR/$artist" | sort)
        fi

        local -a track_paths=()
        local -a track_display_list=()

        while IFS= read -r path; do
            if $is_virtual; then
                local rel="${path#$MUSIC_DIR/}"
            else
                local rel="${path#$MUSIC_DIR/$artist/}"
            fi
            if [[ "$rel" == */* ]]; then
                local alb="${rel%%/*}"
                local file="${rel#*/}"
                local name="${file%.*}"
                track_display_list+=("$alb / $name")
            else
                local name="${rel%.*}"
                track_display_list+=("$name")
            fi
            track_paths+=("$path")
        done <<< "$all_tracks"

        local display_text
        display_text=$(printf '%s\n' "${track_display_list[@]}" | rofi_menu "  Track:")
        [[ -z "$display_text" ]] && exit 0

        local sel_idx=-1
        for i in "${!track_display_list[@]}"; do
            if [[ "${track_display_list[$i]}" == "$display_text" ]]; then
                sel_idx=$i
                break
            fi
        done

        [[ $sel_idx -eq -1 ]] && exit 0

        local track_path="${track_paths[$sel_idx]}"

        local tmp_playlist
        tmp_playlist=$(mktemp /tmp/mpv-playlist-XXXX.m3u)

        echo "$track_path" > "$tmp_playlist"

        if [[ $((sel_idx + 1)) -lt ${#track_paths[@]} ]]; then
            printf '%s\n' "${track_paths[@]:$((sel_idx + 1))}" >> "$tmp_playlist"
        fi

        if $is_virtual; then
            list_tracks "$MUSIC_DIR" | while IFS= read -r f; do
                [[ "${f#$MUSIC_DIR/}" == */* ]] && echo "$f"
            done | shuf >> "$tmp_playlist"
        else
            list_tracks "$MUSIC_DIR" | grep -v "/$artist/" | shuf >> "$tmp_playlist"
        fi

        run_mpv --no-video --playlist="$tmp_playlist" >/dev/null 2>&1 &
        exit 0
    fi

    local album_clean
    album_clean=$(echo "$album" | sed 's/^󰀥  //' | sed 's/ ([0-9]\+)$//')

    [[ ! -d "$MUSIC_DIR/$artist/$album_clean" ]] && exit 0

    if [[ "$album_status" -eq 10 ]]; then
        run_mpv --shuffle --no-video "$MUSIC_DIR/$artist/$album_clean"/* >/dev/null 2>&1 &
        exit 0
    fi

    run_mpv --shuffle --no-video "$MUSIC_DIR/$artist/$album_clean"/* >/dev/null 2>&1 &
}

run_music_picker
