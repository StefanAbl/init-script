# Jellyfin

Automatically provision a Proxmox VM and install Jellyfin

Use Terraform to provision VM and adopt it to FreeIPA domain

```shell
docker run --rm -it  -v $PWD:/tf hashicorp/terraform:light -chdir=/tf init
docker run --rm -it  -v $PWD:/tf hashicorp/terraform:light -chdir=/tf apply
```

Afterwards make sure the default ubuntu user is delete and reboot

```shell
sudo killall -u ubuntu
sudo userdel -r ubuntu
sudo reboot
```

Uses Minio to backup it's data

## Minio
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

## VM Template

This template will be used as a base for the VMs created by Terraform
```bash
export LC_ALL="en_US.UTF-8"
set -e
cd /DirStor/template/iso/
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
qm create 9001 -name focal-template -memory 1024 -net0 virtio,bridge=vmbr0 -cores 1 -sockets 1 -cpu cputype=kvm64 -description "Ubuntu Server 20.04 LTS cloud image" -kvm 1 -numa 1
qm importdisk 9001 focal-server-cloudimg-amd64.img DirStor
qm set 9001 -scsihw virtio-scsi-pci -virtio0 DirStor:9001/vm-9001-disk-0.raw
qm set 9001 -serial0 socket
qm set 9001 -boot c -bootdisk virtio0
qm set 9001 -agent 1
qm set 9001 -hotplug disk,network,usb,memory,cpu
qm set 9001 -vcpus 1
qm set 9001 -vga qxl
qm set 9001 -name focal-template
qm set 9001 -ide2 DirStor:cloudinit
qm template 9001

```