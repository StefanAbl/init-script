# Loki 
Install Loki using the [official helm chart](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed)

An external Minio instance is used as the backing storage. Its address is s3.{{internal_domain}}:9000 a service account must be configured for Loki.

After deploying the helm chart with name "loki" the gateway will be reachable inside the cluster using `loki-loki-distributed-gateway.default.svc.cluster.local`