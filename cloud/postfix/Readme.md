# Postifx
This will setup a container running postfix with ldap userlookup

# To do
- remove excess packages when done
- Test wihch things in master.cf can be chrotted

## Setup
### Setupt DNS
1. Setup mail.domain in dynv6
2. Setup reverse DNS

## Linode with full disk encryption
Follow [this guide](https://www.linode.com/docs/tools-reference/custom-kernels-distros/install-a-custom-distribution-on-a-linode/)

Use this command to download ubuntu server:
`curl https://releases.ubuntu.com/20.04.1/ubuntu-20.04.1-live-server-amd64.iso | dd of=/dev/sda`

## Design
### Directories
- /var/docker directory for all docker volumes
- /var/docker/postfix/config configuration directory for postfix
- var/docker/mail
- var/docker/mail/ssl directory for ssl certificates and dhparams
- var/docker/mail

## Issues
make sure docker container can resolve MX entries
Disable chroot in master.cf
Debugging postfix https://access.redhat.com/solutions/70539
## Test
### Test ufw really blocks ports
### Test postfix
telnet localhost 25
ehlo test.thorn.dynv6.net
mail from: <stefan@test.thorn.dynv6.net>
rcpt to: <stefan@test.thorn.dynv6.net>
data
Subject: My first mail on Postfix

Hi,
Are you there?
regards,
Admin
.
