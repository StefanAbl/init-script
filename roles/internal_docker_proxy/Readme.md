# Internal Docker Proxy

Creates an Nginx Container which acts as a reverse proxy for Docker containers in the same network.


Needs the following variables:
```yaml
internal_docker_proxy:
  network_name: primary # Name for the Docker network of the created Nginx container. Optional default is primary
  nginx_dir: /var/docker/nginx # Where to put the config files
  sites:
    - server_name: service.host.domain.name
      upstream: http://docker-container:1234
      record: service.host # Record to create in FreeIPA relative to domain name
      protected: true # Whether this record should be secured with Authelia

# May be loaded from secrets.yaml
ipa_server: http://ipa.domain.name
ipa_admin_user: admin
ipa_admin_user_password: supersecure
internal_domain: domain.name
internal_authelia_fqdn: authelia.domain.name
authelia_local: False # Set to true if Authelia is running as a container on this host
```