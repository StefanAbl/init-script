FROM ubuntu:latest
RUN apt-get update && \
    apt-get install -y postfix postfix-ldap openssl sudo bash dnsutils nano telnet less
RUN mkdir -p /config /data &&\
    addgroup --system --gid {{bindUserGID.stdout}} {{bindUser}} &&\
    adduser --system --disabled-password --no-create-home \
      --ingroup {{bindUser}} --firstuid {{bindUserUID.stdout}} --lastuid {{bindUserUID.stdout}} {{bindUser}}

RUN echo "NETWORK_TIMEOUT 3" >> /etc/ldap/ldap.conf &&\
    echo "TIMEOUT 3" >> /etc/ldap/ldap.conf



SHELL ["/bin/bash", "-c"]
VOLUME ["/config", "/data"]
CMD postfix -c /config start-fg
