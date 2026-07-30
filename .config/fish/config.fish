if status is-interactive
end

set -g fish_greeting

# ── functions
for f in ~/.config/fish/functions/*.fish
    source $f
end

# ── prompt
set -g fish_transient_prompt 1

function fish_prompt
    if set -q argv[1]
        echo -n "❯ "
        return
    end

    set -l last_status $status

    set -l status_color f5c2e7
    if test $last_status -ne 0
        set status_color ff6b8a
    end

    set -l pwd (string replace -r "^$HOME/" "" "$PWD")
    string match -q "$HOME" "$PWD"; and set pwd "~"

    set -l DIM (set_color 7c5cbf)
    set -l DIR (set_color c8b8de --bold)
    set -l N (set_color normal)

    echo -s "$DIM●$N $DIR$pwd$N"
    echo -n -s "$DIM╰─$N " (set_color $status_color --bold) "❯ " (set_color normal)
end

alias pwd="command pwd | wl-copy; and command pwd"
alias myip="echo -n 'IP:  '; ip -4 -o a show | awk '/inet / && !/127.0.0.1/{print \$4}' | cut -d/ -f1 | head -1; echo -n 'DNS: '; awk '/^nameserver/{print \$2}' /etc/resolv.conf | head -1"
alias f="rg -l . | fzf"

# ─────────── zoxide ───────────
if command -q zoxide
    zoxide init fish | source
end
# ─────────── fzf ───────────
if command -q fzf
    fzf --fish | source
end

# ── player
function player -d ""
    python3 (find ~ -name "player.py" -not -path "*/.cache/*" -not -path "*/.local/*" -not -path "*/.venv/*" 2>/dev/null | head -1) $argv
end

# ── mkcd
function mkcd -d "mkdir and cd"
    mkdir -p $argv[1]; and cd $argv[1]
end

# ── rd
function rd -d "remove current dir"
    clear
    set -l p (pwd)

    if test "$p" = /; or test "$p" = /home; or test "$p" = $HOME
        set_color red; echo "refuse to remove protected dir: $p"; set_color normal
        return 1
    end

    cd ..
    read -l -P "rm -rf $p ? [y/N] " confirm
    test "$confirm" = y; and rm -rf $p; and clear; and echo "deleted $p"
end

# ─────────── chmod ───────────
function chmod -d "chmod +x on .sh files"
    if test (count $argv) -eq 0
        set -l sh (find (pwd) -maxdepth 1 -name "*.sh" -type f)
        if test (count $sh) -gt 0
            command chmod +x $sh
            for f in $sh
                set_color --dim
                echo -n "  → "
                set_color normal
                echo (basename $f)
            end
        end
    else
        command chmod -R $argv (pwd)
    end
end

# ── empty
function empty -d "delete empty dirs"
    set -l n (find (pwd) -type d -empty 2>/dev/null | wc -l)
    find (pwd) -type d -empty -delete 2>/dev/null
    echo "$n folders deleted"
end

# ─────────── zips-extract ───────────
function zips -d "compression menu"
    set -l P (set_color cba6f7)
    set -l G (set_color a6e3a1)
    set -l Y (set_color yellow)
    set -l B (set_color 89b4fa)
    set -l D (set_color brblack)
    set -l N (set_color normal)

    echo "$D󰗄 Zip$N"
    echo "  [1] $Y󰛫 zip into one$N"
    echo "  [2] $P󰉓 zip separately$N"
    echo "  [3] $B󰃨 extract here$N"
    read -P "→ " choice

    switch $choice
        case 1
            clear
            set -l current (basename "$PWD")
            set -l subdirs (find . -maxdepth 1 -mindepth 1 -type d 2>/dev/null)

            if test -z "$subdirs"
                echo "zips: no subdirectories to zip here"
                return 1
            end

            set -l archive "$current.zip"
            rm -f "$archive"
            __zips_progress "$archive" $subdirs

        case 2
            clear
            set -l subdirs (find . -maxdepth 1 -mindepth 1 -type d 2>/dev/null)

            if test -z "$subdirs"
                echo "zips: no subdirectories to zip here"
                return 1
            end

            for dir in $subdirs
                set -l name (basename "$dir")
                set -l archive "$name.zip"
                rm -f "$archive"
                __zips_progress "$archive" "$dir"
            end

        case 3
            clear
            extract

        case 0 ''
            return 0
    end
end

# ─── extract
function extract -d "unzip all archives"
    set -l archives (find . -maxdepth 1 -type f -name "*.zip" 2>/dev/null)

    if test -z "$archives"
        echo "extract: no zip files found here"
        return 1
    end

    for z in $archives
        set -l name (basename "$z" .zip)
        mkdir -p "$name"
        unzip -qo "$z" -d "$name"
        set -l files (find "$name" -type f | wc -l | string trim)
        echo "extracted: $z -> $name/ ($files files)"
    end
end

function __zips_progress -d "zip with progress"
    if test (count $argv) -lt 2
        return 1
    end

    set -l archive $argv[1]
    set -l targets $argv[2..-1]
    set -l cols (tput cols)
    set -l max (math $cols - 4)

    zip -r "$archive" $targets | while read -l line
        set -l item (string match -rg 'adding: (.+) \(' -- "$line")
        if test -n "$item"
            set -l truncated (string sub -l $max -- "$item")
            printf "\r\033[K󰗄 %s" "$truncated"
        end
    end

    if test $pipestatus[1] -eq 0
        printf "\r\033[K"
        set -l size (du -h "$archive" | cut -f1)
        echo "󰄬 $archive ($size)"
    else
        printf "\r\033[K"
        echo "󰅙"
        return 1
    end
end

# ── venv
function py; test -z "$VIRTUAL_ENV"; and venv; python3 (test -n "$argv"; and echo $argv; or echo main.py); end
function venv -d "toggle python venv"
    set -l green (set_color green)
    set -l red (set_color red)
    set -l reset (set_color normal)
    set -l env "$HOME/.venv"
    if test -n "$VIRTUAL_ENV"
        deactivate
        clear
        echo -s $red "󰄬 venv off" $reset
    else
        if not test -d "$env"
            python3 -m venv "$env"
        end
        source "$env/bin/activate.fish"
        if test -f requirements.txt
            echo -s $green "  installing requirements.txt..." $reset
            pip install -q -r requirements.txt
        end
        clear
        echo -s $green "󰄬 venv on" $reset
    end
end
