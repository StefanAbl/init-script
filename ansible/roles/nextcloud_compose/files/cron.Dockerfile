FROM nextcloud:28.0.7-fpm

RUN set -ex; \
    echo '0 */2 * * * php -f /var/www/html/occ preview:pre-generate' >> /var/spool/cron/crontabs/www-data
