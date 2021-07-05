# init-script

## Ansible

Install external collections with `ansible-galaxy collection install -r requirements.yml`

## zsh.yml

it will install zsh and powerlevel10k and configure it based on the users preference
```
ansible-playbook -K -i hosts -u stefan zsh.yml 
```
## initial.yml

Update packages and install some requirements

## dockerCentos.yml

Install docker on CentOS