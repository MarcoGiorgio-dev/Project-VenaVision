#!/bin/bash
set -euo pipefail

SRC=bkpuser@192.168.1.10
BASE=/srv/backup
DEST=$BASE/server1
LOG=$BASE/pull-backup.log
KEEP=30

# Never write to the root disk by accident
mountpoint -q $BASE || { echo 'ERROR: backup disk is not mounted' >&2; exit 1; }

exec >> $LOG 2>&1
echo "=== $(date '+%F %T') start ==="

# Only one run at a time
exec 9>$BASE/.lock
flock -n 9 || { echo 'ERROR: another run is still active'; exit 1; }

STAMP=$(date +%F_%H%M)
NEW=$DEST/$STAMP
LAST=$DEST/latest
[ -d $LAST ] || LAST=
SSH='ssh -o BatchMode=yes -o ConnectTimeout=15'

# rsync code 24 means files vanished during the copy, which is harmless
run_rsync() {
  local rc=0
  rsync "$@" || rc=$?
  if [ $rc -ne 0 ] && [ $rc -ne 24 ]; then
    echo "ERROR: rsync failed with code $rc"
    exit $rc
  fi
}

mkdir -p $DEST
rm -rf $DEST/*.partial
mkdir -p $NEW.partial/app $NEW.partial/project

run_rsync -a --delete -e "$SSH" ${LAST:+--link-dest=$LAST/app} $SRC:/var/backups/app/ $NEW.partial/app/
run_rsync -a --delete --exclude=venv --exclude=__pycache__ --exclude='*.pyc' --exclude=.env -e "$SSH" ${LAST:+--link-dest=$LAST/project} $SRC:/project_venavision/ $NEW.partial/project/


# Only a complete snapshot gets its final name; the link is relative so it also works on the SSD
mv $NEW.partial $NEW
ln -sfn $STAMP $DEST/latest

# Keep the newest $KEEP snapshots
ls -1d $DEST/20* | grep -v partial | head -n -$KEEP | xargs -r rm -rf || true

echo "=== $(date '+%F %T') done: $STAMP ==="