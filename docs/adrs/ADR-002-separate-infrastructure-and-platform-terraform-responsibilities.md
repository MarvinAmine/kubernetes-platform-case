# ADR-002 - Separate Infrastructure and Platform Terraform Responsibilities

## Status

Accepted

## Context

Stage 1 provisions multiple layers:

- the remote Terraform backend
- Azure infrastructure such as the resource group and AKS cluster
- Kubernetes resources such as namespace, service account, RBAC, and baseline configuration

Earlier wording treated these as one generic Terraform domain. That was inaccurate for the ownership model the project is trying to demonstrate.

## Decision

Terraform responsibilities are split by layer:

- `infrastructure/terraform-backend` and `infrastructure/azure` belong to the **Infrastructure team**
- `infrastructure/kubernetes-resources` belongs to the **Platform team**

The platform layer is intentionally modeled as a consumer of prepared infrastructure rather than the creator of the raw cloud estate.

## Consequences

### Positive

- ownership aligns with the real purpose of each Terraform layer
- the repo better illustrates how teams hand off from cloud foundation to governed runtime
- it becomes easier to explain why namespace/RBAC/bootstrap resources are not the same as AKS provisioning

### Negative

- more documentation and diagrams must reflect the split accurately
- some readers may initially expect all Terraform code to live under one team

## Alternatives considered

### All Terraform belongs to the Platform team

Rejected because it hides the distinction between infrastructure provisioning and platform provisioning.

### All Terraform belongs to the Infrastructure team

Rejected because Kubernetes namespace, RBAC, and runtime conventions are part of the governed application boundary, not raw infrastructure.
