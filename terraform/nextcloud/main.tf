terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}
provider "proxmox" {
    pm_api_url = "https://proxmox0.i.stabl.one:8006/api2/json"
    pm_user = "${var.proxmox_user}"
    pm_password = "${var.proxmox_pass}"
    pm_tls_insecure = "true"
}
variable "proxmox_user" {
  type = string
  sensitive = true
}
variable "proxmox_pass" {
  type = string
}
variable "otp" {
  type = string
}
variable "ip" {
  type = string
}
variable "hostname" {
  type = string
}
resource "tls_private_key" "temporary" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "proxmox_vm_qemu" "proxmox_vm" {
  count             = 1
  name              = "${var.hostname}"
  target_node       = "proxmox0"
  clone             = "ubuntu-20.04"
  os_type           = "cloud-init"
  agent             = 1
  cores             = 4
  cpu               = "host"
  memory            = 4096
  scsihw            = "virtio-scsi-pci"
  guest_agent_ready_timeout = 120
  define_connection_info = false

disk {
    slot            = 0
    size            = "32G"
    type            = "virtio"
    storage         = "NVMe"
    backup          = 1
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
  ipconfig0 = "ip=${var.ip}/24,gw=10.13.2.1"
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
      "sleep 30 && DEBIAN_FRONTEND=noninteractive sudo apt-get -o DPkg::Lock::Timeout=240 update -y && DEBIAN_FRONTEND=noninteractive sudo apt-get -o DPkg::Lock::Timeout=240 upgrade -y && DEBIAN_FRONTEND=noninteractive sudo apt-get -o DPkg::Lock::Timeout=240 install -q -y freeipa-client qemu-guest-agent",
      "if hostname | grep stabl.one ; then   echo \"Hostname already correct\" ; else   sudo hostnamectl set-hostname $(hostname).i.stabl.one; fi",
      "sudo ipa-client-install --unattended --enable-dns-updates --mkhomedir --password \"${var.otp}\" && sudo sh -c \"userdel -rf ubuntu && shutdown -r +0\""
    ]
  }

  # Login to the ec2-user with the aws key.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    password    = ""
    private_key = "${tls_private_key.temporary.private_key_pem}"
    host        = "${var.ip}"
  }

}
