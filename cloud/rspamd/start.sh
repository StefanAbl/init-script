#!/bin/bash
file="/etc/rspamd/local.d/worker-controller.inc"
dir="/etc/rspamd/local.d/"
mailDomains="{{ mailDomains }}"

echo config files
ls $dir

if [ -z "$(ls "$dir"| grep done)" ]; then
  pw="$(cat "$file" | grep password)"
  pw=${pw/password = \"/}
  pw=${pw/\";/}
  echo "rspamd password: '$pw'"
  pw="$(rspamadm pw -p "$pw")"
  cat "$file" | grep -v password > "$file"
  echo "password = \"$pw\";" >> "$file"
cat <<EOF >> /var/dcc/dcc_conf
DCCM_LOG_AT=NEVER
DCCM_REJECT_AT=MANY
DCCIFD_ENABLE=on
EOF
  mkdir -p /dkim
  for domain in $mailDomains; do
    if [ ! -f "/dkim/$domain.dkim.key" ]; then
      dkim_record="$(rspamadm dkim_keygen -k "/dkim/$domain.dkim.key" -b 2048 -s dkim -d "$domain")"

      chown rspamd:rspamd /dkim/$domain.dkim.key
      echo "$dkim_record" >> "/dkim/addto$domain"
      echo "please add the following dkim record to this domain: $domain"
      echo "$dkim_record"
    fi
  done
  chown rspamd:rspamd /dkim

  touch "$dir/done"
fi

rspamd -u rspamd -g rspamd -f

# start dcc with /var/dcc/libexec/dccifd
