#!/usr/bin/env bash
while true
do
  postfix -c /config start-fg &
  inotifywait -e create -e modify /data/ssl/fullchain.pem
  postfix stop
done
