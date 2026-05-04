# Grafana

This folder documents the Grafana side of the shared platform observability
stack.

## Role in this repository

Grafana is used for:

- visualizing shared platform metrics
- exposing dashboards for application and platform health
- supporting operational visibility for platform and application teams

## Installation model

Grafana is not installed as a standalone chart in the first implementation.

It is installed through:

- `kube-prometheus-stack`

That keeps Grafana aligned with the shared Prometheus and Alertmanager
installation path.

The environment-specific installation entrypoints live one level higher in:

- `../install_local_observability_stack.sh`
- `../install_dev_observability_stack.sh`

The shared Helm installation logic itself lives in:

- `../scripts/cluster/install_shared_observability_stack.sh`

## Credentials

The planned installation path expects:

- `GRAFANA_ADMIN_USER`
- `GRAFANA_ADMIN_PASSWORD`

Those values must not be committed in values files.

Use:

- local `.env`
- GitHub repository secrets later if CI automates observability installation

## Default datasource behavior

In the current shared stack, Grafana already provisions the Prometheus
datasource by default.

So for local validation and AKS validation:

- first check the existing datasource
- reuse the provisioned Prometheus datasource
- do not add a duplicate datasource manually unless you are intentionally
  testing an alternate configuration

The expected datasource URL is:

```text
http://kube-prometheus-stack-prometheus.monitoring:9090
```

## What belongs here later

This folder is the right place for Grafana-specific material such as:

- access runbooks
- dashboard import/export notes
- provisioning conventions
- SSO integration notes
- folder and RBAC conventions
