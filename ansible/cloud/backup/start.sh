#!/bin/sh
key="/key/rsa"
user="svc_mail"
host="mail.stabl.one"
base="/var/docker/mail"
dir="{attachments,vhosts}"

if ! test -f "$FILE"; then
    echo "Key not found in $key. Creating it now"
    ssh-keygen -b 2048 -t rsa -f $key -q -N ""
fi
echo "Key is present in $key not recreating it"

# Setup a cron schedule
crontab -l | { cat; echo "00    00       *       *       *       scp -i $key -oStrictHostKeyChecking=no -r $user@$host:$base/$dir /data"; } | crontab -


crond -f
