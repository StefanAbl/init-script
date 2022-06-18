FROM nginx
RUN openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj '/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com' -keyout /ffsync.key -out /ffsync.crt
COPY nginx.conf /etc/nginx/nginx.conf
