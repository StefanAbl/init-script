terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.9"
    }
  }
}
variable "pass" {
  type = string
  description = "Password for proxmox"
  sensitive = true
}
provider "proxmox" {
    pm_api_url = "https://proxmox0.i.stabl.one:8006/api2/json"
    pm_user = "root@pam"
    pm_password = "${var.pass}"
    pm_tls_insecure = "true"
}
variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDqseQRRLlG4YiNgD9Kjs+GAWudIPDXWFs3ic74CgnrSRF6tBRjqBmvGmjwbUvXvWPgfCdcLwPKFPUGx/R6ymXFiMwMc7ZCtthHg9rD/QtlSMRW/6YwKX8dzDteLERTmJFZzlh2MYob4Q6/543Dj57sGp3v1IQIfKTCmmTYrZIWCtxRdQ1P6I/jxk9bQvmfJs2LbhxUAvj0wdZOkSRySkxvpk3Abe/p2XpxKt8lcEHX0XkA27lu+s4w0y6BGc2q8ZNoFp5DgVF/oRDVREp/vwjS5Li5SPLqCPgFZru2xO5HkBMu1f4DS3pbGUw2vT/BZ6K8Cb8RjqYmZteSycMADOQ85ZoRU8rBsAHwFqbK5VYC13ovmhLKratE8WbSjfdhUlz74hjNyFFcTjZHy415zsEFa4G90mCGedPY8fzTLeI6b0itReqfmR0QcLtevqku4CtrD7n9GKbdq0dC8AJGr+68LiBHvtWH7VOBnM3+N+dI0FHKPia75Hw1cODjI6P+sTM= stefan@pop-os"
}

resource "proxmox_vm_qemu" "proxmox_vm" {
  count             = 3 
  name              = "k3s-${count.index}"
  target_node       = "proxmox0"
  clone             = "hirsute-template"
  os_type           = "cloud-init"
  agent             = 1
  cores             = 2 
  cpu               = "host"
  memory            = 4096 
  scsihw            = "virtio-scsi-pci"

disk {
    size            = "64G" 

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
  ipconfig0 = "ip=10.13.2.13${count.index}/24,gw=10.13.2.1"
  nameserver        = "10.13.2.100"
  searchdomain      = "i.stabl.one"
sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}