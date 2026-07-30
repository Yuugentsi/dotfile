#!/bin/bash

for b in zen-browser brave-origin librewolf firefox chromium; do
    if command -v "$b" &>/dev/null; then
        BROWSER="$b"
        break
    fi
done

rofi_menu() {
    local lines="${2:-10}"
    rofi -dmenu -i \
        -theme-str '* { font: "JetBrainsMono Nerd Font Medium 10.5"; bg: rgba(12,4,8,0.75); bg-alt: rgba(255,255,255,0.05); bg-hover: rgba(200,90,120,0.25); fg: #ffe0ec; muted: #b898a8; accent: #f8b4c8; glow: rgba(248,180,200,0.5); }' \
        -theme-str 'window { width: 54%; background-color: @bg; transparency: "real"; border: 2px; border-color: @glow; border-radius: 18px; }' \
        -theme-str 'mainbox { background-color: transparent; padding: 8px; spacing: 4px; }' \
        -theme-str 'inputbar { background-color: rgba(255,255,255,0.07); padding: 6px 10px; border: 1px; border-color: rgba(248,180,200,0.2); border-radius: 10px; children: [ entry ]; }' \
        -theme-str 'entry { background-color: transparent; text-color: @fg; placeholder-color: @muted; cursor-color: @accent; cursor-width: 2px; }' \
        -theme-str "listview { columns: 1; lines: ${lines}; fixed-height: false; dynamic: true; spacing: 2px; scrollbar: true; scrollbar-width: 4px; }" \
        -theme-str 'scrollbar { background-color: transparent; handle-color: @accent; handle-width: 4px; border-radius: 2px; }' \
        -theme-str 'element { background-color: @bg-alt; text-color: @fg; padding: 4px 8px; height: 28px; border: 1px; border-color: rgba(255,255,255,0.03); border-radius: 8px; }' \
        -theme-str 'element normal.normal { background-color: @bg-alt; text-color: @fg; }' \
        -theme-str 'element alternate.normal { background-color: @bg-alt; text-color: @fg; }' \
        -theme-str 'element selected.normal { background-color: @bg-hover; text-color: @accent; border: 2px; border-color: @accent; }' \
        -theme-str 'element-text { background-color: transparent; text-color: @fg; vertical-align: 0.5; highlight: bold #ffffff; }' \
        -theme-str 'element normal.normal element-text { background-color: transparent; text-color: @fg; }' \
        -theme-str 'element alternate.normal element-text { background-color: transparent; text-color: @fg; }' \
        -theme-str 'element selected.normal element-text { background-color: transparent; text-color: @accent; }' \
        -p "$1"
}

open_all() {
    for url in "$@"; do
        "$BROWSER" "$url" &
    done
}

open_private() {
    local url="$1"
    case "$BROWSER" in
        zen-browser|librewolf|firefox)
            if [ -n "$url" ]; then
                "$BROWSER" --private-window "$url" &>/dev/null &
            else
                "$BROWSER" --private-window &>/dev/null &
            fi
            ;;
        brave-origin|brave|chromium|google-chrome|chrome)
            if [ -n "$url" ]; then
                "$BROWSER" --incognito "$url" &>/dev/null &
            else
                "$BROWSER" --incognito &>/dev/null &
            fi
            ;;
        *)
            if [ -n "$url" ]; then
                "$BROWSER" "$url" &>/dev/null &
            else
                "$BROWSER" &>/dev/null &
            fi
            ;;
    esac
}

_manga_rofi_menu() {
    rofi -dmenu -i -no-custom -selected-row 0 -format i \
        -theme-str '* { font: "JetBrainsMono Nerd Font Medium 10.5"; bg: rgba(12,4,8,0.75); bg-alt: rgba(255,255,255,0.05); bg-hover: rgba(200,90,120,0.25); fg: #ffe0ec; muted: #b898a8; accent: #f8b4c8; glow: rgba(248,180,200,0.5); }' \
        -theme-str 'window { width: 54%; background-color: @bg; transparency: "real"; border: 2px; border-color: @glow; border-radius: 18px; }' \
        -theme-str 'mainbox { background-color: transparent; padding: 8px; spacing: 4px; }' \
        -theme-str 'inputbar { background-color: rgba(255,255,255,0.07); padding: 6px 10px; border: 1px; border-color: rgba(248,180,200,0.2); border-radius: 10px; children: [ entry ]; }' \
        -theme-str 'entry { background-color: transparent; text-color: @fg; placeholder-color: @muted; cursor-color: @accent; cursor-width: 2px; }' \
        -theme-str 'listview { columns: 1; lines: 12; fixed-height: false; dynamic: true; spacing: 2px; scrollbar: true; scrollbar-width: 4px; }' \
        -theme-str 'scrollbar { background-color: transparent; handle-color: @accent; handle-width: 4px; border-radius: 2px; }' \
        -theme-str 'element { background-color: @bg-alt; text-color: @fg; padding: 4px 8px; height: 28px; border: 1px; border-color: rgba(255,255,255,0.03); border-radius: 8px; }' \
        -theme-str 'element normal.normal { background-color: @bg-alt; text-color: @fg; }' \
        -theme-str 'element alternate.normal { background-color: @bg-alt; text-color: @fg; }' \
        -theme-str 'element selected.normal { background-color: @bg-hover; text-color: @accent; border: 2px; border-color: @accent; }' \
        -theme-str 'element-text { background-color: transparent; text-color: @fg; vertical-align: 0.5; highlight: bold #ffffff; }' \
        -theme-str 'element normal.normal element-text { background-color: transparent; text-color: @fg; }' \
        -theme-str 'element alternate.normal element-text { background-color: transparent; text-color: @fg; }' \
        -theme-str 'element selected.normal element-text { background-color: transparent; text-color: @accent; }' \
        -p "$1"
}

# ----- sites search -----
ai_urls=(
    "https://chatgpt.com"
    "https://claude.ai"
    "https://duck.ai/"
    "https://kimi.com"
    "https://grok.com"
    "https://gemini.google.com/"
    "https://aistudio.google.com/"
    "https://chat.deepseek.com/"
    "https://chat.qwen.ai/"
)

anime_urls=(
    "https://animekai.to/home"
    "https://www.miruro.tv/"
    "https://kuudere.ru"
    "https://kaa.lt/"
)

web_urls=(
    "https://reddit.com"
    "https://letterboxd.com/yuugentsi/"
    "https://myanimelist.net"
    "https://anilist.co"
    "https://www.privacyguides.org/en/tools/"
    "https://news.ycombinator.com/"
    "https://lobste.rs/"
    "https://www.techmeme.com/"
    "https://apt.izzysoft.de/fdroid/"
    "https://f-droid.org/"
    "https://danbooru.donmai.us/"
    "https://www.deepl.com/en"
    "https://mail.google.com"
    "https://github.com"
    "https://wikipedia.org"
    "https://mail.proton.me/u/0/inbox"
    "https://pass.proton.me/u/0"
    "https://citywalks.live"
    "https://www.lofi.cafe/"
)

streaming_urls=(
    "https://www.cineby.sc/"
    "https://67movies.net"
    "https://popcornmovies.org/home"
    "https://shuttletv.su"
)

favorites_urls=(
    "https://wallhaven.cc/toplist"
    "https://youtube.com"
    "https://music.youtube.com"
    "https://last.fm"
    "https://pinterest.com"
    "https://fmhy.net/beginners-guide"
    "https://x.com"
    "https://addons.mozilla.org"
    "https://store.steampowered.com"
)

tech_urls=(
    "https://hackernoon.com/"
    "https://www.reuters.com/technology/"
    "https://www.wsj.com/tech"
    "https://www.androidpolice.com/"
    "https://techcrunch.com/"
)

