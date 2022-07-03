#!/bin/bash

#################################
# Set up Ethernet bridge on Linux
# Requires: bridge-utils
#################################

# Define Bridge Interface
br="br0"

# Define list of TAP interfaces to be bridged,
# for example tap="tap0 tap1 tap2".
tap="tap0"

# Define physical ethernet interface to be bridged
# with TAP interface(s) above.
eth="eth0"
eth_ip="10.13.10.100"
eth_netmask="255.255.255.0"
eth_broadcast="10.13.10.255"
eth_gateway="10.13.10.1"


systemctl stop openvpn@server
for t in $tap; do
openvpn --mktun --dev $t
done

brctl addbr $br
brctl addif $br $eth

for t in $tap; do
brctl addif $br $t
done

for t in $tap; do
ifconfig $t 0.0.0.0 promisc up
done

ifconfig $eth 0.0.0.0 promisc up

ifconfig $br $eth_ip netmask $eth_netmask broadcast $eth_broadcast
ip route add default via $eth_gateway
systemctl start openvpn@server
