# ADR-007 - Use the Main Infrastructure Workflow for Managed Azure PostgreSQL

## Status

Accepted

## Context

Stage 1 includes PostgreSQL as a real service dependency.

The key architectural question is whether managed Azure PostgreSQL should:

- get its own dedicated GitHub Actions workflow, or
- be provisioned through the same infrastructure workflow that already manages the resource group and AKS cluster

The ownership model for Stage 1 places managed Azure PostgreSQL under the Infrastructure team, alongside the rest of the foundational Azure estate.

## Decision

Managed Azure PostgreSQL should be provisioned through the **same infrastructure workflow** that manages the Azure resource group and AKS cluster.

It is treated as part of the same Infrastructure team ownership boundary rather than as a separate workflow domain.

## Consequences

### Positive

- infrastructure ownership stays coherent
- the Azure foundation remains grouped under one reviewed IaC path
- PostgreSQL is treated as a normal managed infrastructure service instead of an artificial special case
- the workflow model stays simpler in Stage 1

### Negative

- the main infrastructure workflow becomes broader
- later stages may require more modular decomposition if database lifecycle controls become stricter

## Alternatives considered

### Create a dedicated PostgreSQL workflow

Rejected for Stage 1 because the database belongs to the same infrastructure ownership boundary as the AKS and Azure foundation.

### Keep PostgreSQL entirely outside infrastructure automation

Rejected because it weakens the credibility and repeatability of the platform case.
