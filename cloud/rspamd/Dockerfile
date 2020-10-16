FROM alpine:latest
COPY start.sh /
RUN apk add --no-cache bash dcc dcc-dccifd rspamd RUN apk add --no-cache rspamd rspamd-controller rspamd-proxy rspamd-fuzzy ca-certificates curl &&\
chmod +x /start.sh

EXPOSE 11334
CMD /start.sh
VOLUME ["/etc/rspamd/local.d"]
