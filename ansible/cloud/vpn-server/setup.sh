#!/bin/bash

#set -e
interface_name="eth0"
local_ip="$(ip -4 addr show dev "$interface_name" | grep inet | sed 's/\/.*//g' | tr -d 'inet ')"
local_ip="10.13.2.107"
public_address="thorn.dynv6.net"
local_netmask="255.255.255.0"
local_broadcast="${local_ip%.*}.255"
local_gateway="${local_ip%.*}.1"

echo "Interface $interface_name ip $local_ip broadcast $local_broadcast gateway $local_gateway"

apt update && apt install -y openvpn bridge-utils easy-rsa ipcalc vim net-tools

cat > /etc/systemd/system/openvpn-tun.service <<EOF
[Unit]
Description=Create /dev/net/tun special device for mod_tun/OpenVPN
Documentation=https://turnkeylinux.org/openvpn https://github.com/turnkeylinux/tracker/issues/1011
DefaultDependencies=no
ConditionPathExists=!/dev/net/tun
ConditionVirtualization=container

Before=network-pre.target
Wants=network-pre.target local-fs.target
After=local-fs.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/bin/mkdir -p /dev/net
ExecStart=/bin/mknod /dev/net/tun c 10 200
ExecStartPost=/bin/chmod 666 /dev/net/tun

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable openvpn-tun.service
systemctl start openvpn-tun.service


EASY_RSA=/etc/openvpn/easy-rsa
SERVER_CFG=/etc/openvpn/server.conf
SERVER_CCD=/etc/openvpn/server.ccd
SERVER_LOG=/var/log/openvpn/server.log
SERVER_IPP=/var/lib/openvpn/server.ipp
KEY_DIR="$EASY_RSA/keys"

