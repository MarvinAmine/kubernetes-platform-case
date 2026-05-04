# Kubernetes Portability Note

[MAIN DOC: Stage 1 of 3 - Governed AKS delivery foundation for an internal payment review service ->](./README.md)

This note explains why the repository uses Kubernetes-managed resources for
platform and observability work, and what that means for portability across
local, cloud, and on-prem Kubernetes environments.

## Why this matters

The practical benefit of managing platform and observability components as
Kubernetes resources is that they can usually be validated locally first and
then reused in AKS, EKS, OpenShift, OKD, or on-prem Kubernetes with limited
changes.

This is one of the reasons the repository uses:

- Helm-managed application deployment
- Kubernetes-managed observability installation
- Grafana dashboard ConfigMaps
- Prometheus `ServiceMonitor` resources

## What is usually portable

The following resource types and patterns are usually highly portable across
Kubernetes environments:

- namespaces
- ConfigMaps
- Secrets
- Deployments
- Services
- Helm values patterns
- Grafana dashboard ConfigMaps
- Prometheus `ServiceMonitor` resources when Prometheus Operator exists there too

## What may vary by environment

The following concerns often need environment-specific adjustment:

- storage classes
- ingress controllers
- load balancer behavior
- security policies
- OpenShift SCC specifics
- cloud IAM integrations
- DNS and certificates
- operator availability and versions

## Practical interpretation

So the portability model is strong, but not absolute.

That means:

- local validation is meaningful
- AKS validation is meaningful
- later promotion to EKS, OpenShift, OKD, or on-prem Kubernetes is credible
- some integration details still need adaptation per environment

This is the right tradeoff for the repository because it gives realistic
cross-environment credibility without pretending that every Kubernetes cluster
behaves identically.

## OKD clarification

`OKD` is the community distribution upstream of OpenShift.

A simple way to think about it is:

- `OpenShift` is the enterprise Red Hat product
- `OKD` is the upstream community platform in the same family

In this repository:

- `OpenShift` is the stronger enterprise signal for Stage 2 discussions
- `OKD` is still relevant when discussing portability, local labs, or upstream
  compatibility in the same platform family
