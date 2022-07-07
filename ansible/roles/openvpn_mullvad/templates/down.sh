#!/bin/bash
/usr/sbin/ip route add default via 10.13.2.1 dev {{local_interface}} proto static
