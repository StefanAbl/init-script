#!/bin/bash
ncDir="/Volume2/nextcloud_data/"
unrecoveredFilesDB="/root/.ncZeroSizeFiles"

mail_account="{{syncoid_backup_mail_user}}@{{domain_name}}"
mail_pw="{{syncoid_backup_mail_user_password}}"
mail_dest="{{ipa_admin_user}}@{{domain_name}}"

recoveredFiles="$(mktemp)"
unrecoveredFiles="$(mktemp)"

findCorruptFiles () {
    local user="$1"
    # echo "find $ncDir$user/files/ -size 0 | grep -v node_modules | sed 's|'"$ncDir"'||g'"
    corruptFiles="$(find $ncDir$user/files/ -size 0 | grep -v node_modules | grep -v .nomedia| sed 's|'"$ncDir"'||g')"

    echo "$corruptFiles" | while read -r file; do
        echo ""
        echo "Looking at file $file"
        for snapshot in $(ls -r $ncDir.zfs/snapshot | grep autosnap); do
            snapshot=$ncDir.zfs/snapshot/$snapshot
            echo "Testing file $snapshot/$file"
            if [ -s "$snapshot/$file" ]; then
                echo "Potential recovery option found!"
                echo "$snapshot/$file" >> "$recoveredFiles"
                break
            fi

        done
        echo "Checking if file has been previously found"
        if ! grep -q "$user/files/$file" "$unrecoveredFilesDB"; then
            echo "The following new unrecoverable file has been found"
            echo "$user/files/$file" >> "$unrecoveredFiles"
            echo "$user/files/$file" >> "$unrecoveredFilesDB"
        fi
    done
}

reporting () {

    if test -s "$recoveredFiles"  || test -s "$unrecoveredFiles" ; then

        mail_file="$(mktemp)"
        {
        echo "From: Nextcloud Reports <$mail_account>"
        echo "To: $mail_dest <$mail_dest>"
        echo "Subject: Nextcloud corrupt files"
        echo ""
        echo "The following files may potentially be recovered:"
        cat "$recoveredFiles"
        echo ""
        echo ""
        echo "The following new potentially corrupted files have been discovered:"
        cat "$unrecoveredFiles"
        } >>"$mail_file"

        cat "$mail_file"

        curl --url 'smtp://mail.stabl.one:587' --ssl-reqd \
        --mail-from "$mail_account" --mail-rcpt "$mail_dest" \
        --upload-file "$mail_file" --user "$mail_account:$mail_pw"
        rm "$mail_file"

    fi
}


findCorruptFiles maria
findCorruptFiles stefan
echo ""
reporting
# echo "$corruptFiles"

rm "$recoveredFiles"
rm "$unrecoveredFiles"
