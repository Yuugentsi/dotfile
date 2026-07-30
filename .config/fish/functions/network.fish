# network | network: wifi or dns"
# wifi | network manager
# ─────────── network ───────────
function network -d "Network: WiFi or DNS"
    set -l PURPLE (set_color cba6f7)
    set -l DIM (set_color brblack)
    set -l RESET (set_color normal)

    echo "$PURPLE󰛳 Network$RESET"
    echo "$DIM────────────────────────────$RESET"
    echo "  [1] 󰤨 WiFi"
    echo "  [2] 󰉋 DNS"
    echo "$DIM  [0] 󰜺 exit$RESET"
    echo ""
    read -P "→ choice: " choice

    switch $choice
        case 1
            wifi
        case 2
            dns
        case '*'
            echo "󰜺 cancelled"
    end
end
# ─────────── DNS ───────────
function dns --description "Change DNS easily"
    if not command -v nmcli >/dev/null 2>&1
        echo "nmcli not found"
        return 1
    end

    set -l CONN (nmcli -t -f NAME,DEVICE connection show --active | head -1 | cut -d: -f1)
    if test -z "$CONN"
        echo "No active connection found"
        return 1
    end

    set -l P (set_color cba6f7)
    set -l G (set_color a6e3a1)
    set -l Y (set_color f9e2af)
    set -l R (set_color f38ba8)
    set -l D (set_color brblack)
    set -l N (set_color normal)

    set -l names automatic cloudflare google quad9 adguard opendns mullvad
    set -l labels "󰑐  Automatic" "󰀄  Cloudflare" "󰊶  Google" "󰁴  Quad9" "󰁪  AdGuard" "󰁂  OpenDNS" "󰀘  Mullvad"
    set -l servers "" "1.1.1.1 1.0.0.1" "8.8.8.8 8.8.4.4" "9.9.9.9" "94.140.14.14 94.140.15.15" "208.67.222.222 208.67.220.220" "194.242.2.2 194.242.2.3"

    set -l current (nmcli -g ipv4.dns connection show "$CONN" | string trim | string replace -a ',' ' ')
    set -l active_idx 0
    for i in (seq 1 (count $servers))
        if test "$current" = "$servers[$i]"
            set active_idx $i
            break
        end
    end

    set -l active_name "Unknown"
    if test "$active_idx" -ge 1
        set active_name (string replace -r '^\S+\s+' '' -- "$labels[$active_idx]")
    end

    clear
    echo ""
    for i in (seq 1 (count $labels))
        if test "$i" = "$active_idx"
            echo "  [$i] $G$labels[$i]$N  $G●$N"
        else
            echo "  [$i] $labels[$i]$N"
        end
    end
    echo ""

    set -l choice ""
    if test -n "$argv[1]"
        set choice (string lower "$argv[1]")
        switch "$choice"
            case auto dhcp automatic; set choice 1
            case cf cloudflare; set choice 2
            case gg google; set choice 3
            case q9 quad9; set choice 4
            case ag adguard; set choice 5
            case od opendns; set choice 6
            case mv mullvad; set choice 7
            case '*'; set choice ""
        end
    else
        read -P "→ " choice
    end

    if test "$choice" = 0 -o "$choice" = ""
        return 0
    end

    if not string match -qr '^\d+$' -- "$choice"
        or test "$choice" -lt 1
        or test "$choice" -gt (count $names)
        echo "$R󰅙 invalid$N"
        return 1
    end

    set -l name $names[$choice]
    set -l dns $servers[$choice]

    if test "$name" = automatic
        nmcli con mod "$CONN" ipv4.dns "" ipv4.ignore-auto-dns no
    else
        nmcli con mod "$CONN" ipv4.dns "$dns" ipv4.ignore-auto-dns yes
    end
    nmcli con up "$CONN" >/dev/null 2>&1

    if test $status -eq 0
        echo ""
        echo "$G󰄬  DNS set to $name$N"
        echo "$D   $dns$N"
    else
        echo ""
        echo "$R󰅙  Failed to set DNS$N"
        return 1
    end
