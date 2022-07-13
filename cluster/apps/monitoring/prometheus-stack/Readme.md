# Kube Prometheus Stack

Monitor Kubernetes with Prometheus

### Access Prometheus Web Dashboard

```
kubectl --kubeconfig kubeconfig.yml port-forward -n monitoring pod/prometheus-kube-prometheus-stack-prometheus-0 :9090
```
