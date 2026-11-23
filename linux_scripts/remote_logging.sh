#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="/etc/logs"
KEEP_DAYS=14
TODAY=$(date +%F_%H-%M)

MINIPC_HOST="gruppe4@192.168.1.10"
FLASK_SERVICE="flasksite"

LAPTOP_FILES=("/var/log/syslog" "/var/log/auth.log" "/var/log/ufw.log")
MINIPC_FILES=("/var/log/syslog" "/var/log/auth.log" "/var/log/nginx" "/var/log/postgresql")

write_log () {
    echo "$(date '+%F %T') $*" | tee -a "$LOG_DIR/collect_logs.log"
}

collect_local () {
    local dest="$LOG_DIR/$(hostname)/$TODAY"
    mkdir -p "$dest"
    local path
    for path in "${LAPTOP_FILES[@]}"; do
        if cp -r "$path" "$dest/"; then
            write_log "OK   local:$path"
        else
            write_log "FAIL local:$path"
        fi
    done
}

collect_remote () {
    local name=$1
    local host=$2
    shift 2
    local dest="$LOG_DIR/$name/$TODAY"
    local path
    mkdir -p "$dest"
    for path in "$@"; do
        if rsync -a --timeout=20 -e "ssh -o BatchMode=yes -o ConnectTimeout=10" "$host:$path" "$dest/"; then
            write_log "OK   $name:$path"
        else
            write_log "FAIL $name:$path"
        fi
    done
}

collect_journal () {
    local name=$1
    local host=$2
    local service=$3
    local dest="$LOG_DIR/$name/$TODAY"
    mkdir -p "$dest"
    if ssh -o BatchMode=yes -o ConnectTimeout=10 "$host" "journalctl -u $service --since '24 hours ago' --no-pager" > "$dest/$service.log"; then
        write_log "OK   $name:journal:$service"
    else
        write_log "FAIL $name:journal:$service"
    fi
}

delete_old () {
    find "$LOG_DIR" -mindepth 2 -maxdepth 2 -type d -mtime +"$KEEP_DAYS" -exec rm -rf {} +
    write_log "Deleted logs older than $KEEP_DAYS days."
}

mkdir -p "$LOG_DIR"
chmod 700 "$LOG_DIR"

write_log "Log collection initiated"
collect_local
collect_remote "minipc" "$MINIPC_HOST" "${MINIPC_FILES[@]}" 
collect_journal "minipc" "$MINIPC_HOST" "$FLASK_SERVICE"
delete_old

write_log "Log collection completed"