# Homelab

Configuration for my Homelab which is setup using Ansible.

It includes a locally hosted [Nextcloud](./nextcloud) and [Jellyfin](./jellyfin) instances.
Some Application are hosted in a [k3s Kubernetes](./k3s) cluster and there is an [e-mail server](./cloud) hosted in the cloud.



## Requirements

- Install external Ansible collections with `ansible-galaxy collection install -r requirements.yml`
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## zsh.yml

it will install zsh and powerlevel10k and configure it based on the users preference
```
ansible-playbook -K -i hosts -u stefan zsh.yml 
```
