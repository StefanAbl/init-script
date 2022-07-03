# Nextcloud with Docker Compose

This role sets up Nextcloud with Docker compose.

# Migration

Make sure the version of the Docker image which should be used is the same as the version of Nextcloud you are currently running, unless you want to upgrade.

Create Backup of webroot with `sudo tar -cf webroot.tar -C /var/www/nextcloud/ .` where `var/www/nextcloud` is the path to the webroot and the file in the data dir.

Create a datbase dump with `mysqldump --single-transaction -h localhost --all-databases -uroot -p"$MARIADB_ROOT_PASSWORD" > dump.sql` 

# TODO

- Get ipa certificate into nextcloud container for secure ldap
  - Maybe mount hosts /etc/ssl/certs/ca-certificates.crt read-only on same path in container

docker exec --user www-data -it compose-app-1 php occ ldap:set-config s01 turnOffCertCheck 1