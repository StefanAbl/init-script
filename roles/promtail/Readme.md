# Promtail
This will install Promtail on the machine to send logs to loki
## User
Promtail needs a username and password to connect to Loki. Please add a pair to the secrets file, like below
```yaml
logging:
    loki:
        users:
            - name: username
              password: sosecure
```
## Variables
The following variables are needed.
```yaml
promtail:
    user: # Name of the user from above
    run_as_user: # The user for the promtail process on the local machine. Defaults to www-data
    scrape_configs: # scrape configs for loki
    - job_name: system
      pipeline_stages: 
      static_configs:
      - targets:
         - localhost
        labels:
         host: "{{ansible_facts['fqdn']}}"
         app: nextcloud
         agent: promtail
         __path__: /data/nextcloud.log
```