terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.10"
    }
  }
}
variable "pass" {
  type = string
  description = "Password for proxmox"
  sensitive = true
}
variable "otp" {
  type = string
  description = "One time password for FreeIPA client enrollment"
  sensitive = false
}
provider "proxmox" {
    pm_api_url = "https://proxmox0.i.stabl.one:8006/api2/json"
    pm_user = "root@pam"
    pm_password = "${var.pass}"
    pm_tls_insecure = "true"
}

resource "tls_private_key" "temporary" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "proxmox_vm_qemu" "proxmox_vm" {
  count             = 1
  name              = "jellyfin0"
  target_node       = "proxmox0"
  clone             = "focal-template"
  os_type           = "cloud-init"
  agent             = 1
  cores             = 2
  cpu               = "host"
  memory            = 4096
  scsihw            = "virtio-scsi-pci"

disk {
    size            = "16G"
    type            = "virtio"
    storage         = "NVMe"
    backup          = 1
  }
disk {
    size            = "16G"
    type            = "virtio"
    storage         = "NVMe"
  }
network {
    model           = "virtio"
    bridge          = "vmbr0"
    tag            = 2
  }
lifecycle {
    ignore_changes  = [
      network,
    ]
  }
# Cloud Init Settings
  ipconfig0 = "ip=10.13.2.110/24,gw=10.13.2.1"
  nameserver        = "10.13.2.100"
  searchdomain      = "i.stabl.one"
 # disable_password_authentication = false
  ciuser = "ubuntu"
  cipassword = "ubuntu"
  sshkeys = <<EOF
  ${tls_private_key.temporary.public_key_openssh}
  EOF

  provisioner "remote-exec" {
    inline = [
      "DEBIAN_FRONTEND=noninteractive sudo apt-get update -y && DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y && DEBIAN_FRONTEND=noninteractive sudo timeout 10m apt-get install -q -y freeipa-client qemu-guest-agent",
      "if hostname | grep stabl.one ; then   echo \"Hostname already correct\" ; else   sudo hostnamectl set-hostname $(hostname).i.stabl.one; fi",
      "sudo ipa-client-install --unattended --enable-dns-updates --mkhomedir --password \"${var.otp}\" && sudo userdel -rf ubuntu && sudo reboot"
    ]
  }

  # Login to the ec2-user with the aws key.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    password    = ""
    private_key = "${tls_private_key.temporary.private_key_pem}"
    host        = "10.13.2.110"
  }

}
