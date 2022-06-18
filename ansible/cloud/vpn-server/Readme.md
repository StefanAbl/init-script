# Setup OpenVPN in a LXC container

Needs privileged container or VM to create tun interface

## packages
openvpn brdige-utils easy-rsa

## Setup certificates


## Bridge routing
ip route del 10.13.2.0/24 dev eth0 proto kernel scope link src 10.13.2.107
ip route add 10.13.2.0/24 dev br0 proto kernel scope link src 10.13.2.107
