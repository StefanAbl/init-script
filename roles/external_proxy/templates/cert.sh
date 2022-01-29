#!/bin/bash
#This file is managed by Ansible do not modify by hand
{% for i in acmesh.env_vars %}
export {{i.name}}='{{i.value}}'
{% endfor %}

/root/acme.sh/acme.sh  --register-account  -m {{ipa_admin_user}}@{{domain_name}} --server zerossl

{% for server in servers %}

/root/acme.sh/acme.sh --issue -d {{server.name}} --server zerossl \
{% if server.verification == "dns" %} --dns {{server.api}} {% else %} --nginx /etc/nginx/sites/{{server.name}} {% endif %} \
 --key-file /etc/letsencrypt/live/{{server.name}}/key.pem \
  --ca-file /etc/letsencrypt/live/{{server.name}}/ca.pem \
  --cert-file /etc/letsencrypt/live/{{server.name}}/cert.pem \
  --fullchain-file /etc/letsencrypt/live/{{server.name}}/fullchain.pem \
  || if [ $? -eq 2 ]; then echo "Domain not due for renewal"; else exit 1 ;fi
{% endfor %}

# service nginx restart
