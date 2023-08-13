#!/bin/bash

# Retries a command on failure.
# $1 - the max number of attempts
# $2... - the command to run

retry() {
    local -r -i max_attempts="$1"; shift
    local -i attempt_num=1
    until "$@"
    do
        if ((attempt_num==max_attempts))
        then
            echo "Attempt $attempt_num failed and there are no more attempts left!"
            return 1
        else
            echo "Attempt $attempt_num failed! Trying again in $attempt_num seconds..."
            sleep $((attempt_num++))
        fi
    done
}

mail_account="{{syncoid_backup_mail_user}}@{{domain_name}}"
mail_pw="{{syncoid_backup_mail_user_password}}"
mail_dest="{{ipa_admin_user}}@{{domain_name}}"

logfile="/var/log/backup.log"
logtemp="$(mktemp)"
status=0

vols="nextcloud_data share2 docker0 docker1 ProxmoxBackupDir VeeamBackup minio"
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

   sleep 5m
  if [[ $status == 0 ]]; then
    echo "Shuting down remote server"
    retry 5 ssh -p 27022 -i /root/.ssh/id_rsa proxmox@alarmanlage.dynv6.net dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.PowerOff" boolean:true
    sleep 5m
    if ssh -o ConnectTimeout=10 -p 27022 -i /root/.ssh/id_rsa proxmox@alarmanlage.dynv6.net /bin/true ; then
      echo "Shutdown failed trying again in 10m"
      sleep 10m
      ssh -p 27022 -i /root/.ssh/id_rsa proxmox@alarmanlage.dynv6.net dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.PowerOff" boolean:true
    else
      echo "Shutdown successful"
    fi
  else
    echo "Backup was not successfull not shutting down remote server"
  fi
} >>"$mail_file"

curl --url 'smtp://mail.stabl.one:587' --ssl-reqd \
  --mail-from "$mail_account" --mail-rcpt "$mail_dest" \
  --upload-file "$mail_file" --user "$mail_account:$mail_pw"

rm "$mail_file"
rm "$logtemp"
