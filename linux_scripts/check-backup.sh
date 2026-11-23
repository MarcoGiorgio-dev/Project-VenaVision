#!/bin/bash
set -euo pipefail

BASE=/srv/backup
SSD=/mnt/ssdbackup
LATEST=$BASE/server1/latest
USE_SSD=1             # set to 0 if the SSD is not installed
MAX_AGE_MIN=1560      # internal copy: 26 hours
SSD_MAX_AGE_H=30      # SSD copy: use 200 for a weekly copy
MAX_USED=85           # percent full

fail() { logger -p user.err -t backup-check "$1"; echo "FAIL: $1"; exit 1; }

mountpoint -q $BASE || fail 'internal backup disk not mounted'
[ -d $LATEST ] || fail 'no snapshot exists yet'

AGE=$(( ( $(date +%s) - $(stat -L -c %Y $LATEST) ) / 60 ))
[ $AGE -le $MAX_AGE_MIN ] || fail "latest snapshot is $AGE minutes old"

ls $LATEST/app/venavision_*.dump > /dev/null 2>&1 || fail 'newest snapshot has no database dump'

USED=$(df --output=pcent $BASE | tail -n 1 | tr -dc '0-9')
[ $USED -lt $MAX_USED ] || fail "internal backup disk is $USED percent full"

AGE2=0
USED2=0
if [ $USE_SSD -eq 1 ]; then
  mountpoint -q $SSD || fail 'SSD is not mounted'
  [ -d $SSD/server1/latest ] || fail 'SSD has no copy yet'
  AGE2=$(( ( $(date +%s) - $(stat -L -c %Y $SSD/server1/latest) ) / 3600 ))
  [ $AGE2 -le $SSD_MAX_AGE_H ] || fail "SSD copy is $AGE2 hours old"
  USED2=$(df --output=pcent $SSD | tail -n 1 | tr -dc '0-9')
  [ $USED2 -lt $MAX_USED ] || fail "SSD is $USED2 percent full"
fi

echo "OK: snapshot $AGE minutes old, SSD copy $AGE2 hours old, disks $USED and $USED2 percent used"