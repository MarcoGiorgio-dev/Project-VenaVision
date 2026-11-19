#!/bin/bash
set -euo pipefail
umask 027

OUT=/var/backups/app
mkdir -p $OUT
STAMP=$(date +%F_%H%M)

# 1. Database (custom format, compressed) and roles
sudo -u postgres pg_dump -Fc appdb > $OUT/appdb_$STAMP.dump
sudo -u postgres pg_dumpall --globals-only > $OUT/globals_$STAMP.sql

# 2. Ownership and permissions of the web files (rsync as a normal user cannot keep owners)
find /var/www -printf '%u:%g %m %p\n' > $OUT/www-perms_$STAMP.txt

# 3. Web server and application config (adjust the paths to your setup)
tar -czf $OUT/config_$STAMP.tar.gz /etc/nginx /etc/myapp

# 4. Keep 7 days here; fw01 keeps the long history
find $OUT -type f -mtime +7 -delete

# 5. Let bkpuser read the results
chgrp -R bkpuser $OUT
chmod -R u=rwX,g=rX,o= $OUT