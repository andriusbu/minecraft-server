#!/bin/sh

SYSTEMD_PATH="${HOME}/.config/systemd/user"

# Color codes
RED='\033[0;31m'    # Turn on red color
GREEN='\033[0;32m'  # Turn on green color
YELLO='\033[0;33m'  # Turn on green color
BOLD='\033[1m'      # Turn on bold
NC='\033[0m'        # No Color

# Standard messages
OK="${GREEN}[OK]${NC}"
UPDATED="${YELLO}[UPDATED]${NC}"
DONE="${YELLO}[DONE]${NC}"
ERROR="${RED}[ERROR]${NC}"

generate_config() {
    echo CONFIG
}

show_help() {
    echo HELP
}


FILES_MINECRAFT_SERVICE="$(cat <<-EOF
[Unit]
Description=Minecraft Server
Wants=network-online.target
After=network-online.target
RequiresMountsFor=%t/containers

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
TimeoutStartSec=300
TimeoutStopSec=300
ExecStartPre=/bin/rm -f %t/%n.ctr-id
ExecStart=/usr/bin/podman run --cidfile=%t/%n.ctr-id --cgroups=no-conmon --log-driver=journald --label "io.containers.autoupdate=registry" --rm --sdnotify=conmon --replace -d --name minecraft -p 25565:25565 -p 19132:19132/udp -v mc-work:/opt/minecraft/work -e TZ="Europe/Vilnius" -e MC_XMS=2G -e MC_XMX=2G -e MC_SERVER_NAME="Debeselis MC" ghcr.io/andriusbu/minecraft-server:latest
ExecStop=/usr/bin/podman stop --ignore --cidfile=%t/%n.ctr-id
ExecStopPost=/usr/bin/podman rm -f --ignore --cidfile=%t/%n.ctr-id
Type=notify
NotifyAccess=all

[Install]
WantedBy=default.target
EOF
)"

FILES_PODMAN_AUTO_UPDATE_SERVICE="$(cat <<-EOF
[Unit]
Description=Podman auto-update service
Documentation=man:podman-auto-update(1)
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/podman auto-update
ExecStartPost=/usr/bin/podman image prune -f

[Install]
WantedBy=default.target
EOF
)"

FILES_PODMAN_AUTO_UPDATE_TIMER="$(cat <<-EOF
[Unit]
Description=Podman auto-update timer

[Timer]
OnCalendar=02:00:00 UTC
RandomizedDelaySec=600
Persistent=false

[Install]
WantedBy=timers.target
EOF
)"


print_result() {
    printf "%-50s $2\n" "$1" 
}

check_command() {
    if [ ! -x "$(command -v $2)" ]; then
        print_result "$1" $ERROR
        exit 1
    else
        print_result "$1" $OK
    fi
}

check_folder() {
    if [ ! -d "$2" ]; then
        mkdir -p "$2"
        print_result "$1" $UPDATED
    else
        print_result "$1" $OK
    fi
}

check_systemd_file() {
    if [ -f $3 ]; then
        echo "$2" | diff -q $3 - > /dev/null
        if [ $? -eq 0 ]; then
            print_result "$1" $OK
            return
        fi
    fi
    echo "$2" > $3
    print_result "$1" $UPDATED
    SYSTEMD_UPDATED=1
}

install() {
    check_command "PACKAGE: podman" "podman" 

    check_folder "SYSTEMD: directory" "${SYSTEMD_PATH}"

    SYSTEMD_UPDATED=0
    check_systemd_file "SYSTEMD: Minecraft Server service" "${FILES_MINECRAFT_SERVICE}" "${SYSTEMD_PATH}/minecraft.service"
    check_systemd_file "SYSTEMD: podman auto-update service" "${FILES_PODMAN_AUTO_UPDATE_SERVICE}" "${SYSTEMD_PATH}/podman-auto-update.service"
    check_systemd_file "SYSTEMD: podman auto-update timer" "${FILES_PODMAN_AUTO_UPDATE_TIMER}" "${SYSTEMD_PATH}/podman-auto-update.timer"

    if [ "${SYSTEMD_UPDATED}" -eq "1" ]; then
        systemctl --user daemon-reload
        print_result "SYSTEMD: Reloading systemd" $DONE
    fi
}

case "$1" in
    generate)
        generate_config
        exit 0
        ;;
    help)
        show_help
        exit 0
        ;;
esac

install
