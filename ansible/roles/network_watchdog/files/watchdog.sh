#!/bin/bash

test_host=`ip r | grep "default" | awk '{ print $3}' | xargs ping -q -w 1 -c 1 | grep "received" | awk '{ print $4 }'`
if [ "$test_host" == "0" ] || [ -z "$test_host" ] ;
then
    service networking restart

    sleep 60
    test_host=`ip r | grep "default" | awk '{ print $3}' | xargs ping -q -w 1 -c 1 | grep "received" | awk '{ print $4 }'`
    if [ "$test_host" == "0" ] || [ -z "$test_host" ] ;
    then
            reboot
    fi
else
    echo "Network is reachable"
fi
