#!/bin/bash

logfile=/var/log/watchdog

if [ $(cat $logfile | wc -l)  -ge 10000 ]; then
           mv $logfile $logfile.1
else
           echo "Logfile small enough"
fi

date >> $logfile
echo "Running watchdog" >> $logfile

test_host=`ip r | grep "default" | awk '{ print $3}' | xargs timeout 10 ping -q -w 1 -c 1 | grep "received" | awk '{ print $4 }'`
if [ "$test_host" == "0" ] || [ -z "$test_host" ] ;
then
    service networking restart
    echo "Trying to restart networking" >> $logfile

    sleep 60
    test_host=`ip r | grep "default" | awk '{ print $3}' | xargs timeout 10 ping -q -w 1 -c 1 | grep "received" | awk '{ print $4 }'`
    if [ "$test_host" == "0" ] || [ -z "$test_host" ] ;
    then
        date >> $logfile
        echo "Rebooting" >> $logfile
        /usr/sbin/reboot now
            shutdown --reboot 1 "System rebooting in 1 minute"
        sleep 120
        echo "Uh oh" >> $logfile
    else
        echo "Networking restored" >> $logfile
    fi
else
    echo "Network is reachable"
    echo "Network is reachable" >> $logfile
fi
