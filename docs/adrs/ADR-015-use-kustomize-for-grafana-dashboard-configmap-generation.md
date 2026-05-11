# ADR-015 - Use Kustomize for Grafana Dashboard ConfigMap Generation

## Status

Accepted

## Context

Stage 1 now includes Grafana dashboards as part of the shared observability
story. Those dashboards are authored first in the Grafana UI, exported as JSON,
and then committed to the repository as code.

The repository needs a clean way to turn those JSON files into Kubernetes
`ConfigMap` objects that the `kube-prometheus-stack` Grafana sidecar can load.

The solution needs to stay aligned with Stage 1 goals:

- dashboards remain versioned and reviewable in Git
- the source of truth stays readable
- provisioning stays Kubernetes-native
- the design stays credible for regulated and governed environments
- the solution does not overload the Helm layer with large static JSON content

## Decision

Use **Kustomize** to generate Grafana dashboard `ConfigMap` objects from the
dashboard JSON files stored in the repository.

The intended Stage 1 split is:

- Helm installs the shared `kube-prometheus-stack`
- dashboard JSON files stay under the Grafana dashboard folder
- Kustomize generates stable dashboard `ConfigMap` objects from those files
- the platform-owned observability lifecycle applies those generated resources

## Consequences

### Positive

- dashboard JSON stays separate from Kubernetes wrapping
- large inline YAML blobs are avoided
- Git diffs stay cleaner and easier to review
- the generated `ConfigMap` objects remain deterministic
- the approach is Kubernetes-native and easy to integrate with later GitOps
- ownership stays clear: Helm for the shared stack, Kustomize for the extra
  dashboard resources

### Negative

- the observability path now uses both Helm and Kustomize
- operators must understand one additional Kubernetes-native packaging tool
- there is one more apply/delete step to integrate into the observability
  lifecycle

## Alternatives considered

### Inline dashboard JSON directly inside tracked ConfigMap YAML

Rejected because the manifests become long, noisy, and hard to review.

### Helm template the dashboard JSON into ConfigMaps

Rejected as the primary approach because Helm is better suited to parameterized
templates than to large mostly static dashboard JSON files.

### Manage dashboards only through the Grafana UI

Rejected because the UI is useful for authoring, but not as the long-term
source of truth in a governed environment.
