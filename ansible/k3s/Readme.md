# K3S in the Homelab

## [Installation](./installation)

Installation of the cluster is partially automated with Terraform and Ansible.

## Applications

The applications can be divided into supporting applications such as [Cert-Manager](./10-cert-manager) to obtain certificates and [Longhorn](./12-longhorn) for storage.

A [monitoring stack](./30-logging) using Grafana, Prometheus, Loki and Influxdb is used to monitor applications both inside and outside the cluster.
