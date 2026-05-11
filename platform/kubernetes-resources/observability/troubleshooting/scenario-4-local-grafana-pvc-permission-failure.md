# Scenario 4: Local Grafana PVC Permission Failure

[UP: Observability Troubleshooting ->](./README.md)

[ROOT INDEX: Troubleshooting Index ->](../../../../docs/troubleshooting-index.md)

[STACK DOC: Shared Observability Stack ->](../README.md)

## Issue summary

Grafana failed to start locally even though the rest of the
`kube-prometheus-stack` components were healthy.

Observed behavior:

- Prometheus was `Running`
- Alertmanager was `Running`
- the Prometheus Operator was `Running`
- Grafana stayed stuck in `Init:CrashLoopBackOff`

## Root cause

Grafana persistence was enabled and the init container failed while trying to
change ownership of the Grafana data directory mounted from the local PVC.

Init container:

- `init-chown-data`

Command:

- `chown -R 472:472 /var/lib/grafana`

Observed log output:

```bash
kubectl -n monitoring logs <grafana-pod> -c init-chown-data
```

```text
chown: /var/lib/grafana/pdf: Permission denied
chown: /var/lib/grafana/png: Permission denied
chown: /var/lib/grafana/csv: Permission denied
```

This means the local persistent volume contained files or permissions that the
Grafana init container could not correct.

## Why it happened here

This was observed on the local Kubernetes path where:

- Grafana persistence is enabled
- local storage is provided through the cluster's local path provisioner
- an older or stale local Grafana data directory can survive long enough to
  cause permission problems on a later reinstall

This is a local persistence hygiene issue, not a general Prometheus or AKS
design issue.

## Permanent local fix

The repository now treats this as a local-environment concern rather than a
reason to disable Grafana persistence everywhere.

Current design:

- local install path: Grafana persistence disabled
- dev / AKS install path: Grafana persistence remains enabled

This keeps local rebuilds fast and repeatable while preserving a more
production-shaped persistent Grafana setup in the governed cloud environment.

The local-only override lives in:

- `platform/kubernetes-resources/observability/grafana/kube-prometheus-stack-grafana-values-local.yaml`

and is consumed by:

- `platform/kubernetes-resources/observability/install_local_observability_stack.sh`

through the shared install path.

## Permanent fix validation

The local-only non-persistent Grafana design was validated with a real
Helm-triggered Grafana rollout after changing the chart values.

Observed result:

- the old Grafana pod terminated normally
- the replacement Grafana pod reached `3/3 Running`
- the previous `init-chown-data` failure did not return
- no `Permission denied` messages were observed

This confirms the repository fix works for the local lifecycle that previously
retriggered the PVC permission failure during reinstall or upgrade.

## Diagnosis checklist

Use these commands to confirm the issue:

```bash
kubectl -n monitoring get pods
kubectl -n monitoring describe pod -l app.kubernetes.io/name=grafana
kubectl -n monitoring logs <grafana-pod> -c init-chown-data
kubectl -n monitoring get pvc
kubectl -n monitoring get events --sort-by=.metadata.creationTimestamp
```

Signals that confirm this root cause:

- Grafana is the only unhealthy component
- init container `init-chown-data` is failing
- logs show `Permission denied` under `/var/lib/grafana`

## Recovery runbook

If you are still on the older persistent local setup or already hit the issue
before the local-only persistence override was applied:

1. uninstall the local observability release
2. delete the Grafana PVC if it still exists
3. reinstall the local observability stack

Commands:

```bash
helm uninstall kube-prometheus-stack -n monitoring
kubectl -n monitoring delete pvc kube-prometheus-stack-grafana --ignore-not-found
./create_local_platform_and_app.sh
```

If you want only the observability portion again:

```bash
./platform/kubernetes-resources/observability/install_local_observability_stack.sh
```

After the local override is in place, normal local reinstalls should no longer
need the PVC cleanup path unless an older persistent local release is still
being upgraded in place.

## Validation after recovery

Confirm:

```bash
kubectl -n monitoring get pods
kubectl -n monitoring get svc
```

Expected Grafana state:

```text
kube-prometheus-stack-grafana-...   3/3   Running
```

Validate local access again:

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
```

Then open:

```text
http://localhost:3000
```

## Interpretation

This issue does not mean the shared observability stack design is broken.

It means local Grafana persistence on `kind` was a poor fit for a disposable
developer validation path. The durable repository fix is to keep persistence in
dev and disable it locally.
