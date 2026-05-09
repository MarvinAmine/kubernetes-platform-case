# Scenario 2: Prometheus API Query Validation Fails

[UP: Observability Troubleshooting ->](./README.md)

[ROOT INDEX: Troubleshooting Index ->](../../../../docs/troubleshooting-index.md)

[STACK DOC: Shared Observability Stack ->](../README.md)

## Symptom

This call failed:

```bash
curl http://127.0.0.1:9090/api/v1/query
```

with an error like:

```json
{"status":"error","errorType":"bad_data","error":"invalid parameter \"query\": unknown position: parse error: no expression found in input"}
```

## Diagnosis

Prometheus was healthy.

The problem was only that the API endpoint requires a real PromQL expression
in the `query` parameter.

## Working validation

```bash
curl 'http://127.0.0.1:9090/api/v1/query?query=up'
curl http://127.0.0.1:9090/api/v1/targets
```

## Interpretation

- `http://127.0.0.1:9090` responding is a good sign
- `api/v1/query` without `query=...` is invalid
- `api/v1/targets` is useful to confirm scrape targets are registered and `UP`
