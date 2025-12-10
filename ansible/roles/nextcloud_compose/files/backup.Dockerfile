FROM mariadb:12.1

RUN apt-get update; \
    apt-get install -y --no-install-recommends busybox-static; \
    mkdir -p /var/spool/cron/crontabs; \
    echo '0 4 * * * mysqldump --single-transaction -h db -u owncloud -p$(cat /run/secrets/nextcloud_db_user_pass) owncloud > /data/dbBackup.sql' > /var/spool/cron/crontabs/www-data; \
    echo '30 4 * * * tar -cf /data/webroot.tar -C /var/www/nextcloud/ .' >> /var/spool/cron/crontabs/www-data; \
    \
    echo '#!/bin/sh \nset -eu \nexec busybox crond -f -l 7 -L /dev/stdout' > /cron.sh;\
    chmod +x /cron.sh
