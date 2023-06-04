# Proxmox Intel iGPU passthrough

Based on https://3os.org/infrastructure/proxmox/gpu-passthrough/igpu-split-passthrough/#proxmox-configuration-for-gvt-g-split-passthrough

## Does not work when using ZFS

You need to add the boot options to the end of the systemd-boot file `/ertc/kernel/cmdline` and refresh using `proxmox-boot-tool refresh`
See: https://pve.proxmox.com/wiki/PCI_Passthrough#Intel_CPU
