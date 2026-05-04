# Internal Access Future Direction

[MAIN DOC: Stage 1 of 3 - Governed AKS delivery foundation for an internal payment review service ->](./README.md)

This note preserves the earlier internal access architecture direction that was
removed from the Stage 1 Mermaid diagram when the diagram was updated to
reflect the actual implemented Stage 1 access path.

## Why this note exists

The current Stage 1 implementation is accurately represented as:

- internal developer access
- Azure CLI authentication
- `kubectl` context access
- `kubectl port-forward`
- access to internal `ClusterIP` services inside AKS

That is the right picture for the current implementation.

But there was also an earlier, more forward-looking access model:

- internal consumer
- corporate network / VPN
- private DNS
- internal application gateway
- routed access into AKS-hosted services

That model is still useful as a future direction. It was simply too early to
show it as if it were already implemented in Stage 1.

## Current Stage 1 access model

Stage 1 currently behaves like a secure internal developer validation
environment.

Typical access path:

- internal developer
- Azure CLI login
- `az aks get-credentials`
- `kubectl config use-context`
- `kubectl port-forward`
- local validation of application and observability endpoints

This is consistent with:

- `ClusterIP` services
- private-by-default service exposure
- operator-oriented validation instead of broad internal endpoint exposure

## Future internal access direction

The earlier architecture direction remains relevant for later stages.

That future-facing access path looks like:

- internal consumer or internal developer
- corporate network / VPN
- private DNS
- internal application gateway or governed internal ingress
- routed access to AKS workloads

This is the more realistic long-term internal service exposure model once the
platform moves beyond operator-only validation and toward broader internal
consumer access patterns.

## Where this belongs

This direction is better aligned with later-stage maturity work such as:

- stronger internal ingress patterns
- more explicit private DNS integration
- governed internal service exposure standards
- more formal internal application entry paths

Those concerns are intentionally treated as later-stage work rather than core
Stage 1 implementation requirements.

## Simple interpretation

Use this rule:

- Stage 1 diagram = actual implemented access path
- future internal access note = planned later-stage access direction

That keeps the Stage 1 architecture honest while preserving the broader
platform design direction for later steps.
