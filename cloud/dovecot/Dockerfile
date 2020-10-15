FROM alpine:latest
RUN apk add --no-cache shadow
RUN mkdir -p /config /etc/ipa /data &&\
    /usr/sbin/groupadd --system --gid 102 postfix &&\
    /usr/sbin/useradd -u 101 -g 102 -M --system postfix &&\
    /usr/sbin/groupadd --system --gid {{bindUserGID.stdout}} {{bindUser}} &&\
    /usr/sbin/useradd -u {{bindUserUID.stdout}} -g {{bindUserGID.stdout}} -M --system {{bindUser}}
RUN apk add --no-cache dovecot dovecot-ldap dovecot-pigeonhole-plugin dovecot-pigeonhole-plugin-ldap dovecot-lmtpd bash nano

VOLUME ["/config", "/data", "/etc/ipa"]
EXPOSE 993
CMD dovecot -F -c /config/dovecot.conf
