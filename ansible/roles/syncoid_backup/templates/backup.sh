#!/bin/bash

mail_account="{{syncoid_backup_mail_user}}@{{domain_name}}"
mail_pw="{{syncoid_backup_mail_user_password}}"
mail_dest="{{ipa_admin_user}}@{{domain_name}}"

logfile="/var/log/backup.log"
logtemp="$(mktemp)"
status=0

vols="nextcloud_data share2 docker0 docker1 ProxmoxBackupDir VeeamBackup"
export LC_ALL="en_US.UTF-8"
for d in $vols; do
  syncoid --no-privilege-elevation --sshport 27022 --sshkey /root/.ssh/id_rsa --sendoptions="w" "Volume2/$d" "proxmox@alarmanlage.dynv6.net:backup0/$d" 2>&1 | tee -a "$logtemp"
  s=$?
  status=$((status + s))
  echo "Status $status"
done

{
  date
  cat "$logtemp"
  echo ""
} >>"$logfile"

mail_file="$(mktemp)"
{
  echo "From: Backup System <$mail_account>"
  echo "To: $mail_dest <$mail_dest>"
  echo "Subject: Backup Status $status"
  echo ""
  cat "$logtemp"
  echo ""
  echo ""
  ssh -p 27022 -i /root/.ssh/id_rsa proxmox@alarmanlage.dynv6.net zpool list
  ssh -p 27022 -i /root/.ssh/id_rsa proxmox@alarmanlage.dynv6.net zfs list

  echo "Shuting down remote server"
  ssh -p 27022 -i /root/.ssh/id_rsa proxmox@alarmanlage.dynv6.net dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.PowerOff" boolean:true
} >>"$mail_file"

curl --url 'smtp://mail.stabl.one:587' --ssl-reqd \
  --mail-from "$mail_account" --mail-rcpt "$mail_dest" \
  --upload-file "$mail_file" --user "$mail_account:$mail_pw"

rm "$mail_file"
rm "$logtemp"
