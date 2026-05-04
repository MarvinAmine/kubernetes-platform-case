# Alertmanager

This folder documents the Alertmanager side of the shared platform
observability stack.

## Role in this repository

Alertmanager is used for:

- routing alerts generated from shared Prometheus rules
- separating notification ownership between teams
- supporting governed operational escalation paths

## Installation model

Alertmanager is not installed as a standalone chart in the first
implementation.

It is installed through:

- `kube-prometheus-stack`

That keeps alert routing aligned with the shared Prometheus and Grafana
installation path.

The environment-specific installation and teardown entrypoints live one level
higher in:

- `../install_local_observability_stack.sh`
- `../destroy_local_observability_stack.sh`
- `../install_dev_observability_stack.sh`
- `../destroy_dev_observability_stack.sh`

The shared Helm implementation lives in:

- `../scripts/cluster/install_shared_observability_stack.sh`
- `../scripts/cluster/destroy_shared_observability_stack.sh`

## What belongs here later

This folder is the right place for Alertmanager-specific material such as:

- route and receiver conventions
- severity mapping
- on-call notification notes
- team ownership rules
- later governance guidance for regulated escalation flows
