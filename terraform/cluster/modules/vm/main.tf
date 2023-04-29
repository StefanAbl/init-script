resource "tls_private_key" "temporary" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "freeipa_host" "hostname" {
  fqdn        = "${var.hostname}.${var.domain}"
  description = ""
  force       = true
  random      = true
}

resource "proxmox_vm_qemu" "proxmox_vm" {
  count                     = 1
  vmid                      = var.id
  name                      = var.hostname
  target_node               = var.target_node
  clone                     = var.template
  os_type                   = "cloud-init"
  agent                     = 1
  cores                     = var.cores
  vcpus                     = 0
  cpu                       = "host"
  memory                    = var.memory
  scsihw                    = "virtio-scsi-pci"
  guest_agent_ready_timeout = 120
  define_connection_info    = false
  qemu_os                   = "other"

  disk {
    slot    = 0
    size    = var.disk
    type    = "virtio"
    storage = var.target_node == "proxmox0" ? "NVMe" : "local-zfs"
    backup  = false
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
    tag    = var.target_node == "proxmox0" ? 2 : -1
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  # Cloud Init Settings
  ipconfig0    = "ip=${var.ip}/24,gw=10.13.2.1"
  nameserver   = "10.13.2.100"
  searchdomain = var.domain
  # disable_password_authentication = false
  ciuser     = "ubuntu"
  cipassword = "ubuntu"
  sshkeys    = <<EOF
  ${tls_private_key.temporary.public_key_openssh}
  EOF

  provisioner "remote-exec" {
    inline = [
      "sudo rm /etc/apt/apt.conf.d/99needrestart",
      "sleep 30 && DEBIAN_FRONTEND=noninteractive sudo apt-get -o DPkg::Lock::Timeout=240 -o pkg::Options::=\"--force-confnew\" -y update",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get -o DPkg::Lock::Timeout=240 -o pkg::Options::=\"--force-confnew\" -y upgrade",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get -o DPkg::Lock::Timeout=240 -o pkg::Options::=\"--force-confnew\" -y install freeipa-client qemu-guest-agent",
      "if hostname | grep ${var.domain} ; then   echo \"Hostname already correct\" ; else   sudo hostnamectl set-hostname $(hostname).${var.domain}; fi",
      "sudo ipa-client-install --unattended --enable-dns-updates --mkhomedir --password \"${freeipa_host.hostname.randompassword}\" && sudo sh -c \"userdel -rf ubuntu && shutdown -r +0\""
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    password    = ""
    private_key = tls_private_key.temporary.private_key_pem
    host        = var.ip
  }

}
