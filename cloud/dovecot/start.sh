#!/usr/bin/env bash
rm /run/dovecot/master.pid
while true
do
  dovecot -F -c /config/dovecot.conf &
  inotifywait -e create -e modify /data/ssl/fullchain.pem
  dovecot stop
done