open_site_choice() {
    case "$1" in
        *ChatGPT) "$BROWSER" "https://chatgpt.com" ;;
        *Claude) "$BROWSER" "https://claude.ai" ;;
        *DuckAI) "$BROWSER" "https://duck.ai/" ;;
        *Kimi) "$BROWSER" "https://kimi.com" ;;
        *Grok) "$BROWSER" "https://grok.com" ;;
        *Gemini) "$BROWSER" "https://gemini.google.com/" ;;
        *AI\ Studio) "$BROWSER" "https://aistudio.google.com/" ;;
        *DeepSeek) "$BROWSER" "https://chat.deepseek.com/" ;;
        *Qwen) "$BROWSER" "https://chat.qwen.ai/" ;;
        *AnimeKai) "$BROWSER" "https://animekai.to/home" ;;
        *Miruro) "$BROWSER" "https://www.miruro.tv/" ;;
        *Kuudere) "$BROWSER" "https://kuudere.ru" ;;
        *Kaa) "$BROWSER" "https://kaa.lt/" ;;
        *MyAnimeList) "$BROWSER" "https://myanimelist.net" ;;
        *AniList) "$BROWSER" "https://anilist.co" ;;
        *Twitter) "$BROWSER" "https://x.com" ;;
        *Reddit) "$BROWSER" "https://reddit.com" ;;
        *Letterboxd) "$BROWSER" "https://letterboxd.com/yuugentsi/" ;;
        *Pinterest) "$BROWSER" "https://pinterest.com" ;;
        *Last.fm) "$BROWSER" "https://last.fm/user/yuugentsi" ;;
        *Privacy\ Guides) "$BROWSER" "https://www.privacyguides.org/en/tools/" ;;
        *Hacker\ News) "$BROWSER" "https://news.ycombinator.com/" ;;
        *Lobsters) "$BROWSER" "https://lobste.rs/" ;;
        *Techmeme) "$BROWSER" "https://www.techmeme.com/" ;;
        *FMHY) "$BROWSER" "https://fmhy.net/beginners-guide" ;;
        *IzzyOnDroid) "$BROWSER" "https://apt.izzysoft.de/fdroid/" ;;
        *FDroid) "$BROWSER" "https://f-droid.org/" ;;
        *YouTube) "$BROWSER" "https://youtube.com" ;;
        *YouTube\ Music) "$BROWSER" "https://music.youtube.com" ;;
        *Danbooru) "$BROWSER" "https://danbooru.donmai.us/" ;;
        *Wallhaven) "$BROWSER" "https://wallhaven.cc/toplist" ;;
        *DeepL) "$BROWSER" "https://www.deepl.com/en" ;;
        *Gmail) "$BROWSER" "https://mail.google.com" ;;
        *GitHub) "$BROWSER" "https://github.com/repos" ;;
        *Wikipedia) "$BROWSER" "https://wikipedia.org" ;;
        *Proton\ Mail) "$BROWSER" "https://mail.proton.me/u/0/inbox" ;;
        *Proton\ Pass) "$BROWSER" "https://pass.proton.me/u/0" ;;
        *CityWalks) "$BROWSER" "https://citywalks.live" ;;
        *Lofi\ Cafe) "$BROWSER" "https://www.lofi.cafe/" ;;
        *X.com) "$BROWSER" "https://x.com" ;;
        *Extensions) "$BROWSER" "https://addons.mozilla.org" ;;
        *Steam) "$BROWSER" "https://store.steampowered.com" ;;
        *HackerNoon) "$BROWSER" "https://hackernoon.com/" ;;
        *Reuters\ Tech) "$BROWSER" "https://www.reuters.com/technology/" ;;
        *WSJ\ Tech) "$BROWSER" "https://www.wsj.com/tech" ;;
        *Android\ Police) "$BROWSER" "https://www.androidpolice.com/" ;;
        *TechCrunch) "$BROWSER" "https://techcrunch.com/" ;;
        *Cineby) "$BROWSER" "https://www.cineby.sc/" ;;
        *67Movies) "$BROWSER" "https://67movies.net" ;;
        *PopcornMovies) "$BROWSER" "https://popcornmovies.org/home" ;;
        *ShuttleTV) "$BROWSER" "https://shuttletv.su" ;;
        *aria2) zeditor "$HOME/.config/aria2" ;;
        *gallery-dl) zeditor "$HOME/.config/gallery-dl" ;;
        *kitty) zeditor "$HOME/.config/kitty" ;;
        *waybar) zeditor "$HOME/.config/waybar" ;;
        *rofi) zeditor "$HOME/.config/rofi" ;;
        *hypr) zeditor "$HOME/.config/hypr" ;;
        *mpv) zeditor "$HOME/.config/mpv" ;;
        *swayimg) zeditor "$HOME/.config/swayimg" ;;
        *yt-dlp) zeditor "$HOME/.config/yt-dlp" ;;
        *swaync) zeditor "$HOME/.config/swaync" ;;
        *zathura) zeditor "$HOME/.config/zathura" ;;
        *fish) zeditor "$HOME/.config/fish" ;;
    esac
}

