terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}
variable "pass" {
  type        = string
  description = "Password for proxmox"
  sensitive   = true
}
variable "otp" {
  type        = string
  description = "One time password for FreeIPA client enrollment"
  sensitive   = false
}
provider "proxmox" {
  pm_api_url      = "https://proxmox0.i.stabl.one:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = "${var.pass}"
  pm_tls_insecure = "true"
}

resource "tls_private_key" "temporary" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "proxmox_vm_qemu" "proxmox_vm" {
  vmid        = 190
  count       = 1
  name        = "backup-mx"
  target_node = "proxmox0"
  clone       = "ubuntu-22.04"
  os_type     = "cloud-init"
  agent       = 0
  cores       = 2
  cpu         = "host"
  memory      = 2048
  scsihw      = "virtio-scsi-pci"

  disk {
    size    = "16G"
    type    = "virtio"
    storage = "NVMe"
    backup  = true
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
    tag    = 2
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  # Cloud Init Settings
  ipconfig0    = "ip=10.13.2.190/24,gw=10.13.2.1"
  nameserver   = "10.13.2.100"
  searchdomain = "i.stabl.one"
  # disable_password_authentication = false
  ciuser       = "ubuntu"
  cipassword   = "ubuntu"
  sshkeys      = <<EOF
  ${tls_private_key.temporary.public_key_openssh}
  EOF

  provisioner "remote-exec" {
    inline = [
      "sudo sh -c \"echo '$nrconf{restart} = \"'\"a\"'\"'; >> /etc/needrestart/needrestart.conf\"",
      "sudo sh -c 'export DEBIAN_FRONTEND=no ninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1 && apt-get remove needrestart -yqq && apt-get update -yqq && timeout 10m apt-get install -qq -y freeipa-client qemu-guest-agent ' ",
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
    host        = "10.13.2.190"
  }

}
