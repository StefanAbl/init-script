# Longhorn
## Installation
[Docs](https://longhorn.io/docs/1.1.1/deploy/install/install-with-kubectl/)

1. Install Longhorn on any Kubernetes cluster using this command:

```bash
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.1.1/deploy/longhorn.yaml
```
2. Check that the deployment was successful
```bash
kubectl -n longhorn-system get pod
```

## Configuration
The default config was changed in the following ways:

- `Default Replica Count` was set two 2