handle_bang() {
    local input="$1"
    local bang query encoded
    bang=${input%% *}
    query=${input#* }
    [ "$bang" = "$query" ] && query=""
    encoded=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$query" 2>/dev/null || printf '%s' "$query")

    case "$bang" in
        .youtube|.yt)
            if [ -n "$query" ]; then
                "$BROWSER" "https://www.youtube.com/results?search_query=$encoded"
            else
                "$BROWSER" "https://youtube.com"
            fi
            ;;
        .x|.twitter)
            if [ -n "$query" ]; then
                "$BROWSER" "https://x.com/search?q=$encoded&src=typed_query"
            else
                "$BROWSER" "https://x.com"
            fi
            ;;
        .dan|.danbooru)
            if [ -n "$query" ]; then
                "$BROWSER" "https://danbooru.donmai.us/posts?tags=$encoded&z=5"
            else
                "$BROWSER" "https://danbooru.donmai.us"
            fi
            ;;
        .lastfm|.last)
            if [ -n "$query" ]; then
                "$BROWSER" "https://last.fm/user/$encoded"
            else
                "$BROWSER" "https://last.fm/user/yuugentsi"
            fi
            ;;
        .walltop|.wall) "$BROWSER" "https://wallhaven.cc/toplist" ;;
        .wallhot)       "$BROWSER" "https://wallhaven.cc/hot" ;;
        .github)
            if [ -n "$query" ]; then
                "$BROWSER" "https://github.com/$encoded"
            else
                "$BROWSER" "https://github.com/yuugentsi"
            fi
            ;;
        .git)
            if [ -n "$query" ]; then
                "$BROWSER" "https://github.com/$encoded"
            else
                "$BROWSER" "https://github.com/yuugentsi"
            fi
            ;;
        .gh)
            if [ -n "$query" ]; then
                "$BROWSER" "https://github.com/$encoded"
            else
                "$BROWSER" "https://github.com/Yuugentsi?tab=repositories"
            fi
            ;;
        .g)
            if [ -n "$query" ]; then
                "$BROWSER" "https://www.google.com/search?q=$encoded"
            else
                "$BROWSER" "https://google.com"
            fi
            ;;
        .p) open_private "$query" ;;
        .reddit)
            if [ -n "$query" ]; then
                "$BROWSER" "https://www.reddit.com/search/?q=$encoded"
            else
                "$BROWSER" "https://reddit.com"
            fi
            ;;
        .r)
            if [ -n "$query" ]; then
                "$BROWSER" "https://www.reddit.com/r/$encoded"
            else
                "$BROWSER" "https://reddit.com"
            fi
            ;;
        .pin)
            if [ -n "$query" ]; then
                "$BROWSER" "https://www.pinterest.com/search/pins/?q=$encoded"
            else
                "$BROWSER" "https://pinterest.com"
            fi
            ;;
        .mpv) mpv "$query" &>/dev/null & ;;
        .mp4) (hyprctl notify 5 2000 "rgb(a6e3a1)" "󰄬" && yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" -o "$HOME/videos/yt/%(title)s.%(ext)s" "$query" && hyprctl notify 5 3000 "rgb(a6e3a1)" "󰄬") &>/dev/null & ;;
        .mp3) (hyprctl notify 5 2000 "rgb(a6e3a1)" "󰄬" && yt-dlp -x --audio-format mp3 -o "$HOME/music/yt/%(title)s.%(ext)s" "$query" && hyprctl notify 5 3000 "rgb(a6e3a1)" "󰄬") &>/dev/null & ;;
        .dl) (hyprctl notify 5 2000 "rgb(a6e3a1)" "󰄬" && gallery-dl "$query" && hyprctl notify 5 3000 "rgb(a6e3a1)" "󰄬") &>/dev/null & ;;
        .zed)
            if [ -n "$query" ]; then
                zeditor "$HOME/$query" &>/dev/null &
            else
                zeditor "$HOME" &>/dev/null &
            fi
            ;;
        .ins) kitty -e sudo pacman -S --noconfirm "$query" &>/dev/null & ;;
        .play) (pgrep -x mpv | xargs -r kill -9 2>/dev/null; sleep 0.1; /usr/bin/mpv --shuffle --no-video "$HOME/0/music"/**/*) &>/dev/null & ;;
        .manga) (
            MANGA_HISTORY="$HOME/.cache/scripts/manga/random_history.txt"
            mkdir -p "$(dirname "$MANGA_HISTORY")"
            all_manga=$(find "$HOME" -type d \( -path "*/\.*" -o -path "*/node_modules" -o -path "*/.cache" -o -path "*/.local" -o -path "*/.config" \) -prune -o -type f -iname "*.cbz" -print 2>/dev/null)
            [[ -z "$all_manga" ]] && exit 0
            unplayed=$(grep -Fxvf "$MANGA_HISTORY" <<< "$all_manga" 2>/dev/null)
            [[ -z "$unplayed" ]] && : > "$MANGA_HISTORY" && unplayed="$all_manga"
            manga=$(echo "$unplayed" | shuf -n 1)
            echo "$manga" >> "$MANGA_HISTORY"
            zathura "$manga" &>/dev/null &
        ) &>/dev/null & ;;
        .wallpaper|.wp) (
            cache="$HOME/.cache/scripts/wallpapers"
            mkdir -p "$cache"
            wp=$(find "$HOME/0/pictures/wallpapers" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | shuf -n 1)
            [[ -z "$wp" ]] && exit 1
            cp -- "$wp" "$cache/current"
            printf "splash = false\nipc = true\npreload = %s\nwallpaper = ,%s,cover\n" "$cache/current" "$cache/current" > "$cache/hyprpaper.conf"
            pgrep -x hyprpaper >/dev/null || hyprpaper -c "$cache/hyprpaper.conf" &>/dev/null & sleep 0.5
            hyprctl hyprpaper preload "$cache/current" &>/dev/null
            hyprctl hyprpaper wallpaper ",$cache/current,cover" &>/dev/null
            hyprctl hyprpaper unload unused &>/dev/null
            hyprctl notify 5 2200 "rgb(cba6f7)" "󰄬 wallpaper set"
        ) &>/dev/null & ;;
        .wallpaperblur|.wpb) (
            cache="$HOME/.cache/scripts/wallpapers"
            mkdir -p "$cache"
            wp=$(find "$HOME/0/pictures/wallpapers" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | shuf -n 1)
            [[ -z "$wp" ]] && exit 1
            magick "$wp" -scale 1920x1080^ -gravity center -extent 1920x1080 -blur 0x15 -modulate 60 "$cache/current"
            printf "splash = false\nipc = true\npreload = %s\nwallpaper = ,%s,cover\n" "$cache/current" "$cache/current" > "$cache/hyprpaper.conf"
            pgrep -x hyprpaper >/dev/null || hyprpaper -c "$cache/hyprpaper.conf" &>/dev/null & sleep 0.5
            hyprctl hyprpaper preload "$cache/current" &>/dev/null
            hyprctl hyprpaper wallpaper ",$cache/current,cover" &>/dev/null
            hyprctl hyprpaper unload unused &>/dev/null
            hyprctl notify 5 2200 "rgb(cba6f7)" "󰄬 wallpaper set (blur)"
        ) &>/dev/null & ;;
    esac
}

anime_entries='❀  AnimeKai
❀  Miruro
❀  Kuudere
❀  Kaa'
anime_count=$(printf '%s\n' "$anime_entries" | wc -l)

ai_entries='❀  ChatGPT
❀  Claude
❀  DuckAI
❀  Kimi
❀  Grok
❀  Gemini
❀  AI Studio
❀  DeepSeek
❀  Qwen'
ai_count=$(printf '%s\n' "$ai_entries" | wc -l)

web_entries='❀  Reddit
❀  Letterboxd
❀  MyAnimeList
❀  AniList
❀  Privacy Guides
❀  Hacker News
❀  Lobsters
❀  Techmeme
❀  IzzyOnDroid
❀  FDroid
❀  Danbooru
❀  DeepL
❀  Gmail
❀  GitHub
❀  Wikipedia
❀  Proton Mail
❀  Proton Pass
❀  CityWalks
❀  Lofi Cafe'
web_count=$(printf '%s\n' "$web_entries" | wc -l)

streaming_entries='❀  Cineby
❀  67Movies
❀  PopcornMovies
❀  ShuttleTV'
streaming_count=$(printf '%s\n' "$streaming_entries" | wc -l)

tech_entries='❀  HackerNoon
❀  Reuters Tech
❀  WSJ Tech
❀  Android Police
❀  TechCrunch'
tech_count=$(printf '%s\n' "$tech_entries" | wc -l)

favorites_entries='❀  Wallhaven
❀  YouTube
❀  YouTube Music
❀  Last.fm
❀  Pinterest
❀  FMHY
❀  X.com
❀  Extensions
❀  Steam'
favorites_count=$(printf '%s\n' "$favorites_entries" | wc -l)

config_entries='❀  aria2
❀  gallery-dl
❀  kitty
❀  waybar
❀  rofi
❀  hypr
❀  mpv
❀  swayimg
❀  yt-dlp
❀  swaync
❀  zathura
❀  fish'

all_entries=$(printf '%s\n%s\n%s\n%s\n%s\n%s\n%s' "$favorites_entries" "$ai_entries" "$anime_entries" "$tech_entries" "$web_entries" "$streaming_entries" "$config_entries")
all_count=$(printf '%s\n' "$all_entries" | wc -l)

websites_count=$((favorites_count + ai_count + anime_count + tech_count + web_count + streaming_count))
config_count=$(printf '%s\n' "$config_entries" | wc -l)
manga_count=$(wc -l < "$MANGA_CACHE_FILE" 2>/dev/null)
video_count=$(wc -l < "$VIDEO_CACHE_FILE" 2>/dev/null)
image_count=$(wc -l < "$IMAGE_CACHE_FILE" 2>/dev/null)

if [[ -z "$manga_count" ]]; then
    manga_count=$(find "$HOME" -type d \( -path "*/\.*" -o -path "*/node_modules" -o -path "*/.cache" -o -path "*/.local" -o -path "*/.config" \) -prune -o -type f -iname "*.cbz" -print 2>/dev/null | wc -l)
fi
if [[ -z "$video_count" ]]; then
    video_count=$(find "$HOME" -type d \( -path "*/\.*" -o -path "*/node_modules" -o -path "*/.cache" -o -path "*/.local" -o -path "*/.config" \) -prune -o -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" \) -print 2>/dev/null | wc -l)
fi
if [[ -z "$image_count" ]]; then
    image_count=$(find "$HOME" -type d \( -path "*/\.*" -o -path "*/node_modules" -o -path "*/.cache" -o -path "*/.local" -o -path "*/.config" \) -prune -o -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.avif" -o -iname "*.svg" \) -print 2>/dev/null | wc -l)
fi

run_search_all() {
    pkill -x rofi 2>/dev/null
    sleep 0.1

    local all_choice
    all_choice=$(printf '%s\n' "$all_entries" | rofi_menu "❀  All:")
    [[ -z "$all_choice" ]] && exit 0

    case "$all_choice" in
        '.'*)
            handle_bang "$all_choice"
            exit 0
            ;;
        *)
            open_site_choice "$all_choice"
            ;;
    esac
}

