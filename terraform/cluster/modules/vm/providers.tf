terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.11"
    }
    freeipa = {
      source  = "camptocamp/freeipa"
      version = "0.7.0"
    }
  }
}