end
# ─────────── wifi ───────────
function wifi --description 'Network Manager'
    if not command -v nmcli >/dev/null 2>&1
        echo "󰅙 nmcli not found. Installing..."
        sudo pacman -S --noconfirm networkmanager
    end

    while true
        clear
        set -l PURPLE (set_color cba6f7)
        set -l GREEN (set_color green)
        set -l RED (set_color red)
        set -l DIM (set_color brblack)
        set -l RESET (set_color normal)

        set -l ssid (nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
        set -l ip (ip -4 addr show | grep -oP 'inet \K[\d.]+' | grep -v '127.0.0.1' | head -1)
        set -l dns (grep '^nameserver' /etc/resolv.conf | grep -v '^nameserver fe80' | awk '{print $2}' | command tr '\n' ' ')
        set -l wifi_dev (nmcli -t -f device,type dev | grep wifi | cut -d: -f1 | head -1)

        echo ""
        echo "$PURPLE󰤨 WiFi$RESET"
        echo "$DIM────────────────────────────$RESET"

        if test -n "$ssid"
            set -l freq (nmcli -t -f active,chan dev wifi | grep '^yes' | cut -d: -f2)
            if test -n "$freq"
                if test $freq -le 14
                    set -l band "2.4GHz"
                else
                    set -l band "5GHz"
                end
            else
                set -l band ""
            end

            set -l ping_ms ""
            set -l gw (ip route | grep default | awk '{print $3}' | head -1)
            if test -n "$gw"
                set -l raw_ping (ping -c 1 -W 1 $gw 2>/dev/null | grep -oP 'time=\K[\d.]+')
                if test -n "$raw_ping"
                    set ping_ms " 󰓅 "$raw_ping"ms"
                end
            end

            echo "$GREEN󰄬 $ssid$RESET  $DIM$ip  $band$ping_ms$RESET"
        else
            echo "$RED󰤭 not connected$RESET"
        end

        echo "$DIM󰉋 $dns$RESET"
        echo ""

        set -l networks (nmcli -t -f ssid,signal,security,chan dev wifi list 2>/dev/null | grep -v '^:' | sort -t: -k2 -rn | awk -F: '!seen[$1]++ && $1!=""')

        if test (count $networks) -eq 0
            echo "󰅙 no networks found"
            echo ""
            read -P "→ press enter to retry, 0 to exit: " choice
            if test "$choice" = "0"
                return 0
            end
            continue
        end

        set -l i 1
        set -l ssids
        for net in $networks
            set -l name (echo $net | cut -d: -f1)
            set -l signal (echo $net | cut -d: -f2)
            set -l security (echo $net | cut -d: -f3)
            set -l chan (echo $net | cut -d: -f4)

            if test $signal -ge 75
                set -l bar "▂▄▆█"
            else if test $signal -ge 50
                set -l bar "▂▄▆ "
            else if test $signal -ge 25
                set -l bar "▂▄  "
            else
                set -l bar "▂   "
            end

            if test -z "$security" -o "$security" = "--"
                set -l lock ""
            else
                set -l lock "󰌾 "
            end

            if test -n "$chan" -a "$chan" -le 14 2>/dev/null
                set -l band "2.4G"
            else
                set -l band "5G  "
            end

            if test "$name" = "$ssid"
                printf "$GREEN  [%d] %-30s %s %s $DIM%s$GREEN %s$RESET\n" $i "$name" "$bar" "$lock" "$band" ""
            else
                printf "  [%d] %-30s $DIM%s %s %s$RESET\n" $i "$name" "$bar" "$lock" "$band"
            end

            set ssids $ssids "$name"
            set i (math $i + 1)
        end

        echo ""
        echo "$DIM  [d] disconnect  [r] refresh  [p] passwords  [f] forget all  [0] exit$RESET"
        echo ""
        read -P "→ choice: " choice

        switch $choice
            case 0 ''
                return 0
            case d
                if test -n "$ssid"
                    nmcli dev disconnect $wifi_dev >/dev/null 2>&1
                    echo "× disconnected"
                    sleep 1
                else
                    echo "! not connected"
                    sleep 1
                end
            case r
                nmcli dev wifi rescan 2>/dev/null
            case p
                set -l saved_wifi (nmcli -t -f NAME,TYPE con show 2>/dev/null | grep '802-11-wireless' | cut -d: -f1)
                if test (count $saved_wifi) -eq 0
                    echo "! no saved networks"
                else
                    echo ""
                    for net in $saved_wifi
                        set -l pass (nmcli -s -t -f 802-11-wireless-security.psk con show "$net" 2>/dev/null | cut -d: -f2-)
                        if test -n "$pass"
                            echo "  󰌾 $net: $pass"
                        else
                            echo "  $DIM$net$RESET"
                        end
                    end
                    echo ""
                end
                echo "$DIM  press enter to continue$RESET"
                read cont
            case f
                set -l saved_wifi (nmcli -t -f NAME,TYPE con show 2>/dev/null | grep '802-11-wireless' | cut -d: -f1)
                if test (count $saved_wifi) -eq 0
                    echo "! no saved networks"
                else
                    read -P "󰗜 forget all (count $saved_wifi)? [y/N]: " confirm
                    if string match -qi 'y*' $confirm
                        for net in $saved_wifi
                            nmcli con delete "$net" >/dev/null 2>&1
                        end
                        echo "$RED󰗜 all saved networks forgotten$RESET"
                    else
                        echo "󰜺 cancelled"
                    end
                end
                sleep 1
            case '*'
                if string match -qr '^\d+$' $choice; and test $choice -ge 1 -a $choice -le (count $ssids)
                    set -l target $ssids[$choice]
                    if test "$target" = "$ssid"
                        echo "󰄬 already connected to $target"
                        sleep 1
                        continue
                    end

                    set -l saved (nmcli -t -f name con show 2>/dev/null | grep -Fx "$target")
                    if test -n "$saved"
                        echo "󰤨 connecting to $target..."
                        nmcli con up "$target" >/dev/null 2>&1
                    else
                        read -sP "󰌾 password for $target: " pass
                        echo ""
                        echo "󰤨 connecting to $target..."
                        nmcli dev wifi connect "$target" password "$pass" >/dev/null 2>&1
                    end

                    if test $status -eq 0
                        echo "$GREEN󰄬 connected to $target$RESET"
                    else
                        echo "$RED󰅙 failed to connect$RESET"
                    end
                    sleep 1
                else
                    echo "! invalid option"
                    sleep 0.8
                end
        end
    end
end