run_websites_menu() {
    pkill -x rofi 2>/dev/null
    sleep 0.1

    local ws_choice
    ws_choice=$(printf '❀  Favorites (%s)\n❀  Web (%s)\n❀  Tech (%s)\n❀  AI (%s)\n❀  Anime (%s)\n❀  Streaming (%s)' \
        "$favorites_count" "$web_count" "$tech_count" "$ai_count" "$anime_count" "$streaming_count" \
        | rofi_menu "❀  Websites:" 6)
    [[ -z "$ws_choice" ]] && exit 0

    case "$ws_choice" in
        *"Favorites ("*")")
            local fav_choice
            fav_choice=$(printf '❀  Open All\n%s' "$favorites_entries" | rofi_menu "❀  Favorites:")
            [[ -z "$fav_choice" ]] && exit 0
            if [[ "$fav_choice" == *"Open All" ]]; then
                open_all "${favorites_urls[@]}"
            else
                open_site_choice "$fav_choice"
            fi
            ;;
        *"Web ("*")")
            local web_choice
            web_choice=$(printf '❀  Open All\n%s' "$web_entries" | rofi_menu "❀  Web:")
            [[ -z "$web_choice" ]] && exit 0
            if [[ "$web_choice" == *"Open All" ]]; then
                open_all "${web_urls[@]}"
            else
                open_site_choice "$web_choice"
            fi
            ;;
        *"Tech ("*")")
            local tech_choice
            tech_choice=$(printf '❀  Open All\n%s' "$tech_entries" | rofi_menu "❀  Tech:")
            [[ -z "$tech_choice" ]] && exit 0
            if [[ "$tech_choice" == *"Open All" ]]; then
                open_all "${tech_urls[@]}"
            else
                open_site_choice "$tech_choice"
            fi
            ;;
        *"AI ("*")")
            local ai_choice
            ai_choice=$(printf '❀  Open All\n%s' "$ai_entries" | rofi_menu "❀  AI:")
            [[ -z "$ai_choice" ]] && exit 0
            if [[ "$ai_choice" == *"Open All" ]]; then
                open_all "${ai_urls[@]}"
            else
                open_site_choice "$ai_choice"
            fi
            ;;
        *"Anime ("*")")
            local anime_choice
            anime_choice=$(printf '❀  Open All\n%s' "$anime_entries" | rofi_menu "❀  Anime:")
            [[ -z "$anime_choice" ]] && exit 0
            if [[ "$anime_choice" == *"Open All" ]]; then
                open_all "${anime_urls[@]}"
            else
                open_site_choice "$anime_choice"
            fi
            ;;
        *"Streaming ("*")")
            local streaming_choice
            streaming_choice=$(printf '❀  Open All\n%s' "$streaming_entries" | rofi_menu "❀  Streaming:")
            [[ -z "$streaming_choice" ]] && exit 0
            if [[ "$streaming_choice" == *"Open All" ]]; then
                open_all "${streaming_urls[@]}"
            else
                open_site_choice "$streaming_choice"
            fi
            ;;
    esac
}

run_config_menu() {
    pkill -x rofi 2>/dev/null
    sleep 0.1

    local config_choice
    config_choice=$(printf '󰁯  Backup → dotfiles.zip\n❀  Open All\n%s' "$config_entries" | rofi_menu "❀  Cfg:" 14)
    [[ -z "$config_choice" ]] && exit 0
    if [[ "$config_choice" == *Backup* ]]; then
        cd "$HOME/.config" && zip -rq "$HOME/dotfiles.zip" aria2 gallery-dl kitty waybar rofi hypr mpv swayimg yt-dlp swaync zathura fish \
            && hyprctl notify 5 3000 "rgb(a6e3a1)" "󰁯  Backup saved → ~/dotfiles.zip" \
            || hyprctl notify 3 3000 "rgb(f38ba8)" "󰅗  Backup failed"
        exit 0
    fi
    if [[ "$config_choice" == *"Emoji Picker" ]]; then
        rofi -modi emoji -show emoji -emoji-format '{emoji}' -emoji-mode copy
        exit 0
    fi
    if [[ "$config_choice" == *"Open All" ]]; then
        zeditor "$HOME/.config/aria2" "$HOME/.config/gallery-dl" "$HOME/.config/kitty" "$HOME/.config/waybar" "$HOME/.config/rofi" "$HOME/.config/hypr" "$HOME/.config/mpv" "$HOME/.config/swayimg" "$HOME/.config/yt-dlp" "$HOME/.config/swaync" "$HOME/.config/zathura" "$HOME/.config/fish" &>/dev/null &
        exit 0
    fi
    local cfg
    cfg=$(echo "$config_choice" | sed 's/^❀  //')
    zeditor "$HOME/.config/$cfg" &
}

# ----- manga -----
MANGA_DIR="${HOME}"
MANGA_CACHE_DIR="$HOME/.cache/scripts/manga"
MANGA_CACHE_FILE="$MANGA_CACHE_DIR/cache.txt"
MANGA_CACHE_MTIME="$MANGA_CACHE_DIR/cache-mtime.txt"
MANGA_HISTORY="$MANGA_CACHE_DIR/history.txt"

_manga_find() {
    find "$MANGA_DIR" -type d \( -path "*/\.*" -o -path "*/node_modules" -o -path "*/.cache" -o -path "*/.local" -o -path "*/.config" \) -prune -o -type f -iname "*.cbz" -print 2>/dev/null | sed "s|^$HOME/||"
}

_manga_size() {
    du -h "$1" 2>/dev/null | awk '{print $1}'
}

_manga_pages() {
    zipinfo -1 "$1" 2>/dev/null | grep -iE '\.(jpg|jpeg|png|webp|gif|bmp)$' | wc -l
}

_manga_get_mtime() {
    find "$MANGA_DIR" -type d \( -path "*/\.*" -o -path "*/node_modules" -o -path "*/.cache" -o -path "*/.local" -o -path "*/.config" \) -prune -o -type f -iname "*.cbz" -printf '%T@ %s %p\n' 2>/dev/null | sort | md5sum
}

_manga_build_cache() {
    local tmp
    tmp=$(mktemp)
    mkdir -p "$MANGA_CACHE_DIR"
    while IFS= read -r path; do
        [[ -z "$path" ]] && continue
        local size pages
        size=$(_manga_size "$HOME/$path")
        pages=$(_manga_pages "$HOME/$path")
        printf '%s\t%s\t%s\n' "$path" "$size" "$pages" >> "$tmp"
    done < <(_manga_find)
    mv "$tmp" "$MANGA_CACHE_FILE"
    _manga_get_mtime > "$MANGA_CACHE_MTIME"
}

_manga_refresh_cache() {
    if [[ ! -f "$MANGA_CACHE_FILE" ]] || [[ ! -f "$MANGA_CACHE_MTIME" ]]; then
        _manga_build_cache
        return
    fi
    local current cached
    current=$(_manga_get_mtime)
    cached=$(cat "$MANGA_CACHE_MTIME")
    [[ "$current" != "$cached" ]] && _manga_build_cache
}

_manga_sort() {
    local all hist
    all=$(mktemp)
    hist=$(mktemp)
    cut -f1 "$MANGA_CACHE_FILE" | sort > "$all"
    if [[ -f "$MANGA_HISTORY" ]]; then
        cat "$MANGA_HISTORY" > "$hist"
        grep -Fxv -f "$hist" "$all" | sort
        grep -Fx -f "$all" "$hist"
    else
        cat "$all"
    fi
    rm -f "$all" "$hist"
}

_manga_add_history() {
    mkdir -p "$(dirname "$MANGA_HISTORY")"
    local tmp
    tmp=$(mktemp)
    grep -Fxv "$1" "$MANGA_HISTORY" 2>/dev/null > "$tmp"
    printf '%s\n' "$1" >> "$tmp"
    mv "$tmp" "$MANGA_HISTORY"
}

