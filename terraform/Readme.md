# Terraform

## Create VM Template on Proxmox host

```bash
set -e
export LC_ALL="en_US.UTF-8"
ID=9002
name="ubuntu-22.04"
cd /DirStor/template/iso/
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -O cloud-init.img
qm create $ID -name "$name" -memory 1024 -net0 virtio,bridge=vmbr0 -cores 1 -sockets 1 -cpu cputype=kvm64 -kvm 1 -numa 1
qm importdisk $ID cloud-init.img DirStor
qm set $ID -scsihw virtio-scsi-pci -virtio0 DirStor:$ID/vm-$ID-disk-0.raw
qm set $ID -serial0 socket
qm set $ID -boot c -bootdisk virtio0
qm set $ID -agent 1
qm set $ID -hotplug disk,network,usb,memory,cpu
qm set $ID -vcpus 1
qm set $ID -vga qxl
qm set $ID -name "$name"
qm set $ID -ide2 DirStor:cloudinit
qm template $ID

```

With ZFS storage

```bash
set -e
export LC_ALL="en_US.UTF-8"
ID=9003
name="ubuntu-22.04"
storage=local-zfs

cd
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -O cloud-init.img
qm create $ID -name "$name" -memory 1024 -net0 virtio,bridge=vmbr0 -cores 1 -sockets 1 -cpu cputype=kvm64 -kvm 1 -numa 1
qm importdisk $ID cloud-init.img $storage
qm set $ID -scsihw virtio-scsi-pci -virtio0 $storage:vm-$ID-disk-0
qm set $ID -serial0 socket
qm set $ID -boot c -bootdisk virtio0
qm set $ID -agent 1
qm set $ID -hotplug disk,network,usb,memory,cpu
qm set $ID -vcpus 1
qm set $ID -vga qxl
qm set $ID -name "$name"
qm set $ID -ide2 $storage:cloudinit
qm template $ID
```
