FROM nextcloud:26.0.9-fpm

RUN set -ex; \
    echo '0 */2 * * * php -f /var/www/html/occ preview:pre-generate' >> /var/spool/cron/crontabs/www-data