run_manga_menu() {
    pkill -x rofi 2>/dev/null
    sleep 0.1
    _manga_refresh_cache
    [[ ! -f "$MANGA_CACHE_FILE" ]] && exit 0

    declare -a MANGA_PATHS MANGA_LABELS

    LAST_READ=$(tail -n 1 "$MANGA_HISTORY" 2>/dev/null)
    [[ -n "$LAST_READ" ]] && MANGA_PATHS+=("$LAST_READ") && MANGA_LABELS+=("➜ last")

    while IFS= read -r path; do
        [[ -z "$path" ]] && continue
        local info size pages
        info=$(grep -F "$path" "$MANGA_CACHE_FILE" | head -1)
        [[ -z "$info" ]] && continue
        size=$(printf '%s' "$info" | cut -f2)
        pages=$(printf '%s' "$info" | cut -f3)
        MANGA_PATHS+=("$path")
        MANGA_LABELS+=("$(printf '%-7s %-4s %s' "$size" "$pages" "$path")")
    done < <(_manga_sort)

    [[ ${#MANGA_PATHS[@]} -eq 0 ]] && exit 0

    idx=$(printf '%s\n' "${MANGA_LABELS[@]}" | _manga_rofi_menu "manga")
    [[ -z "$idx" ]] && exit 0

    choice="${MANGA_PATHS[$idx]}"
    [[ -z "$choice" ]] && exit 0

    file="$HOME/$choice"
    [[ -f "$file" ]] || exit 0

    if [[ "${MANGA_LABELS[$idx]}" == "➜ last" ]]; then
        zathura "$file" >/dev/null 2>&1 &
    else
        _manga_add_history "$choice"
        zathura "$file" >/dev/null 2>&1 &
    fi
}

# ----- video -----
VIDEO_DIR="${HOME}"
VIDEO_CACHE_DIR="$HOME/.cache/scripts/video"
VIDEO_CACHE_FILE="$VIDEO_CACHE_DIR/cache.txt"
VIDEO_CACHE_MTIME="$VIDEO_CACHE_DIR/cache-mtime.txt"
VIDEO_HISTORY="$VIDEO_CACHE_DIR/history.txt"
VIDEO_GROUP_BY_FOLDER=true

_video_find() {
    find "$VIDEO_DIR" -type d \( -path "*/\.*" -o -path "*/node_modules" -o -path "*/.cache" -o -path "*/.local" -o -path "*/.config" \) -prune -o -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" \) -print 2>/dev/null | sed "s|^$HOME/||"
}

_video_size() {
    du -h "$1" 2>/dev/null | awk '{print $1}'
}

_video_duration() {
    local dur
    dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1" 2>/dev/null)
    if [[ -n "$dur" ]]; then
        local sec min hour
        sec=${dur%.*}
        min=$((sec / 60))
        hour=$((min / 60))
        sec=$((sec % 60))
        min=$((min % 60))
        printf '%02d:%02d:%02d' "$hour" "$min" "$sec"
    fi
}

_video_get_mtime() {
    find "$VIDEO_DIR" -type d \( -path "*/\.*" -o -path "*/node_modules" -o -path "*/.cache" -o -path "*/.local" -o -path "*/.config" \) -prune -o -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" \) -printf '%T@ %s %p\n' 2>/dev/null | sort | md5sum
}

_video_build_cache() {
    local tmp
    tmp=$(mktemp)
    mkdir -p "$VIDEO_CACHE_DIR"
    while IFS= read -r path; do
        [[ -z "$path" ]] && continue
        local size duration
        size=$(_video_size "$HOME/$path")
        duration=$(_video_duration "$HOME/$path")
        printf '%s\t%s\t%s\n' "$path" "$size" "$duration" >> "$tmp"
    done < <(_video_find)
    mv "$tmp" "$VIDEO_CACHE_FILE"
    _video_get_mtime > "$VIDEO_CACHE_MTIME"
}

_video_refresh_cache() {
    if [[ ! -f "$VIDEO_CACHE_FILE" ]] || [[ ! -f "$VIDEO_CACHE_MTIME" ]]; then
        _video_build_cache
        return
    fi
    local current cached
    current=$(_video_get_mtime)
    cached=$(cat "$VIDEO_CACHE_MTIME")
    [[ "$current" != "$cached" ]] && _video_build_cache
}

_video_sort() {
    cut -f1 "$VIDEO_CACHE_FILE" | sort -V
}

_video_add_history() {
    mkdir -p "$(dirname "$VIDEO_HISTORY")"
    local tmp
    tmp=$(mktemp)
    grep -Fxv "$1" "$VIDEO_HISTORY" 2>/dev/null > "$tmp"
    printf '%s\n' "$1" >> "$tmp"
    mv "$tmp" "$VIDEO_HISTORY"
}

_run_video_menu_flat() {
    declare -a VIDEO_PATHS VIDEO_LABELS

    LAST_WATCHED=$(tail -n 1 "$VIDEO_HISTORY" 2>/dev/null)
    [[ -n "$LAST_WATCHED" ]] && VIDEO_PATHS+=("$LAST_WATCHED") && VIDEO_LABELS+=("➜ last")

    while IFS=$'\t' read -r path size duration; do
        [[ -z "$path" ]] && continue
        [[ "$path" == "$LAST_WATCHED" ]] && continue
        VIDEO_PATHS+=("$path")
        VIDEO_LABELS+=("$(printf '%-7s %-10s %s' "$size" "$duration" "$path")")
    done < "$VIDEO_CACHE_FILE"

    [[ ${#VIDEO_PATHS[@]} -eq 0 ]] && exit 0

    idx=$(printf '%s\n' "${VIDEO_LABELS[@]}" | _manga_rofi_menu "video")
    [[ -z "$idx" ]] && exit 0

    choice="${VIDEO_PATHS[$idx]}"
    [[ -z "$choice" ]] && exit 0

    file="$HOME/$choice"
    [[ -f "$file" ]] || exit 0

    if [[ "${VIDEO_LABELS[$idx]}" == "➜ last" ]]; then
        mpv "$file" >/dev/null 2>&1 &
    else
        _video_add_history "$choice"
        mpv "$file" >/dev/null 2>&1 &
    fi
}

_run_video_menu_by_folder() {
    local root_display
    if [[ "$VIDEO_DIR" == "$HOME" ]]; then
        root_display="~"
    else
        root_display="$VIDEO_DIR"
    fi

    declare -a MENU_ENTRIES MENU_LABELS
    local LAST_WATCHED
    LAST_WATCHED=$(tail -n 1 "$VIDEO_HISTORY" 2>/dev/null)
    if [[ -n "$LAST_WATCHED" ]]; then
        MENU_ENTRIES+=("LAST")
        MENU_LABELS+=("➜ last")
    fi

    MENU_ENTRIES+=("ALL")
    MENU_LABELS+=("󰒓  all")

    while IFS=$'\t' read -r count folder; do
        [[ -z "$folder" ]] && continue
        if [[ "$folder" == "." ]]; then
            MENU_ENTRIES+=(".")
            MENU_LABELS+=("$(printf '(%s)\t%s' "$count" "$root_display")")
        else
            MENU_ENTRIES+=("$folder")
            MENU_LABELS+=("$(printf '(%s)\t%s' "$count" "$folder")")
        fi
    done < <(
        cut -f1 "$VIDEO_CACHE_FILE" | awk '{n=$0; sub(/\/[^\/]+$/,"",n); if (n == $0) n="."; c[n]++} END {for (k in c) print c[k] "\t" k}' \
        | sort -t$'\t' -k1,1rn
    )

    MENU_ENTRIES+=("LONGEST")
    MENU_LABELS+=("")

    [[ ${#MENU_ENTRIES[@]} -eq 0 ]] && exit 0

    local idx
    idx=$(printf '%s\n' "${MENU_LABELS[@]}" | _manga_rofi_menu "video folder")
    [[ -z "$idx" ]] && exit 0

    local selected_entry
    selected_entry="${MENU_ENTRIES[$idx]}"
    [[ -z "$selected_entry" ]] && exit 0

    if [[ "$selected_entry" == "LAST" ]]; then
        local file
        file="$HOME/$LAST_WATCHED"
        [[ -f "$file" ]] || exit 0
        mpv "$file" >/dev/null 2>&1 &
        exit 0
    fi

    if [[ "$selected_entry" == "ALL" ]]; then
        declare -a VIDEO_PATHS VIDEO_LABELS
        while IFS=$'\t' read -r path size duration; do
            [[ -z "$path" ]] && continue
            [[ "$path" == "$LAST_WATCHED" ]] && continue
            VIDEO_PATHS+=("$path")
            VIDEO_LABELS+=("$(printf '%-7s %-10s %s' "$size" "$duration" "$path")")
        done < "$VIDEO_CACHE_FILE"

        [[ ${#VIDEO_PATHS[@]} -eq 0 ]] && exit 0

        idx=$(printf '%s\n' "${VIDEO_LABELS[@]}" | _manga_rofi_menu "all videos")
        [[ -z "$idx" ]] && exit 0

        choice="${VIDEO_PATHS[$idx]}"
        [[ -z "$choice" ]] && exit 0

        file="$HOME/$choice"
        [[ -f "$file" ]] || exit 0

        _video_add_history "$choice"
        mpv "$file" >/dev/null 2>&1 &
        exit 0
    fi

    if [[ "$selected_entry" == "LONGEST" ]]; then
        declare -a VIDEO_PATHS VIDEO_LABELS
        while IFS=$'\t' read -r path size duration; do
            [[ -z "$path" ]] && continue
            [[ "$path" == "$LAST_WATCHED" ]] && continue
            VIDEO_PATHS+=("$path")
            VIDEO_LABELS+=("$(printf '%-7s %-10s %s' "$size" "$duration" "$path")")
        done < <(awk -F'\t' '{split($3,a,":"); secs=a[1]*3600+a[2]*60+a[3]; print secs "\t" $0}' "$VIDEO_CACHE_FILE" | sort -t$'\t' -k1,1nr | cut -f2-)

        [[ ${#VIDEO_PATHS[@]} -eq 0 ]] && exit 0

        idx=$(printf '%s\n' "${VIDEO_LABELS[@]}" | _manga_rofi_menu "longest videos")
        [[ -z "$idx" ]] && exit 0

        choice="${VIDEO_PATHS[$idx]}"
        [[ -z "$choice" ]] && exit 0

        file="$HOME/$choice"
        [[ -f "$file" ]] || exit 0

        _video_add_history "$choice"
        mpv "$file" >/dev/null 2>&1 &
        exit 0
    fi

    local folder_choice
    folder_choice="$selected_entry"

    declare -a VIDEO_PATHS VIDEO_LABELS
    while IFS=$'\t' read -r path size duration; do
        [[ -z "$path" ]] && continue
        [[ "$path" == "$LAST_WATCHED" ]] && continue
        local base
        base="${path##*/}"
        VIDEO_PATHS+=("$path")
        VIDEO_LABELS+=("$(printf '%-7s %-10s %s' "$size" "$duration" "$base")")
    done < <(grep -F "$folder_choice/" "$VIDEO_CACHE_FILE")

    [[ ${#VIDEO_PATHS[@]} -eq 0 ]] && exit 0

    idx=$(printf '%s\n' "${VIDEO_LABELS[@]}" | _manga_rofi_menu "$folder_choice")
    [[ -z "$idx" ]] && exit 0

    choice="${VIDEO_PATHS[$idx]}"
    [[ -z "$choice" ]] && exit 0

    file="$HOME/$choice"
    [[ -f "$file" ]] || exit 0

    _video_add_history "$choice"
    mpv "$file" >/dev/null 2>&1 &
}

run_video_menu() {
    pkill -x rofi 2>/dev/null
    sleep 0.1
    _video_refresh_cache
    [[ ! -f "$VIDEO_CACHE_FILE" ]] && exit 0

    if [[ "$VIDEO_GROUP_BY_FOLDER" == true ]]; then
        _run_video_menu_by_folder
        return
    fi

    _run_video_menu_flat
}

# ----- images -----
IMAGE_DIR="${HOME}"
IMAGE_CACHE_DIR="$HOME/.cache/scripts/image"
IMAGE_CACHE_FILE="$IMAGE_CACHE_DIR/cache.txt"
IMAGE_CACHE_MTIME="$IMAGE_CACHE_DIR/cache-mtime.txt"
IMAGE_HISTORY="$IMAGE_CACHE_DIR/history.txt"

_image_find() {
    fd --type f --hidden --absolute-path \
        --exclude .git --exclude node_modules --exclude .cache --exclude __pycache__ \
        --exclude .venv --exclude venv --exclude target --exclude build --exclude dist \
        --exclude .npm --exclude .cargo --exclude .rustup \
        --exclude .local --exclude .var --exclude .flatpak --exclude .fonts --exclude .icons \
        --exclude BraveSoftware --exclude librewolf --exclude go --exclude .go \
        --exclude thumbnails --exclude thumb --exclude '.thumbs' \
        . "$IMAGE_DIR" 2>/dev/null \
        | grep -iE '\.(jpg|jpeg|png|webp|gif|bmp|avif|svg)$' \
        | sed "s|^$HOME/||"
}

_image_get_mtime() {
    _image_find | md5sum
}

_image_build_cache() {
    local tmp
    tmp=$(mktemp)
    mkdir -p "$IMAGE_CACHE_DIR"
    _image_find > "$tmp"
    mv "$tmp" "$IMAGE_CACHE_FILE"
    _image_get_mtime > "$IMAGE_CACHE_MTIME"
}

_image_refresh_cache() {
    if [[ ! -f "$IMAGE_CACHE_FILE" ]] || [[ ! -f "$IMAGE_CACHE_MTIME" ]]; then
        _image_build_cache
        return
    fi
    local current cached
    current=$(_image_get_mtime)
    cached=$(cat "$IMAGE_CACHE_MTIME")
    [[ "$current" != "$cached" ]] && _image_build_cache
}

_image_open() {
    local file="$1"
    local dir viewer
    dir=$(dirname "$file")

    if command -v swayimg &>/dev/null; then
        viewer="swayimg"
    elif command -v imv &>/dev/null; then
        viewer="imv"
    else
        xdg-open "$file" >/dev/null 2>&1 &
        return
    fi

    # Open all images in the folder so user can swipe,
    # and track the last viewed file via /proc/PID/fd/
    (
        cd "$dir" 2>/dev/null || exit

        local -a images
        while IFS= read -r -d '' img; do
            images+=("$img")
        done < <(find . -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.avif" -o -iname "*.svg" \) -print0 2>/dev/null | sort -zV)

        "${viewer}" "${images[@]}" >/dev/null 2>&1 &
        local pid=$!

        local last="$file"
        while kill -0 "$pid" 2>/dev/null; do
            local current
            current=$(readlink "/proc/${pid}/fd/"* 2>/dev/null | grep -iE '\.(jpg|jpeg|png|webp|gif|bmp|avif|svg)$' | tail -1)
            [[ -n "$current" ]] && last="$current"
            sleep 1
        done

        local rel="${last#$HOME/}"
        if [[ "$rel" != "$last" ]]; then
            _image_add_history "$rel"
        fi
    ) & disown
}

_image_add_history() {
    mkdir -p "$(dirname "$IMAGE_HISTORY")"
    local tmp
    tmp=$(mktemp)
    grep -Fxv "$1" "$IMAGE_HISTORY" 2>/dev/null > "$tmp"
    printf '%s\n' "$1" >> "$tmp"
    mv "$tmp" "$IMAGE_HISTORY"
}

_image_recent() {
    find "$HOME" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.avif" -o -iname "*.svg" \) \
        -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/.cache/*" -not -path "*/.local/*" -not -path "*/.config/*" \
        -printf '%T@\t%p\n' 2>/dev/null \
    | sort -t$'\t' -k1,1nr \
    | cut -f2- \
    | head -n 20
}

_image_open_recent() {
    local dir
    dir=$(mktemp -d /tmp/images-recent.XXXXXX)

    local count=0
    while IFS=$'\t' read -r mtime filepath; do
        [[ -z "$filepath" ]] && continue
        ln -s "$filepath" "$dir/$(printf '%03d' $count)_$(basename "$filepath")" 2>/dev/null
        ((count++))
    done < <(
        find "$HOME" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.avif" -o -iname "*.svg" \) \
            -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/.cache/*" -not -path "*/.local/*" -not -path "*/.config/*" \
            -printf '%T@\t%p\n' 2>/dev/null \
        | sort -t$'\t' -k1,1nr \
        | head -n 20
    )

    [[ $count -eq 0 ]] && rm -rf "$dir" && exit 0

    local first
    first=$(ls -1v "$dir" 2>/dev/null | head -1)

    if command -v swayimg &>/dev/null; then
        swayimg "$dir/$first" >/dev/null 2>&1 &
    elif command -v imv &>/dev/null; then
        imv "$dir/$first" >/dev/null 2>&1 &
    else
        xdg-open "$dir/$first" >/dev/null 2>&1 &
    fi
}

run_image_menu() {
    pkill -x rofi 2>/dev/null
    sleep 0.1
    _image_refresh_cache
    [[ ! -f "$IMAGE_CACHE_FILE" ]] && exit 0

    local root_display="~"

    declare -a MENU_ENTRIES MENU_LABELS
    local LAST_OPENED
    LAST_OPENED=$(tail -n 1 "$IMAGE_HISTORY" 2>/dev/null)
    if [[ -n "$LAST_OPENED" ]]; then
        MENU_ENTRIES+=("LAST")
        MENU_LABELS+=("➜ last")
    fi

    MENU_ENTRIES+=("RECENT")
    MENU_LABELS+=("➜ recent")

    while IFS=$'\t' read -r count folder; do
        [[ -z "$folder" ]] && continue
        if [[ "$folder" == "." ]]; then
            MENU_ENTRIES+=(".")
            MENU_LABELS+=("$(printf '(%s)\t%s' "$count" "$root_display")")
        else
            MENU_ENTRIES+=("$folder")
            MENU_LABELS+=("$(printf '(%s)\t%s' "$count" "$folder")")
        fi
    done < <(
        awk '{n=$0; sub(/\/[^\/]+$/,"",n); if (n == $0) n="."; c[n]++} END {for (k in c) print c[k] "\t" k}' "$IMAGE_CACHE_FILE" \
        | sort -t$'\t' -k1,1rn
    )

    [[ ${#MENU_ENTRIES[@]} -eq 0 ]] && exit 0

    local idx
    idx=$(printf '%s\n' "${MENU_LABELS[@]}" | _manga_rofi_menu "images")
    [[ -z "$idx" ]] && exit 0

    local selected_folder="${MENU_ENTRIES[$idx]}"
    [[ -z "$selected_folder" ]] && exit 0

    if [[ "$selected_folder" == "LAST" ]]; then
        local last_file="$HOME/$LAST_OPENED"
        [[ -f "$last_file" ]] || exit 0
        _image_open "$last_file"
        exit 0
    fi

    if [[ "$selected_folder" == "RECENT" ]]; then
        _image_open_recent
        exit 0
    fi

    declare -a IMAGE_PATHS IMAGE_LABELS
    if [[ "$selected_folder" == "." ]]; then
        while IFS= read -r path; do
            [[ -z "$path" ]] && continue
            IMAGE_PATHS+=("$path")
            IMAGE_LABELS+=("${path##*/}")
        done < <(grep -v '/' "$IMAGE_CACHE_FILE")
    else
        while IFS= read -r path; do
            [[ -z "$path" ]] && continue
            IMAGE_PATHS+=("$path")
            IMAGE_LABELS+=("${path##*/}")
        done < <(grep -F "$selected_folder/" "$IMAGE_CACHE_FILE")
    fi

    [[ ${#IMAGE_PATHS[@]} -eq 0 ]] && exit 0

    idx=$(printf '%s\n' "${IMAGE_LABELS[@]}" | _manga_rofi_menu "$selected_folder")
    [[ -z "$idx" ]] && exit 0

    local choice="${IMAGE_PATHS[$idx]}"
    [[ -z "$choice" ]] && exit 0

    local file="$HOME/$choice"
    [[ -f "$file" ]] || exit 0

    _image_add_history "$choice"
    _image_open "$file"
}

# ----- files -----
FILES_CACHE_DIR="$HOME/.cache/scripts/files"
FILES_CACHE_FILE="$FILES_CACHE_DIR/cache.txt"
FILES_CACHE_MTIME="$FILES_CACHE_DIR/cache-mtime.txt"
FILES_HISTORY="$FILES_CACHE_DIR/history.txt"
FILES_LIMIT=5000

_files_get_mtime() {
    find "$HOME" -maxdepth 2 -type d ! -path "*/.local" ! -path "*/.cache" | xargs stat --format="%Y %n" 2>/dev/null | sort | md5sum
}

_files_build_cache() {
    local tmp
    tmp=$(mktemp)
    mkdir -p "$FILES_CACHE_DIR"

    local fd_args=(
        --type f --hidden --absolute-path
        --exclude .git --exclude node_modules --exclude .cache --exclude __pycache__
        --exclude .venv --exclude venv --exclude target --exclude build --exclude dist
        --exclude .npm --exclude .cargo --exclude .rustup
        --exclude .local --exclude .var --exclude .flatpak --exclude .fonts --exclude .icons
        --exclude BraveSoftware --exclude librewolf --exclude go --exclude .go
    )

    local dir_args=(
        --type d --hidden --absolute-path
        --exclude .git --exclude node_modules --exclude .cache --exclude __pycache__
        --exclude .venv --exclude venv --exclude target --exclude build --exclude dist
        --exclude .npm --exclude .cargo --exclude .rustup
        --exclude .local --exclude .var --exclude .flatpak --exclude .fonts --exclude .icons
        --exclude BraveSoftware --exclude librewolf --exclude go --exclude .go
    )

    fd "${dir_args[@]}" . "$HOME" 2>/dev/null | sed "s|$HOME/||" | head -n $FILES_LIMIT | \
        while IFS= read -r line; do
            printf 'dir\t%s\n' "$line"
        done >> "$tmp"

    fd "${fd_args[@]}" . "$HOME" 2>/dev/null | sed "s|$HOME/||" | head -n $FILES_LIMIT | \
        while IFS= read -r line; do
            printf 'file\t%s\n' "$line"
        done >> "$tmp"

    mv "$tmp" "$FILES_CACHE_FILE"
    _files_get_mtime > "$FILES_CACHE_MTIME"
}

_files_refresh_cache() {
    if [[ ! -f "$FILES_CACHE_FILE" ]] || [[ ! -f "$FILES_CACHE_MTIME" ]]; then
        _files_build_cache
        return
    fi
    local current_mtime
    current_mtime=$(_files_get_mtime)
    local cached_mtime
    cached_mtime=$(cat "$FILES_CACHE_MTIME")
    if [[ "$current_mtime" != "$cached_mtime" ]]; then
        _files_build_cache
    fi
}

_files_get_count() {
    local type="$1"
    awk -F'\t' '$1 == "'"$type"'" {count++} END {print count+0}' "$FILES_CACHE_FILE" 2>/dev/null
}

_files_get_text_count() {
    grep -E $'^file\t.*\.(sh|txt|py|lua|json|js|ts|css|html|conf|md|rs|toml|xml|yaml|yml|ini|c|cpp|h|hpp|go|java|rb|php|sql|fish|log|desktop|service|bash|zsh|vim|nvim)$' "$FILES_CACHE_FILE" | wc -l
}

_files_get_config_count() {
    local dirs=(aria2 gallery-dl kitty rofi swayimg mpv swaync fish yt-dlp zathura hypr waybar)
    local count=0
    for d in "${dirs[@]}"; do
        [[ -d "$HOME/.config/$d" ]] && ((count++))
        if [[ -d "$HOME/.config/$d" ]]; then
            count=$((count + $(find "$HOME/.config/$d" -type f 2>/dev/null | wc -l)))
        fi
    done
    echo "$count"
}

_files_save_history() {
    mkdir -p "$(dirname "$FILES_HISTORY")"
    local tmp
    tmp=$(mktemp)
    grep -Fxv "$1" "$FILES_HISTORY" 2>/dev/null > "$tmp"
    printf '%s\n' "$1" >> "$tmp"
    mv "$tmp" "$FILES_HISTORY"
}

run_files_menu() {
    pkill -x rofi 2>/dev/null
    sleep 0.1
    _files_refresh_cache

    local file_count=$(_files_get_count file)
    local dir_count=$(_files_get_count dir)
    local text_count=$(_files_get_text_count)
    local config_count=$(_files_get_config_count)

    local LAST_READ=$(tail -n 1 "$FILES_HISTORY" 2>/dev/null | grep -v '^$')
    local menu_entries=""
    [[ -n "$LAST_READ" ]] && menu_entries+="➜  last\n"
    menu_entries+="󰉋  All Folders ($dir_count)\n󰈙  All Files ($file_count)\n󰈙  Text Files ($text_count)\n󰒓  Cfg Files ($config_count)\n󰈙  Other Files"

    local chosen=$(printf '%b' "$menu_entries" | _manga_rofi_menu "❀  fd:" 6)
    [ -z "$chosen" ] && exit 0

    local file=""

    if [[ "$chosen" == "➜  last" ]]; then
        file="$LAST_READ"
        local fullpath="$HOME/$file"
        if [ -f "$fullpath" ] || [ -d "$fullpath" ]; then
            if command -v nvim &>/dev/null; then
                nohup nvim "$fullpath" >/dev/null 2>&1 &
            else
                nohup zeditor "$fullpath" >/dev/null 2>&1 &
            fi
        else
            hyprctl notify -1 2000 0 "fontsize:16 󰅙 last not found"
        fi
        exit 0
    fi

    if [[ "$chosen" == *"All Folders"* ]]; then
        file=$(grep $'^dir\t' "$FILES_CACHE_FILE" | cut -f2 | sed 's/^/󰉋  /' | _manga_rofi_menu "󰉋  Folders:")
        file="${file#󰉋  }"

    elif [[ "$chosen" == *"All Files"* ]]; then
        file=$(grep $'^file\t' "$FILES_CACHE_FILE" | cut -f2 | sed 's/^/󰈙  /' | _manga_rofi_menu "󰈙  Files:")
        file="${file#󰈙  }"

    elif [[ "$chosen" == *"Text Files"* ]]; then
        file=$(grep -E $'^file\t.*\.(sh|txt|py|lua|json|js|ts|css|html|conf|md|rs|toml|xml|yaml|yml|ini|c|cpp|h|hpp|go|java|rb|php|sql|fish|log|desktop|service|bash|zsh|vim|nvim)$' "$FILES_CACHE_FILE" | cut -f2 | sed 's/^/󰈙  /' | _manga_rofi_menu "󰈙  Text:")
        file="${file#󰈙  }"

    elif [[ "$chosen" == *"Cfg Files"* ]]; then
        local config_dirs=(aria2 gallery-dl kitty rofi swayimg mpv swaync fish yt-dlp zathura hypr waybar)
        local config_entries="󰒓  Open All\n"
        for d in "${config_dirs[@]}"; do
            if [[ -d "$HOME/.config/$d" ]]; then
                config_entries+="󰉋  $d\n"
                while IFS= read -r f; do
                    local rel=$(echo "$f" | sed "s|$HOME/.config/$d/||")
                    config_entries+="󰈙  $d/$rel\n"
                done < <(find "$HOME/.config/$d" -type f 2>/dev/null | sort)
            fi
        done
        file=$(printf '%b' "$config_entries" | _manga_rofi_menu "󰒓  Cfg:")
        [[ "$file" == "󰒓  Open All" ]] && {
            if command -v nvim &>/dev/null; then
                zeditor "$HOME/.config/aria2" "$HOME/.config/gallery-dl" "$HOME/.config/kitty" "$HOME/.config/rofi" "$HOME/.config/swayimg" "$HOME/.config/mpv" "$HOME/.config/swaync" "$HOME/.config/fish" "$HOME/.config/yt-dlp" "$HOME/.config/zathura" "$HOME/.config/hypr" "$HOME/.config/waybar" &>/dev/null &
            else
                zeditor "$HOME/.config/aria2" "$HOME/.config/gallery-dl" "$HOME/.config/kitty" "$HOME/.config/rofi" "$HOME/.config/swayimg" "$HOME/.config/mpv" "$HOME/.config/swaync" "$HOME/.config/fish" "$HOME/.config/yt-dlp" "$HOME/.config/zathura" "$HOME/.config/hypr" "$HOME/.config/waybar" &>/dev/null &
            fi
            exit 0
        }
        file="${file#󰉋  }"
        file="${file#󰈙  }"
        [[ -n "$file" ]] && file=".config/$file"

    else
        file=$(grep -Ev $'^file\t.*\.(sh|txt|py|lua|json|js|ts|css|html|conf|md|rs|toml|xml|yaml|yml|ini|c|cpp|h|hpp|go|java|rb|php|sql|fish|log|desktop|service|bash|zsh|vim|nvim)$' "$FILES_CACHE_FILE" | cut -f2 | sed 's/^/󰈙  /' | _manga_rofi_menu "󰈙  Other:")
        file="${file#󰈙  }"
    fi

    [ -z "$file" ] && exit 0

    local fullpath="$HOME/$file"

    if [ -d "$fullpath" ]; then
        if command -v nvim &>/dev/null; then
            nohup nvim "$fullpath" >/dev/null 2>&1 &
        else
            nohup zeditor "$fullpath" >/dev/null 2>&1 &
        fi
        _files_save_history "$file"
    elif [ -f "$fullpath" ]; then
        case "$fullpath" in
            *.sh|*.txt|*.py|*.lua|*.json|*.js|*.ts|*.css|*.html|*.conf|*.md|*.rs|*.toml|*.xml|*.yaml|*.yml|*.ini|*.c|*.cpp|*.h|*.hpp|*.go|*.java|*.rb|*.php|*.sql|*.fish|*.desktop|*.service|*.bash|*.zsh|*.vim|*.nvim|*.log)
                nvim "$fullpath" &>/dev/null &
                ;;
            *.cbz|*.cbr|*.pdf)
                zathura "$fullpath" &>/dev/null &
                ;;
            *.mp4|*.mp3|*.mkv|*.webm|*.avi|*.mov|*.flv|*.m4a|*.ogg|*.flac|*.wav|*.aac|*.opus|*.wma)
                mpv "$fullpath" &>/dev/null &
                ;;
            *)
                xdg-open "$fullpath" &>/dev/null &
                ;;
        esac
        _files_save_history "$file"
    else
        hyprctl notify -1 2000 0 "fontsize:16 󰅙 not found"
    fi
}

run_power_menu() {
    case "$(printf '❀  Shutdown\n❀  Reboot\n❀  Logout' | rofi_menu "❀  Power:" 3)" in
        *Shutdown) systemctl poweroff ;;
        *Reboot) systemctl reboot ;;
        *Logout) hyprctl dispatch exit 2>/dev/null || loginctl terminate-user "$USER" ;;
    esac
}

main_menu_items=()
main_menu_items+=('❀  Search All ('"$all_count"')')
main_menu_items+=('❀  Websites ('"$websites_count"')')
main_menu_items+=('❀  Cfg ('"$config_count"')')
[[ "$manga_count" -gt 0 ]] && main_menu_items+=('❀  Mangas ('"$manga_count"')')
[[ "$video_count" -gt 0 ]] && main_menu_items+=('❀  Videos ('"$video_count"')')
[[ "$image_count" -gt 0 ]] && main_menu_items+=('❀  Images ('"$image_count"')')
main_menu_items+=('❀  Files')
main_menu_items+=('❀  Power')
chosen=$(printf '%s\n' "${main_menu_items[@]}" | rofi_menu "❀  tr:" "${#main_menu_items[@]}")
case "$chosen" in
    '.'*)  handle_bang "$chosen" ;;
    *Search*) run_search_all ;;
    *Websites*) run_websites_menu ;;
    *Cfg*) run_config_menu ;;
    *Mangas*) run_manga_menu ;;
    *Videos*) run_video_menu ;;
    *Images*) run_image_menu ;;
    *Files*)  run_files_menu ;;
    *Power*)  run_power_menu ;;
esac
