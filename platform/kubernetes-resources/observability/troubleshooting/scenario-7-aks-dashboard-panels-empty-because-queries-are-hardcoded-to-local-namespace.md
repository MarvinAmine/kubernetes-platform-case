# Scenario 7: AKS Dashboard Panels Are Empty Because Queries Are Hardcoded To The Local Namespace

[UP: Observability Troubleshooting ->](./README.md)

[ROOT INDEX: Troubleshooting Index ->](../../../../docs/troubleshooting-index.md)

[STACK DOC: Shared Observability Stack ->](../README.md)

[GRAFANA DOC: Grafana ->](../grafana/README.md)

## Issue summary

After deploying the service dashboard to AKS, several Grafana panels appeared
empty:

- `Request volume`
- `Successful vs error requests`
- `HikariCP connections`
- `JDBC active connections`

At the same time, another panel such as `404 visibility` still returned data.

This made it look like part of the dashboard or part of the application metrics
pipeline was broken.

## Confirmed root cause

The empty panels were still using Prometheus queries hardcoded to the local
namespace:

```promql
namespace="payment-exception-review-local"
```

That label works only in the local environment.

On AKS, the application is deployed into a different namespace, so those
queries return no series even though the application, Prometheus scrape, and
Grafana datasource are healthy.

The `404 visibility` panel still worked because it already used an
application-level job filter instead:

```promql
job=~".*payment-exception-review.*"
```

## Why it happened here

The dashboard was originally authored and validated against the local platform
path, then later reused on AKS.

Some queries had already been generalized to use application-level labels, but
others were still pinned to the local namespace and therefore did not survive
the environment move.

This is an environment-specific query design issue, not an Azure PostgreSQL
problem and not a Grafana rendering problem.

## Diagnosis checklist

1. Open the empty panels and inspect the PromQL expression.
2. If you see:

```promql
namespace="payment-exception-review-local"
```

that query is local-only.

3. Compare it with a working panel such as:

```promql
sum by (status) (
  rate(http_server_requests_seconds_count{
    job=~".*payment-exception-review.*"
  }[5m])
)
```

4. Confirm the application metrics exist on AKS with broader queries:

```promql
sum(rate(http_server_requests_seconds_count[5m]))
hikaricp_connections
jdbc_connections_active
```

5. If those broader queries return data, the metrics pipeline is healthy and
   the panel filter is the issue.

## Broken expressions

Examples of the local-only queries that failed on AKS:

```promql
sum(rate(http_server_requests_seconds_count{
  namespace="payment-exception-review-local"
}[5m]))
```

```promql
sum by (status) (
  rate(http_server_requests_seconds_count{
    namespace="payment-exception-review-local"
  }[5m])
)
```

```promql
hikaricp_connections{namespace="payment-exception-review-local"}
```

```promql
jdbc_connections_active{namespace="payment-exception-review-local"}
```

## Repository fix

The dashboard was updated to use the same application-level job regex pattern
already used by the working panel:

```promql
sum(rate(http_server_requests_seconds_count{
  job=~".*payment-exception-review.*"
}[5m]))
```

```promql
sum by (status) (
  rate(http_server_requests_seconds_count{
    job=~".*payment-exception-review.*"
  }[5m])
)
```

```promql
hikaricp_connections{job=~".*payment-exception-review.*"}
```

```promql
jdbc_connections_active{job=~".*payment-exception-review.*"}
```

This makes the dashboard work across local and AKS as long as the job naming
stays aligned with the application release.

## Recovery runbook

1. Update the dashboard JSON in:

```text
reliability/observability/grafana/dashboards/payment-exception-review-service-health.json
```

2. Re-apply the Grafana dashboard provisioning folder:

```bash
kubectl apply -k platform/kubernetes-resources/observability/grafana
```

3. Refresh Grafana.
4. Recheck the previously empty panels.

## Interpretation

When some service-health panels are empty on AKS while others still show data,
do not assume PostgreSQL, Prometheus, or Grafana is partially broken.

First check whether the empty queries are still tied to:

- a local-only namespace
- or another environment-specific label

In this case, the right fix was to generalize the panel filters so they follow
the application identity rather than a single local namespace.
