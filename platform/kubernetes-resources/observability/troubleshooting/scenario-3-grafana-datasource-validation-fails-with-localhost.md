# Scenario 3: Grafana Datasource Validation Fails With `127.0.0.1`

[UP: Observability Troubleshooting ->](./README.md)

[ROOT INDEX: Troubleshooting Index ->](../../../../docs/troubleshooting-index.md)

[STACK DOC: Shared Observability Stack ->](../README.md)

## Symptom

Grafana datasource testing did not validate when using:

```text
http://127.0.0.1:9090
```

It was also easy to create an unnecessary duplicate Prometheus datasource
manually, even though Grafana already had a default datasource provisioned by
the shared stack.

## Diagnosis

`127.0.0.1` inside Grafana refers to the Grafana container itself, not the
laptop shell where the Prometheus port-forward is running.

Grafana must reach Prometheus through the in-cluster Kubernetes service.

## Correct datasource URL

```text
http://kube-prometheus-stack-prometheus.monitoring:9090
```

## Good validation sequence

1. Port-forward Grafana:

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
```

2. Optionally port-forward Prometheus for local API checks:

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
```

3. Prove Prometheus is healthy from the laptop shell:

```bash
curl 'http://127.0.0.1:9090/api/v1/query?query=up'
curl http://127.0.0.1:9090/api/v1/targets
```

4. In Grafana, configure the datasource URL as:

```text
http://kube-prometheus-stack-prometheus.monitoring:9090
```

5. If a manual duplicate datasource was added, remove it and keep the
   provisioned default datasource.

6. Test a simple query:

```text
up
```

## Interpretation

- local port-forward is for your workstation validation
- in-cluster service DNS is for Grafana datasource validation
- the default Grafana datasource created by `kube-prometheus-stack` should be
  reused rather than duplicated