mkdir -p $EASY_RSA
ln -s /usr/share/easy-rsa/* $EASY_RSA
set -e #exit on error



KEY_ORG="${KEY_ORG:-stabl.one}"
KEY_OU="${KEY_OU:-cloudVPN}"
KEY_NAME="${KEY_NAME:-openvpn}"
KEY_COUNTRY="${KEY_COUNTRY:-DE}"
KEY_PROVINCE="${KEY_PROVINCE:-BW}"
KEY_CITY="${KEY_CITY:-KA}"
KEY_SIZE="${KEY_SIZE:-2048}"
KEY_EXPIRE="${KEY_EXPIRE:-3650}"
CA_EXPIRE="${CA_EXPIRE:-3650}"
key_email="${key_email:-admin@example.com}"


export EASYRSA_PKI="$EASY_RSA/keys"
export EASYRSA_CERT_EXPIRE="$KEY_EXPIRE"
export EASYRSA_DIGEST="sha256"
export EASYRSA_KEY_SIZE=$KEY_SIZE
export EASYRSA_DN=cn_only
export EASYRSA_REQ_CN="must-be-unique"
export EASYRSA_REQ_COUNTRY="$KEY_COUNTRY"
export EASYRSA_REQ_ORG="$KEY_ORG"
export EASYRSA_REQ_OU="$KEY_OU"
export EASYRSA_REQ_NAME="$KEY_NAME"
export EASYRSA_REQ_COUNTRY="$KEY_COUNTRY"
export EASYRSA_REQ_PROVINCE="$KEY_PROVINCE"
export EASYRSA_REQ_CITY="$KEY_CITY"
export EASYRSA_REQ_EMAIL="$key_email"
export EASYRSA_CRL_DAYS="$CA_EXPIRE"
EASYRSA_NS_SUPPORT="yes"

# remove any files from a previous run to ensure inithook is idempotent
if test -f "$SERVER_CFG" && test -e "$SERVER_CCD" ; then
  echo "Certificates have aleardy been created"
  echo "Skipping"
else
  rm -fr "$EASY_RSA/keys/"* "$SERVER_CFG" "$SERVER_CCD"


  KEY_CONFIG="$EASY_RSA/openssl-easyrsa.cnf"
  OPENSSL="$(which openssl)"
  mkdir -p $KEY_DIR

  # generate easy-rsa vars file
  cat > $EASY_RSA/vars <<EOF
  set_var EASY_RSA "$EASY_RSA/easyrsa"
  set_var OPENSSL "$(which openssl)"
  set_var EASYRSA_PKI "$EASYRSA_PKI"
  set_var EASYRSA_KEY_SIZE $KEY_SIZE
  set_var EASYRSA_REQ_ORG "$KEY_ORG"
  set_var EASYRSA_REQ_EMAIL "$key_email"
  set_var EASYRSA_REQ_OU "$KEY_OU"
  set_var EASYRSA_REQ_COUNTRY "$KEY_COUNTRY"
  set_var EASYRSA_REQ_PROVINCE "$KEY_PROVINCE"
  set_var EASYRSA_REQ_CITY "$KEY_CITY"
  set_var EASYRSA_REQ_CN "$EASYRSA_REQ_CN"
  set_var EASYRSA_DIGEST "$EASYRSA_DIGEST"
  set_var EASYRSA_NS_SUPPORT "$EASYRSA_NS_SUPPORT"
  set_var EASYRSA_CRL_DAYS "$CA_EXPIRE"
  set_var EASYRSA_ALGO "rsa"
EOF

  # cleanup any prior configurations and initialize
  echo "yes" | $EASY_RSA/easyrsa clean-all
  rm -f $SERVER_IPP
  mkdir -p $(dirname $SERVER_IPP)
  mkdir -p $(dirname $SERVER_LOG)
  mkdir -p $SERVER_CCD

  # generate ca and server keys/certs
  export KEY_CN=server
  echo "yes" | $EASY_RSA/easyrsa init-pki
  $EASY_RSA/easyrsa gen-dh
  echo "$EASYRSA_REQ_CN\n" | $EASY_RSA/easyrsa build-ca nopass
  echo "server" | $EASY_RSA/easyrsa gen-req server nopass
  echo "yes" | $EASY_RSA/easyrsa sign-req server server
  openvpn --genkey --secret $KEY_DIR/ta.key

  # setup crl jail with empty crl
  mkdir -p $KEY_DIR/crl.jail/etc/openvpn/
  export KEY_OU=""
  export KEY_CN=""
  export KEY_NAME=""
  $OPENSSL ca -gencrl -config "$KEY_CONFIG" -out "$KEY_DIR/crl.jail/etc/openvpn/crl.pem"
  chown nobody:nogroup $KEY_DIR/crl.jail/etc/openvpn/crl.pem
  chmod +r $KEY_DIR/crl.jail/etc/openvpn/crl.pem

  mkdir -p $KEY_DIR/crl.jail/etc/openvpn
  mkdir -p $KEY_DIR/crl.jail/tmp

  mv $SERVER_CCD $KEY_DIR/crl.jail/etc/openvpn/
  ln -sf $KEY_DIR/crl.jail/etc/openvpn/server.ccd $SERVER_CCD
fi


cat > $SERVER_CFG <<EOF
# PUBLIC_ADDRESS: $public_address (used by openvpn-addclient)
port 1194
proto udp
dev tap
cipher AES-256-CBC
auth SHA256
keepalive 10 120
persist-key
persist-tun
user nobody
group nogroup
chroot $KEY_DIR/crl.jail
crl-verify /etc/openvpn/crl.pem
ca $KEY_DIR/ca.crt
dh $KEY_DIR/dh.pem
tls-auth $KEY_DIR/ta.key 0
key $KEY_DIR/private/server.key
cert $KEY_DIR/issued/server.crt
ifconfig-pool-persist $SERVER_IPP
client-config-dir $SERVER_CCD
status $SERVER_LOG
verb 4
server-bridge $local_gateway 255.255.255.0 ${local_ip%.*}.200 ${local_ip%.*}.254
EOF

cat > /etc/openvpn/start.sh <<EOF
#!/bin/bash
# Define Bridge Interface
br="br0"

# Define list of TAP interfaces to be bridged,
# for example tap="tap0 tap1 tap2".
tap="tap0"

# Define physical ethernet interface to be bridged
# with TAP interface(s) above.
eth="$interface_name"
eth_ip="$local_ip"
eth_netmask="$local_netmask"
eth_broadcast="$local_broadcast"
eth_gateway="$local_gateway"

systemctl stop openvpn@server
for t in \$tap; do
openvpn --mktun --dev \$t
done

brctl addbr \$br
brctl addif \$br \$eth

for t in \$tap; do
brctl addif \$br \$t
done

for t in \$tap; do
ifconfig \$t 0.0.0.0 promisc up
done

ifconfig \$eth 0.0.0.0 promisc up

ifconfig \$br \$eth_ip netmask \$eth_netmask broadcast \$eth_broadcast
ip route add default via \$eth_gateway
systemctl start openvpn@server
EOF

echo '@reboot  root  bash /etc/openvpn/start.sh' >> /etc/crontab

if ! ip addr show dev br0 ; then
  #Brdige interface does not exist yet
   bash /etc/openvpn/start.sh
fi
