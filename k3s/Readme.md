# K3S in the homelab

## Installation

The install_k3s.yml script will provision all the hots in the k3s hostgroup as Kubernetes servers

Download kubectl

```bash
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
```

Copy the config file from one of the servers from `/etc/rancher/k3s/k3s.yaml` to `k3s.yml`

Make an alias for kubeconfig with config

```bash
alias k=$PWD'/kubectl --kubeconfig '$PWD'/k3s.yml'
```

## Kubernetes Dashboard

```bash
k apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.4/aio/deploy/recommended.yaml
k create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml
k -n kubernetes-dashboard describe secret admin-user-token | grep ^token
k proxy
```

Go to http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/ and log in with the token

## Test nginx deployment

```bash
k apply -f testdeploy.yml
```

## Basic auth with default k3s traefik ingress

Create a basic auth fle with the username and password

```bash
USER=<USERNAME_HERE>; PASSWORD=<PASSWORD_HERE>; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})" >> auth
```

Create a Kubernetes secret from the file

```bash
kubectl -n longhorn-system create secret generic basic-auth --from-file=auth
```

Create an Ingress mainfest

```yaml
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: longhorn-ingress
  annotations:
    kubernetes.io/ingress.class: traefik
    ingress.kubernetes.io/auth-type: basic
    ingress.kubernetes.io/auth-secret: basic-auth
spec:
  rules:
  - http:
      paths:
      - path: /
        backend:
          serviceName: longhorn-frontend
          servicePort: 80
```

## Helm
Download and unpack Helm
use helm with local config `KUBECONFIG=$PWD/k3s.yml ./helm init`

```bash
alias h="KUBECONFIG=$PWD/k3s.yml $PWD/helm"
```
`$PWD'/kubectl --kubeconfig '$PWD'/k3s.yml'`
