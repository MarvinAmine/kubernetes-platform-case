# ADR-006 - Do Not Create a Standard GitHub Actions Workflow for the Remote Terraform Backend

## Status

Accepted

## Context

The repository uses a remote Terraform backend in Azure Storage.

That backend is a prerequisite for the normal Terraform execution model. Terraform needs the backend to exist before the standard plan and apply workflow can rely on it.

This makes the backend different from normal infrastructure resources such as the AKS cluster, resource group, or managed PostgreSQL service.

## Decision

The remote Terraform backend is **not** treated as a normal GitHub Actions-managed infrastructure workflow.

Instead, it remains a bootstrap concern handled through a dedicated bootstrap path rather than a standard day-to-day infrastructure workflow.

## Consequences

### Positive

- the backend chicken-and-egg problem remains explicit
- the normal infrastructure workflow can assume a valid remote state location already exists
- the repository stays aligned with common Terraform backend bootstrap practice

### Negative

- the backend follows a different execution pattern than the rest of the infrastructure
- documentation must explain why this special-case flow exists

## Alternatives considered

### Manage the backend through the same normal GitHub Actions workflow as the rest of the infrastructure

Rejected because the workflow itself depends on the backend being available.

### Provision the backend manually with no codified bootstrap flow

Rejected because it weakens repeatability and makes the bootstrap process harder to audit.
