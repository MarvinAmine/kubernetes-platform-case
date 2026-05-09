# Scenario 1: Helm Install Returns `context deadline exceeded`

[UP: Observability Troubleshooting ->](./README.md)

[ROOT INDEX: Troubleshooting Index ->](../../../../docs/troubleshooting-index.md)

[STACK DOC: Shared Observability Stack ->](../README.md)

## Symptom

The shared observability installation failed with:

```text
Error: context deadline exceeded
ERROR: Shared observability stack installation failed
```

## What was already healthy

- Prometheus
- Alertmanager
- Prometheus Operator
- node-exporter

## What was still initializing

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

## Diagnosis

This was a local startup timing issue, not a broken configuration by default.

Grafana was still pulling and starting while Helm was waiting for the whole
stack to become ready.

## Validation commands

```bash
kubectl get pods -n monitoring -w
kubectl get events -n monitoring
kubectl describe pod -n monitoring <grafana-pod-name>
```

## Resolution

Wait for Grafana to reach:

```text
3/3 Running
```

Then continue with the application deployment:

```bash
./application/payment-exception-review-service/create_local_app_with_helm.sh -s
```

## Interpretation

On a first local run, `context deadline exceeded` during
`kube-prometheus-stack` installation does not automatically mean the platform
setup is broken.

If Grafana is the only component still initializing:

1. wait for the monitoring pods to settle
2. confirm Grafana becomes `Running`
3. continue with the local application deployment
