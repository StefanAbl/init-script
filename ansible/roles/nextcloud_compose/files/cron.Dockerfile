FROM nextcloud:27.1.3-fpm

RUN set -ex; \
    echo '0 */2 * * * php -f /var/www/html/occ preview:pre-generate' >> /var/spool/cron/crontabs/www-data
