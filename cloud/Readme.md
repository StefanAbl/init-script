# Postifx
This will setup a container running postfix with ldap userlookup

# To do
- remove excess packages when done
- Test wihch things in master.cf can be chrooted
- When setting return_attribute = mail in virtual alias maps delivery to outside emails via groups works
- remove sieve or add it don't leave half baked
- why are there vhosts without domain
- removing auth_bind_userdn from ldap.conf.ext makes the pass_filter value active otherwise it is ignored
  - this means that users can no longer log in with only the username but must also specify their email domain
  - if previously configured different users will then see a different mailbox, but new mail is delivered properly
  - userdb in 10-auth.conf could then be configured without %d for domain

## Fix mailrouting
- Config:
  - alias maps
    - query: mail=%s
    - result: mail
  - mailbox maps
    - query: (&(memberOf=cn=mail,cn=groups,...)(mail=%s))
    - result: uid
  - 10-auth.conf
    - userdb: home=/data/vhosts/%n
  - ldap.conf.ext
    - pass_filter: (&(uid=%n)(mail=%u)(memberOf=cn=mail,cn=groups,...))
- Result:
  - groups not working
  - external mails working
  - sign in with full mail
  - local mailboxes working
  

## Setup
### Difficulties when setting up replica
1. The master needs to be able to directly access the replica and not just vice versa
  1. Create a docker macvlan network, which attaches the containers directly to the network `sudo docker network create -d macvlan --subnet=10.13.10.0/24 --gateway=10.13.10.1 -o parent=tap0 macvlan`
### Setupt DNS
1. Setup mail.domain in dynv6
2. Setup reverse DNS
3. Make sure correct timezone is set
4. Add Dkim record and dmarc record to domain see https://www.c0ffee.net/blog/mail-server-guide/ for more
5. add replica to ipaservers host-group

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

#### Freeipa ports list
- "127.0.0.1:53:53/udp"
- "127.0.0.1:53:53"
- "127.0.0.1:80:80"
- "127.0.0.1:443:443"
- "127.0.0.1:389:389"
- "127.0.0.1:636:636"
- "127.0.0.1:88:88"
- "127.0.0.1:464:464"
- "127.0.0.1:88:88/udp"
- "127.0.0.1:464:464/udp"
- "127.0.0.1:123:123/udp"
