# Automatically create Proxmox VMs with terrafrom
## Create a template of of which to base VMs
This template will be used as a base for the VMs created by Terraform
```bash
storage=DirStor
cd /DirStor/template/iso/
wget https://cloud-images.ubuntu.com/hirsute/current/hirsute-server-cloudimg-amd64.img
qm create 9000 -name hirsute-template -memory 1024 -net0 virtio,bridge=vmbr0 -cores 1 -sockets 1 -cpu cputype=kvm64 -description "Ubuntu Server 21.04 cloud image" -kvm 1 -numa 1
qm importdisk 9000 hirsute-server-cloudimg-amd64.img $storage
qm set 9000 -scsihw virtio-scsi-pci -virtio0 $storage:vm-9000-disk-0
qm set 9000 -serial0 socket
qm set 9000 -boot c -bootdisk virtio0
qm set 9000 -agent 1
qm set 9000 -hotplug disk,network,usb,memory,cpu
qm set 9000 -vcpus 1
qm set 9000 -vga qxl
qm set 9000 -name hirsute-template
qm set 9000 -ide2 $storage:cloudinit
qm template 9000

```

## Create VMs
Use Terraform to create the VMs automatically. The configuration can be found in `terraform/main.tf`.

```bash
docker run --rm -it  -v $PWD:/tf hashicorp/terraform:light -chdir=/tf apply
```

## Enroll VMs into domain

Create the entries in FreeIPA.
First obtain Kerberos ticket.
```bash
for i in 0 1 2; do
ipa host-add --random --os=Ubuntu-21.04 --ip-address=10.13.2.13$i k3s-$i.i.stabl.one
done
```


The hostname should be set to k3s-x by Terraform, but the domain still needs to be appended so that it is a FQDN.

```bash
echo "Enter OTP for FreeIPA enrollment"
read otp
sudo apt update
sudo apt install -y freeipa-client
sudo hostnamectl set-hostname $(hostname).i.stabl.one
sudo ipa-client-install --enable-dns-updates --mkhomedir --password "$otp" && sudo reboot
```
After this a it should be possible to establish a connection to the VM using the hostname and the FreeIPA user.
```bash
ssh -4 k3s-0.i.stabl.one
```

Then the default user should be deleted

```bash
sudo userdel -r ubuntu
```

## Install K3S

First add the hosts to the Ansible hosts file.
Add a variable called `k3s_token` to the secrets.yml Ansible vault

Then run the `install_k3s.yml` script to install K3S.
```bash
ansible-playbook -K -i hosts k3s/installation/install_k3s.yml --ask-vault-pass
```
