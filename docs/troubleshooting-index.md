# Troubleshooting Index

This document is the root troubleshooting entrypoint for the repository.

Use it to navigate to the domain-owned troubleshooting hubs and the concrete
runbooks beneath them.

## Infrastructure

- [Infrastructure troubleshooting hub](../infrastructure/docs/troubleshooting/README.md)
- [Scenario 5 - Remote backend requires rebinding with `terraform init -reconfigure`](../infrastructure/docs/troubleshooting/scenario-5-remote-backend-requires-rebinding-with-terraform-init-reconfigure.md)
- [Scenario 6 - `terraform validate` fails because the `azurerm` backend block is too empty](../infrastructure/docs/troubleshooting/scenario-6-terraform-validate-fails-because-the-azurerm-backend-block-is-too-empty.md)

## Observability

- [Observability troubleshooting hub](../platform/kubernetes-resources/observability/troubleshooting/README.md)
- [Scenario 1 - Helm install returns `context deadline exceeded`](../platform/kubernetes-resources/observability/troubleshooting/scenario-1-helm-install-context-deadline-exceeded.md)
- [Scenario 2 - Prometheus API query validation fails](../platform/kubernetes-resources/observability/troubleshooting/scenario-2-prometheus-api-query-missing-query-parameter.md)
- [Scenario 3 - Grafana datasource validation fails with `127.0.0.1`](../platform/kubernetes-resources/observability/troubleshooting/scenario-3-grafana-datasource-validation-fails-with-localhost.md)
- [Scenario 4 - Local Grafana PVC permission failure](../platform/kubernetes-resources/observability/troubleshooting/scenario-4-local-grafana-pvc-permission-failure.md)
- [Scenario 5 - 404 dashboard panel shows no data](../platform/kubernetes-resources/observability/troubleshooting/scenario-5-404-dashboard-panel-shows-no-data.md)
- [Scenario 6 - Grafana classic file provisioning rejects v2 dashboard JSON](../platform/kubernetes-resources/observability/troubleshooting/scenario-6-grafana-classic-file-provisioning-rejects-v2-dashboard-json.md)
- [Scenario 7 - AKS dashboard panels are empty because queries are hardcoded to the local namespace](../platform/kubernetes-resources/observability/troubleshooting/scenario-7-aks-dashboard-panels-empty-because-queries-are-hardcoded-to-local-namespace.md)

## Ownership model

The repository keeps troubleshooting material close to the owning domain:

- infrastructure incidents stay under `infrastructure/docs/troubleshooting/`
- observability incidents stay under
  `platform/kubernetes-resources/observability/troubleshooting/`
