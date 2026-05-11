# Scenario 5: 404 Dashboard Panel Shows No Data

[UP: Observability Troubleshooting ->](./README.md)

[ROOT INDEX: Troubleshooting Index ->](../../../../docs/troubleshooting-index.md)

[STACK DOC: Shared Observability Stack ->](../README.md)

[GRAFANA DOC: Grafana ->](../grafana/README.md)

## Issue summary

A Grafana panel intended to show HTTP 404 activity appeared empty even though
the query itself looked reasonable.

Example query:

```promql
sum(
  rate(http_server_requests_seconds_count{
    namespace="payment-exception-review-local",
    status="404"
  }[5m])
)
```

## Root cause

This was not a Grafana rendering problem.

The empty panel came from a combination of two normal conditions:

- no recent 404 traffic had been generated yet
- the original label filter was too narrow for the way the metric was exposed

In practice, the `job` label turned out to be a more reliable application-level
filter than the earlier `namespace`-only query.

## Why it happened here

The panel was created before enough real application traffic existed to produce
recent 404 samples inside the query window.

After traffic was generated manually through the local port-forward and the
query was widened to the right label set, the panel started returning data.

## Diagnosis checklist

1. Confirm the app is reachable and generate fresh traffic:

```bash
kubectl -n payment-exception-review-local port-forward svc/payment-exception-review-service 8080:80
curl http://localhost:8080/actuator/health
curl http://localhost:8080/api/payment-exceptions/payexc-100045/status
curl http://localhost:8080/api/payment-exceptions/payexc-100045/service-status
curl http://localhost:8080/api/payment-exceptions/payexc-100045/bob
```

2. Check whether the metric exists without the narrow filter:

```promql
sum by (status) (
  rate(http_server_requests_seconds_count[5m])
)
```

3. Check which application label is reliable:

```promql
sum by (job, status) (
  rate(http_server_requests_seconds_count[5m])
)
```

4. Only after that apply the application-specific filter.

## Working query

This query worked reliably for the Stage 1 local setup:

```promql
sum by (status) (
  rate(http_server_requests_seconds_count{
    job=~".*payment-exception-review.*"
  }[5m])
)
```

For a dedicated 404 panel:

```promql
sum(
  rate(http_server_requests_seconds_count{
    job=~".*payment-exception-review.*",
    status="404"
  }[5m])
)
```

## Recommended panel types

For the main error view:

- `Time series`
- title example: `404 Request Rate`

Optional summary panel:

```promql
sum(
  increase(http_server_requests_seconds_count{
    job=~".*payment-exception-review.*",
    status="404"
  }[1h])
)
```

- `Stat`
- title example: `404 Requests (1h)`

## Recovery runbook

If the panel is empty again:

1. generate fresh traffic against the app
2. remove overly narrow filters first
3. inspect labels with `sum by (job, status)`
4. reapply the app filter using the working `job` regex
5. refresh the Grafana panel

## Interpretation

An empty 404 panel does not automatically mean Prometheus or Grafana is broken.

In this case, the real issue was:

- no recent matching traffic
- plus a filter choice that was too strict for the actual metric labels
