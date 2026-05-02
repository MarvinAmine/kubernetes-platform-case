# Scenario 1 - Bad readiness probe

## Symptom

The pod starts but never becomes ready.

## Impact

Traffic is not routed to the application and the rollout appears blocked.

## Detection

- `kubectl rollout status`
- `kubectl describe pod`
- Kubernetes events
- readiness probe failures

## Root cause

The readiness probe points to the wrong path or port.

## Fix

Correct the readiness probe configuration so it targets the proper Actuator readiness endpoint.

## Validation

- the pod transitions to `Ready`
- rollout completes
- smoke test succeeds
