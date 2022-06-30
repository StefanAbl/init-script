terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.10"
    }
    freeipa = {
      source  = "camptocamp/freeipa"
      version = "0.7.0"
    }
  }
}
provider "freeipa" {
  host     = "ipa.${var.domain}" # or set $FREEIPA_HOST
  username = var.user            # or set $FREEIPA_USERNAME
  password = var.pass            # or set $FREEIPA_PASSWORD
  insecure = true
}
provider "proxmox" {
  pm_api_url      = "https://proxmox0.${var.domain}:8006/api2/json"
  pm_user         = "${var.user}@${var.domain}"
  pm_password     = var.pass
  pm_tls_insecure = "true"
  #   pm_log_enable = true
  #   pm_log_file = "terraform-plugin-proxmox.log"
  #   pm_debug = true
  #   pm_log_levels = {
  #     _default = "debug"
  #     _capturelog = ""
  #  }

}

module "create_vms" {
  source = "./modules/vm"

  for_each = var.vms

  hostname = each.key
  id       = each.value.id
  cores    = each.value.cores
  memory   = each.value.memory
  disk     = each.value.disk
  ip       = each.value.ip
  template = "ubuntu-22.04"
  domain   = var.domain
}
