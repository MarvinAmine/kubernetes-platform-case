# Observability Troubleshooting

[MAIN DOC: Shared Observability Stack ->](./README.md)

This file captures real troubleshooting scenarios encountered while validating
the shared Prometheus and Grafana stack.

## Scenario 1: Helm install returns `context deadline exceeded`

### Symptom

The shared observability installation failed with:

```text
Error: context deadline exceeded
ERROR: Shared observability stack installation failed
```

### What was already healthy

- Prometheus
- Alertmanager
- Prometheus Operator
- node-exporter

### What was still initializing

- Grafana

Example:

```bash
kubectl get pods -n monitoring
```

```text
alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running
kube-prometheus-stack-grafana-...                           0/3     PodInitializing
kube-prometheus-stack-kube-state-metrics-...                1/1     Running
kube-prometheus-stack-operator-...                          1/1     Running
kube-prometheus-stack-prometheus-node-exporter-...          1/1     Running
prometheus-kube-prometheus-stack-prometheus-0               2/2     Running
```

### Diagnosis

This was a local startup timing issue, not a broken configuration by default.

Grafana was still pulling and starting while Helm was waiting for the whole
stack to become ready.

### Validation commands

```bash
kubectl get pods -n monitoring -w
kubectl get events -n monitoring
kubectl describe pod -n monitoring <grafana-pod-name>
```

### Resolution

Wait for Grafana to reach:

```text
3/3 Running
```

Then continue with the application deployment:

```bash
./application/payment-exception-review-service/create_local_app_with_helm.sh -s
```

### Interpretation

On a first local run, `context deadline exceeded` during
`kube-prometheus-stack` installation does not automatically mean the platform
setup is broken.

If Grafana is the only component still initializing:

1. wait for the monitoring pods to settle
2. confirm Grafana becomes `Running`
3. continue with the local application deployment

## Scenario 2: Prometheus API query validation fails

### Symptom

This call failed:

```bash
curl http://127.0.0.1:9090/api/v1/query
```

with an error like:

```json
{"status":"error","errorType":"bad_data","error":"invalid parameter \"query\": unknown position: parse error: no expression found in input"}
```

### Diagnosis

Prometheus was healthy.

The problem was only that the API endpoint requires a real PromQL expression
in the `query` parameter.

### Working validation

```bash
curl 'http://127.0.0.1:9090/api/v1/query?query=up'
curl http://127.0.0.1:9090/api/v1/targets
```

### Interpretation

- `http://127.0.0.1:9090` responding is a good sign
- `api/v1/query` without `query=...` is invalid
- `api/v1/targets` is useful to confirm scrape targets are registered and `UP`

## Scenario 3: Grafana datasource validation fails

### Symptom

Grafana datasource testing did not validate when using:

```text
http://127.0.0.1:9090
```

It was also easy to create an unnecessary duplicate Prometheus datasource
manually, even though Grafana already had a default datasource provisioned by
the shared stack.

### Diagnosis

`127.0.0.1` inside Grafana refers to the Grafana container itself, not the
laptop shell where the Prometheus port-forward is running.

Grafana must reach Prometheus through the in-cluster Kubernetes service.

### Correct datasource URL

```text
http://kube-prometheus-stack-prometheus.monitoring:9090
```

Default datasource example:

![Local Kubernetes Grafana default data sources](../../../assets/local_kubernetes_grafana_default_data_sources.png)

### Good validation sequence

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

### Interpretation

- local port-forward is for your workstation validation
- in-cluster service DNS is for Grafana datasource validation
- the default Grafana datasource created by `kube-prometheus-stack` should be
  reused rather than duplicated

[NEXT: Return to the shared observability overview ->](./README.md)
