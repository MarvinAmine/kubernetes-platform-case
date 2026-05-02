# Scenario 2 - Invalid business configuration

## Symptom

The application fails at startup or never reaches a healthy ready state.

## Impact

The service cannot serve traffic and deployment fails.

## Detection

- container logs
- rollout status
- pod restart behavior
- failed startup validation

## Root cause

A configuration value is unsupported, for example:

- `VALIDATION_MODE=AGGRESSIVE`

when only `STRICT` and `STANDARD` are supported.

## Fix

Restore a supported configuration value and redeploy.

## Validation

- application starts successfully
- health endpoint returns success
- config-check endpoint returns a valid response
