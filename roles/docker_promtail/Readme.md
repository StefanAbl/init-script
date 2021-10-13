# Docker Promtail
Roll to use promtail to send docker logs to Loki

Add the following to your docker run command: `--log-opt tag="{{.ImageName}}|{{.Name}}|{{.ImageFullID}}|{{.FullID}}"`

Or this to your ansible docker_container directive
```yml
log_driver: json-file
log_options:
  tag: "{{.ImageName}}|{{.Name}}|{{.ImageFullID}}|{{.FullID}}"
```

## User
Promtail needs a username and password to connect to Loki. Please add a pair to the secrets file, like below
```yaml
logging:
    loki:
        users:
            - name: username
              password: sosecure
```

The following variables are needed.
```yaml
promtail:
    user: #Name of the user from above
```