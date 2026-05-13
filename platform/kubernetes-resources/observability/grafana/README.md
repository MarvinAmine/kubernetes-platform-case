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

- `GRAFANA_ADMIN_PASSWORD`

Optional:

- `GRAFANA_ADMIN_USER`
  Defaults to `admin` if unset.

Those values must not be committed in values files.

Use:

- local `.env`
- GitHub repository secrets later if CI automates observability installation

## Environment-specific persistence model

Grafana persistence is intentionally split by environment:

- local: disabled
- dev / AKS: enabled

Reason:

- local dashboards and datasources are provisioned from code and can be
  recreated cheaply
- local `kind` storage repeatedly triggered `init-chown-data` permission
  failures on Grafana restart or upgrade
- dev remains the more production-shaped persistent environment

The local-only persistence override lives in:

- `kube-prometheus-stack-grafana-values-local.yaml`

This local/dev split was validated through a real Grafana Helm rollout:

- local Grafana restarted with a new pod template
- the replacement pod reached `3/3 Running`
- the earlier PVC ownership error did not return

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

## Dashboard authoring model

For Stage 1, the dashboard source of truth should be a separate JSON file in
the repository, not a very long inline JSON blob committed directly inside a
Kubernetes ConfigMap manifest.

Recommended locations:

- Platform-owned shared dashboards:
  `dashboards/`
- Reliability-owned service dashboards:
  `../../../../reliability/observability/grafana/dashboards/`

Recommended naming style:

- one dashboard per file
- clear service or platform scope in the filename

Examples:

- `dashboards/prometheus-overview-curated.json`
- `dashboards/kubernetes-networking-namespace-pods-curated.json`
- `dashboards/payment-exception-review-platform-runtime.json`
- `../../../../reliability/observability/grafana/dashboards/payment-exception-review-service-health.json`

That keeps the repo easier to review and lets the ConfigMap generation or
application logic stay separate from the dashboard content itself.

## Recommended workflow

This is the usual platform-oriented workflow for Grafana dashboards:

1. port-forward Grafana locally or from AKS dev
2. log in with the provisioned Grafana admin credentials
3. reuse the existing Prometheus datasource that comes from
   `kube-prometheus-stack`
4. create the dashboard in the Grafana UI first
5. save and validate the dashboard visually
6. export the dashboard JSON from Grafana
7. store that exported JSON in the repository under the owning team location
8. clean up any obviously environment-specific noise before committing it
9. only then wire that JSON into the Kubernetes ConfigMap or generation logic

This is preferred over writing the full dashboard JSON by hand from scratch.

## What to build first

For the first Stage 1 dashboard, keep it small and operationally useful.

Suggested first panels:

- target availability
- request rate
- average request latency
- JVM basics
- HikariCP / JDBC pool health
- pod restarts

## Expected next step

The dashboard JSON should be committed separately first.

The remaining manual step later is to create the Kubernetes ConfigMap or
generation logic that will load this JSON into Grafana through the existing
`kube-prometheus-stack` sidecar pattern.

## Troubleshooting

For the local persistence permission failure that can block Grafana startup on
local Kubernetes, see:

- [Scenario 4 - Local Grafana PVC permission failure](../troubleshooting/scenario-4-local-grafana-pvc-permission-failure.md)
- [Scenario 5 - 404 dashboard panel shows no data](../troubleshooting/scenario-5-404-dashboard-panel-shows-no-data.md)
- [Scenario 6 - Grafana classic file provisioning rejects v2 dashboard JSON](../troubleshooting/scenario-6-grafana-classic-file-provisioning-rejects-v2-dashboard-json.md)

## Ownership split

- Platform team owns the shared Grafana stack, provider wiring, Helm values,
  lifecycle scripts, and shared platform dashboards under
  `platform/kubernetes-resources/observability/`.
- Reliability Team owns service-specific dashboard JSON content under
  `reliability/observability/grafana/dashboards/`.

This keeps the operational content separate from the Platform-owned shared
observability stack while still letting Kustomize generate the dashboard
ConfigMaps for Grafana.
