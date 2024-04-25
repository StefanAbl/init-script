FROM ubuntu:noble-20240423
RUN apt-get update && \
    apt-get install -y postfix postfix-ldap openssl sudo bash dnsutils nano telnet less inotify-tools
RUN mkdir -p /config /data &&\
    addgroup --system --gid {{bindUserGID.stdout}} {{mailserver_bindUser}} &&\
    adduser --system --disabled-password --no-create-home \
      --ingroup {{mailserver_bindUser}} --firstuid {{bindUserUID.stdout}} --lastuid {{bindUserUID.stdout}} {{mailserver_bindUser}}

RUN echo "NETWORK_TIMEOUT 3" >> /etc/ldap/ldap.conf &&\
    echo "TIMEOUT 3" >> /etc/ldap/ldap.conf

COPY start.sh /start.sh

SHELL ["/bin/bash", "-c"]
VOLUME ["/config", "/data"]
CMD bash -l /start.sh
