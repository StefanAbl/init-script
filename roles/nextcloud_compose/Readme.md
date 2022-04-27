# Nextcloud with Docker Compose

This role sets up Nextcloud with Docker compose

# Migration

Create Backup of webroot with `sudo tar -cf webroot.tar -C /var/www/nextcloud/ .` where `var/www/nextcloud` is the path to the webroot and the file in the data dir.

Create a datbase dump with `mysqldump --single-transaction -h localhost --all-databases -uroot -p"$MARIADB_ROOT_PASSWORD" > dump.sql` 

# TODO

- Get ipa certificate into nextcloud container for secure ldap
  - Maybe mount hosts /etc/ssl/certs/ca-certificates.crt read-only on same path in container