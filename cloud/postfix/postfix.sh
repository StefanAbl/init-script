#!/bin/bash
# needs vars: ldapHost, bindUser, bindPW, mailDomains
ldapHost="{{ldapHost}}"
baseDN="${ldapHost#*.}"
baseDN="dc=${baseDN//\./,dc=}"
echo "$baseDN"

cat <<\EOF > /{{docker_dir}}/postfix/config/main.cf

EOF
echo "create the local mail spool"
mkdir /var/mail/local
chown root:mail /var/mail/local
chmod 775 /var/mail/local

echo "create the dhparams"
test -f "/etc/ssl/dh512.pem" || openssl dhparam -out /etc/ssl/dh512.pem 512
test -f "/etc/ssl/dh2048.pem" || openssl dhparam -out /etc/ssl/dh2048.pem 2048
chmod 644 /etc/ssl/dh{512,2048}.pem


cat <<EOF > /{{docker_dir}}/postfix/config/master.cf

EOF


echo "setup mailboxes (mail addresses) this server will accept mail for"
cat <<EOF > /{{docker_dir}}/postfix/config/ldap-virtual-mailbox-maps.cf

EOF

#Make sure this file is only readable by postfix user
# chown postfix:postfix /{{docker_dir}}/postfix/config/ldap-virtual-mailbox-maps.cf
# chmod 700 /{{docker_dir}}/postfix/config/ldap-virtual-mailbox-maps.cf


echo "Setup virtual alias maps"
cat <<EOF > /{{docker_dir}}/postfix/config/ldap-virtual-alias-maps.cf
server_host = {{ ldapHost }}
search_base = cn=users,cn=accounts,$baseDN
query_filter = (mail=%s)
result_attribute = uid
bind = yes
bind_dn = uid={{ bindUser }},cn=users,cn=accounts,$baseDN
bind_pw = {{ bindPw }}
start_tls = yes
version = 3
EOF
