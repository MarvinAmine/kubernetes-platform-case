# ADR-001 - Use a Three-Team Stage 1 Operating Model

## Status

Accepted

## Context

Stage 1 is meant to simulate a credible internal delivery model for a highly regulated organization.

Earlier drafts of the case compressed ownership into a two-team model, which blurred an important distinction:

- foundational infrastructure ownership
- governed platform ownership

That simplification weakened the realism of the repo because the Azure and AKS foundations, the Kubernetes application boundary, and the application delivery lifecycle do not represent the same scope of responsibility.

## Decision

Stage 1 uses three explicit teams:

- **Infrastructure team**
- **Platform team**
- **Application team**

The split is:

- the **Infrastructure team** bootstraps the foundational estate such as the resource group, AKS cluster, remote Terraform backend, and managed PostgreSQL foundation
- the **Platform team** provisions the governed Kubernetes application boundary and shared runtime conventions on top of that foundation
- the **Application team** builds, packages, deploys, and operates the Spring Boot service inside that governed boundary

## Consequences

### Positive

- Stage 1 better reflects enterprise operating models
- ownership boundaries become clearer in documentation and interviews
- the distinction between infrastructure and platform work is explicit instead of implied
- later stages can add Security/IAM and SRE without rewriting the Stage 1 foundation

### Negative

- the narrative becomes slightly more complex than a simple two-team story
- more documentation alignment is required across the repo

## Alternatives considered

### Two-team model: Platform + Application

Rejected because it collapses infrastructure and platform responsibilities into one role and makes the Azure/AKS foundation look less realistic.

### Single engineering team

Rejected because it removes the operating-model value of the case and makes the repo look more like a tutorial than a credible regulated-environment simulation.
