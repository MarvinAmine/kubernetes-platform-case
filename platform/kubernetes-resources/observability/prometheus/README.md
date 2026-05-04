# Prometheus

This folder documents the Prometheus side of the shared platform observability
stack.

## Role in this repository

Prometheus is used for:

- scraping Spring Boot metrics from `/actuator/prometheus`
- collecting platform and workload metrics
- supporting shared monitoring for the governed Kubernetes platform

The application Helm chart publishes a `ServiceMonitor` so the shared platform
Prometheus instance can scrape the application across namespaces.

## Installation model

Prometheus is not installed as a standalone chart in the first implementation.

It is installed through:

- `kube-prometheus-stack`

That keeps the platform monitoring stack integrated and easier to operate.

The environment-specific installation entrypoints live one level higher in:

- `../install_local_observability_stack.sh`
- `../install_dev_observability_stack.sh`

The shared Helm installation logic itself lives in:

- `../scripts/cluster/install_shared_observability_stack.sh`

## What belongs here later

This folder is the right place for Prometheus-specific material such as:

- scrape strategy notes
- retention notes
- `ServiceMonitor` conventions
- Prometheus access runbooks
- later Thanos integration notes
