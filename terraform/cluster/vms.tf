variable "vms" {
  type = map(map(string))
  default = {
    master01 = {
      id     = 141
      ip     = "10.13.2.41"
      cores  = 2
      memory = 2048
      disk   = "32G"
      target_node = "proxmox0"
      template = "ubuntu-22.04"
    },
    master02 = {
      id     = 142
      ip     = "10.13.2.42"
      cores  = 2
      memory = 2048
      disk   = "32G"
      target_node = "proxmox1"
      template = "ubuntu-22.04-pm1"
    },
    master03 = {
      id     = 143
      ip     = "10.13.2.43"
      cores  = 2
      memory = 2048
      disk   = "32G"
      target_node = "proxmox2"
      template = "ubuntu-22.04-pm2"
    },
    worker01 = {
      id     = 151
      ip     = "10.13.2.51"
      cores  = 4
      memory = 4096
      disk   = "32G"
      target_node = "proxmox0"
      template = "ubuntu-22.04"
    },
    worker02 = {
      id     = 152
      ip     = "10.13.2.52"
      cores  = 4
      memory = 6144
      disk   = "32G"
      target_node = "proxmox1"
      template = "ubuntu-22.04-pm1"
    },
    worker03 = {
      id     = 153
      ip     = "10.13.2.53"
      cores  = 6
      memory = 8192
      disk   = "128G"
      target_node = "proxmox2"
      template = "ubuntu-22.04-pm2"
    }
  }
}
