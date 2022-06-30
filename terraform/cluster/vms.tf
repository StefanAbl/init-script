variable "vms" {
  type = map(map(string))
  default = {
    master01 = {
      id     = 141
      ip     = "10.13.2.41"
      cores  = 2
      memory = 2048
      disk   = "32G"
    },
    master02 = {
      id     = 142
      ip     = "10.13.2.42"
      cores  = 2
      memory = 2048
      disk   = "32G"
    },
    master03 = {
      id     = 143
      ip     = "10.13.2.43"
      cores  = 2
      memory = 2048
      disk   = "32G"
    },
    worker01 = {
      id     = 151
      ip     = "10.13.2.51"
      cores  = 4
      memory = 4096
      disk   = "32G"
    },
    worker02 = {
      id     = 152
      ip     = "10.13.2.52"
      cores  = 4
      memory = 4096
      disk   = "32G"
    }
  }
}
