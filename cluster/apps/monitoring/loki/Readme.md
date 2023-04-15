# Loki

## Generate new htpassword for basicauth

```bash
sudo apt install apache2-utils
htpasswd -n username
```


Install Loki using the [official helm chart](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed)

An external Minio instance is used as the backing storage. Its address is `s3.{{internal_domain}}:9000` a service account must be configured for Loki in Minio

After deploying the helm chart with name "loki" the gateway will be reachable inside the cluster using `loki-loki-distributed-gateway.default.svc.cluster.local`. The Ingress resource will expose Loki for external services at [loki.k3s.i.stabl.one](https://loki.k3s.i.stabl.one). It is protected using basic authentication, the users can be configured via the Ansible vault file

## Promtail

To send all logs of Kubernetes pods to Loki, the Promtail Helm chart is also installed in the Cluster. They can be explored in [Grafana](https://grafana.k3s.i.stabl.one/explore?orgId=1&left=%7B%22datasource%22:%22Loki%22,%22queries%22:%5B%7B%22refId%22:%22A%22,%22expr%22:%22%7Bhost%3D%5C%22k3s.i.stabl.one%5C%22%7D%22%7D%5D,%22range%22:%7B%22from%22:%22now-1h%22,%22to%22:%22now%22%7D%7D).

## Event Exporter

Kubernetes events, such as the scheduling or deletion of pods are not logged by Promtail. Therefore the [Kubernetes Event Exporter](https://github.com/opsgenie/kubernetes-event-exporter) is used to monitor these events and log them, so that they may be send to Loki by Promtial. They can be browsed in [Grafana](https://grafana.k3s.i.stabl.one/explore?orgId=1&left=%7B%22datasource%22:%22Loki%22,%22queries%22:%5B%7B%22refId%22:%22A%22,%22expr%22:%22%7Bapp%3D%5C%22event-exporter%5C%22%7D%22%7D%5D,%22range%22:%7B%22from%22:%22now-1h%22,%22to%22:%22now%22%7D%7D).
