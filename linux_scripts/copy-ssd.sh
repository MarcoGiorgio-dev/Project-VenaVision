#!/bin/bash
set -euo pipefail

SRC=/srv/backup/server1
DEST=/mnt/ssdbackup/server1

fail() { logger -p user.err -t copy-ssd "$1"; echo "ERROR: $1"; exit 1; }

mountpoint -q /srv/backup || fail 'internal backup disk not mounted'
mountpoint -q /mnt/ssdbackup || fail 'SSD not mounted'

# Never mirror an empty or broken source over the SSD copy
[ -d $SRC/latest ] || fail 'no snapshot on the internal disk yet'

# Do not overlap a running pull
exec 9>/srv/backup/.lock
flock -n 9 || fail 'a pull is still running'

mkdir -p $DEST
rsync -aH --delete $SRC/ $DEST/
sync
echo "$(date '+%F %T') copy to SSD done"