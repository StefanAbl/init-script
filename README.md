# init-script

## Requirements

- Install external Ansible collections with `ansible-galaxy collection install -r requirements.yml`
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## zsh.yml

it will install zsh and powerlevel10k and configure it based on the users preference
```
ansible-playbook -K -i hosts -u stefan zsh.yml 
```
