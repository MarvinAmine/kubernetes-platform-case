# Grafana Dashboards

This folder stores Grafana dashboard JSON files used by the shared
observability stack.

## Authoring rule

Do not use a very large inline JSON blob inside a Kubernetes ConfigMap as the
primary authoring format.

Preferred flow:

1. create the dashboard in the Grafana UI
2. validate it visually
3. export the dashboard JSON
4. store that JSON in this folder
5. wire it into the Kubernetes ConfigMap or generation logic afterward

## Naming convention

Use one dashboard per file with a clear scope.

Examples:

- `payment-exception-review-overview.json`
- `platform-runtime-overview.json`

## Status

The first Stage 1 dashboard JSON will be added here after the UI-based
dashboard is created and exported.
