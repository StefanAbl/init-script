#!/bin/sh

log="/var/log/openvpn-script.log"
echo "deleting default route" >> $log
ip route del default >> $log 2>&1
echo "Route net gateway $route_net_gateway" >> $log
echo "Adding default route to $route_vpn_gateway with /0 mask..." >> $log
ip route add default via $route_vpn_gateway >> $log 2>&1

echo "Removing /1 routes..." >> $log
ip route del 0.0.0.0/1 via $route_vpn_gateway >> $log 2>&1
ip route del 128.0.0.0/1 via $route_vpn_gateway >> $log 2>&1
ip route add default via $route_vpn_gateway >> $log 2>&1
resolvectl dns tun0 10.9.0.1
exit 0
