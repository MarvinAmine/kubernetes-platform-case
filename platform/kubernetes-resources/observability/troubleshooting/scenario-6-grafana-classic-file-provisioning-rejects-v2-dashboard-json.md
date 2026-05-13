# Scenario 6: Grafana Classic File Provisioning Rejects V2 Dashboard JSON

[UP: Observability Troubleshooting ->](./README.md)

[ROOT INDEX: Troubleshooting Index ->](../../../../docs/troubleshooting-index.md)

[STACK DOC: Shared Observability Stack ->](../README.md)

[GRAFANA DOC: Grafana ->](../grafana/README.md)

## Issue summary

A Grafana dashboard was authored successfully in the Grafana UI, exported,
wrapped in a Kubernetes `ConfigMap`, and applied through the Grafana sidecar
dashboard provisioning path, but the dashboard never appeared in Grafana.

The `ConfigMap`, sidecar reload, and Kustomize flow all looked healthy.

## Confirmed root cause

The exported dashboard JSON was in **Grafana v2 schema** format, while the
current `kube-prometheus-stack` sidecar file provisioning flow expects the
**classic dashboard JSON** format.

Grafana confirmed this directly in the main container logs:

```text
failed to save dashboard ... error="dashboard appears to be in v2 format. Please use the /apis/dashboard.grafana.app/v2 API"
```

## Why it happened here

This repository currently provisions dashboards through:

- Kubernetes `ConfigMap`
- Grafana sidecar file discovery
- classic file-based dashboard provisioning

That path is compatible with classic dashboard JSON, but not with the newer v2
resource export format from the Grafana UI.

The dashboard was also showing this warning in the UI before export:

```text
This dashboard uses the V2 schema. Features like tabs and conditional rendering cannot be represented in the classic format and may be lost.
```

That warning was the early signal that the file-provisioning path and the
dashboard export format were mismatched.

## Evidence collected

The sidecar correctly detected and reloaded the file:

```text
Writing /tmp/dashboards/payment-exception-review-service-health.json
... Dashboards config reloaded
```

The `ConfigMap` was also correct:

- `namespace: monitoring`
- `grafana_dashboard: "1"`
- JSON file key ending with `.json`

The failure was only visible in the main Grafana container logs:

```bash
kubectl -n monitoring logs deploy/kube-prometheus-stack-grafana -c grafana --tail=200
```

## Diagnosis checklist

1. Confirm the dashboard `ConfigMap` exists in `monitoring`:

```bash
kubectl -n monitoring get configmap payment-exception-review-service-health-dashboard -o yaml
```

2. Confirm the Grafana sidecar saw the file and triggered reload:

```bash
kubectl -n monitoring logs deploy/kube-prometheus-stack-grafana -c grafana-sc-dashboard --tail=100
```

3. Check the main Grafana logs for provisioning errors:

```bash
kubectl -n monitoring logs deploy/kube-prometheus-stack-grafana -c grafana --tail=200
```

4. If you see this error, the file is in the wrong schema for classic
   provisioning:

```text
dashboard appears to be in v2 format
```

## Recovery runbook

1. Re-export the dashboard from the Grafana UI in **classic format**.
2. Replace the JSON file stored under:

```text
reliability/observability/grafana/dashboards/
```

3. Re-apply the Kustomize folder:

```bash
kubectl apply -k platform/kubernetes-resources/observability/grafana
```

4. Re-check the main Grafana logs.
5. Refresh Grafana and search for the dashboard title again.

## How to recognize the wrong export format

The rejected v2-style export contains structures such as:

- `kind`
- `spec`
- `elements`
- `layout`

The classic export is the safer file-provisioning format and uses the older
dashboard model with fields such as:

- `title`
- `panels`
- `templating`
- `time`
- `annotations`

## Practical decision for this repository

For this Stage 1 platform case:

- keep **Kustomize** for dashboard `ConfigMap` generation
- keep the `kube-prometheus-stack` sidecar file provisioning path
- export dashboards in **classic format**

If the repository later moves to a newer Grafana resource-based provisioning
model, v2 dashboards can be reconsidered there. For the current platform path,
classic export is the correct operational choice.
