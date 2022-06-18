# Jellyfin Server Custom

Installs Jellyfin Media Server on the host. Also perform some custom configuration steps

## Variables
```yaml
ipa_server: ipa.domain
ipa_admin_user: admin
ipa_admin_user_password: sosecure
internal_domain: domain
jellyfin:
  # Use this disk to store temporary files while transcoding
  # The disk will be formatted and mounted on /transcode
  # If empty this step is skipped
  extra_transcode_disk: /dev/vdb 
  # Configure Jellyfin to use a non default user
  # A group with the same name should exist
  user: svc_jellyfin
  # Credentials to connect to an s3 storage in which the jellyfin data can be backed up
  s3:
    user: jelly
    password: sosecure
```


## Minio
Uses Minio to backup it's data.

A user from LDAP cannot be directly added to the `mc` command

TODO remove svc_jellyfin user from minio

Create bucket: `mc mb --p local/jellyfin-config`
Add policy
```shell
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject"
        ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::jellyfin-config/*", "arn:aws:s3:::jellyfin-config"
      ],
      "Sid": "BucketAccessForUser"
    }
  ]
}
```