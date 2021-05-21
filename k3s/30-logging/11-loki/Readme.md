# Loki 
Install Loki using the [official helm chart](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed)

A single Minio instance is used as the backing storage. It stores its data in a longhorn volume.

After deploying the helm chart with name "loki" the gateway will be reachable inside the cluster using `loki-loki-distributed-gateway.default.svc.cluster.local`