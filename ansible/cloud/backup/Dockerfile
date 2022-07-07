FROM alpine
RUN mkdir -p /key /data &&\
    apk add --no-cache openssh-keygen openssh-client

VOLUME [ "/data", "/key" ]

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD /start.sh

# use two commands, one for keygen and one for running the cronjob
