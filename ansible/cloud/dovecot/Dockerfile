FROM alpine:3.23
RUN apk add --no-cache shadow
RUN mkdir -p /config /etc/ipa /data &&\
    /usr/sbin/groupadd --system --gid {{postfixGID.stdout}} postfix &&\
    /usr/sbin/useradd -u {{postfixUID.stdout}} -g {{postfixGID.stdout}} -M --system postfix &&\
    /usr/sbin/groupadd --system --gid {{bindUserGID.stdout}} {{mailserver_bindUser}} &&\
    /usr/sbin/useradd -u {{bindUserUID.stdout}} -g {{bindUserGID.stdout}} -M --system {{mailserver_bindUser}}
RUN apk add --no-cache dovecot dovecot-ldap dovecot-pigeonhole-plugin dovecot-pigeonhole-plugin-ldap dovecot-lmtpd bash nano inotify-tools
COPY start.sh /start.sh
VOLUME ["/config", "/data", "/etc/ipa"]
EXPOSE 993
CMD bash -l /start.sh
