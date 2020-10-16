#!/bin/bash
file="/etc/rspamd/local.d/worker-controller.inc"
dir="/etc/rspamd/local.d/"
mailDomains="{{ mailDomains }}"

if [ -z "$(ls "$dir"| grep done)" ]; then
  pw="$(cat "$file" | grep password)"
  pw=${pw/password = \"/}
  pw=${pw/\";/}
  echo "$pw"
  pw="$(rspamadm pw -p "$pw")"
  echo "password = \"$pw\";" >> "$file"
cat <<EOF >> /var/dcc/dcc_conf
DCCM_LOG_AT=NEVER
DCCM_REJECT_AT=MANY
DCCIFD_ENABLE=on
EOF
  mkdir -p /dkim
  for domain in $mailDomains; do
    dkim_record="$(rspamadm dkim_keygen -k "/dkim/$domain.dkim.key" -b 2048 -s dkim -d "$domain")"
    echo "please add the following dkim record to this domain: $domain"
    echo "$dkim_record"
  done


  touch "$dir/done"
fi


# start dcc with /var/dcc/libexec/dccifd
