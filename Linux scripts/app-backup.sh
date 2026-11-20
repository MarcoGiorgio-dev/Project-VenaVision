#!/bin/bash
set -euo pipefail
umask 027

OUT=/var/backups/app
PROJECT=/project_venavision/Project-VenaVision
FLASK=$PROJECT/flasksite
DB=venavision
mkdir -p $OUT
STAMP=$(date +%F_%H%M)

# 1. Database: full dump, readable structure, and roles with their grants
sudo -u postgres pg_dump -Fc $DB > $OUT/${DB}_$STAMP.dump
sudo -u postgres pg_dump --schema-only --no-owner $DB > $OUT/${DB}_schema_$STAMP.sql
sudo -u postgres pg_dumpall --globals-only > $OUT/globals_$STAMP.sql

# 2. Python packages of the app (the venv itself is not backed up)
if [ -x $FLASK/venv/bin/pip ]; then
  $FLASK/venv/bin/pip freeze > $OUT/requirements-freeze_$STAMP.txt
fi

# 3. Owners and modes of the project files (the pull runs without root and cannot keep them)
find /project_venavision -name venv -prune -o -printf '%u:%g %m %p\n' > $OUT/project-perms_$STAMP.txt

# 4. Config and secrets. Only paths that exist are included; the gunicorn unit file is found automatically
CONFIG_PATHS="$FLASK/.env /etc/postgresql/18/main /etc/nginx /etc/letsencrypt"
UNITS=$(grep -rls -e gunicorn -e flasksite /etc/systemd/system 2>/dev/null || true)
LIST=
for p in $CONFIG_PATHS $UNITS; do
  if [ -e $p ]; then LIST="$LIST $p"; fi
done
tar -czf $OUT/config_$STAMP.tar.gz $LIST

# 5. Keep 7 days here; the backup PC keeps the long history
find $OUT -type f -mtime +7 -delete

# 6. Let bkpuser read the results
chgrp -R bkpuser $OUT
chmod -R u=rwX,g=rX,o= $OUT