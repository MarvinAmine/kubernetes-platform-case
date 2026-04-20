# Failure Scenarios

This document captures the two main Stage 1 failure scenarios that support realistic troubleshooting.

## Scenario 1 - Bad readiness probe

### Symptom

The pod starts but never becomes ready.

### Impact

Traffic is not routed to the application and the rollout appears blocked.

### Detection

- `kubectl rollout status`
- `kubectl describe pod`
- Kubernetes events
- readiness probe failures

### Root cause

The readiness probe points to the wrong path or port.

### Fix

Correct the readiness probe configuration so it targets the proper Actuator readiness endpoint.

### Validation

- the pod transitions to `Ready`
- rollout completes
- smoke test succeeds

## Scenario 2 - Invalid business configuration

### Symptom

The application fails at startup or never reaches a healthy ready state.

### Impact

The service cannot serve traffic and deployment fails.

### Detection

- container logs
- rollout status
- pod restart behavior
- failed startup validation

### Root cause

A configuration value is unsupported, for example:

- `VALIDATION_MODE=AGGRESSIVE`

when only `STRICT` and `STANDARD` are supported.

### Fix

Restore a supported configuration value and redeploy.

### Validation

- application starts successfully
- health endpoint returns success
- config-check endpoint returns a valid response
