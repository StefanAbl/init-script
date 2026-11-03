# Node exporter
Installs the Prometheus [node_exporter](https://github.com/prometheus/node_exporter) as a systemd service
and opens its port in firewalld (if firewalld is running). Scraped by `prometheus-external` in the cluster.

All default collectors and filesystem excludes are kept, so tmpfs mounts like `/run` are monitored too.
## Variables
```yaml
node_exporter_version: "1.12.1"
node_exporter_port: 9100
node_exporter_args: [] # extra command line flags
```
