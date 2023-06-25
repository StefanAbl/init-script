terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
    freeipa = {
      source  = "camptocamp/freeipa"
      version = "0.8.0"
    }
  }
}
