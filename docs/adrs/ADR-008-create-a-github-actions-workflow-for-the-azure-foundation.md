# ADR-008 - Create a GitHub Actions Workflow for the Azure Foundation

## Status

Accepted

## Context

Stage 1 must show a credible, reviewable, and repeatable infrastructure delivery path.

The Azure foundation includes the managed resources that support the governed Kubernetes environment, notably:

- the Azure resource group
- the AKS cluster
- later, the managed Azure PostgreSQL service within the same ownership boundary

To support a realistic Infrastructure team workflow, these changes should be validated and applied through a standard CI/CD path rather than through ad hoc local-only execution.

## Decision

The repository uses a **GitHub Actions workflow** for the Azure infrastructure layer.

That workflow is the standard CI/CD path for reviewing and applying changes to the Azure foundation managed by the Infrastructure team.

## Consequences

### Positive

- infrastructure changes become reviewable and auditable
- the repo demonstrates a realistic enterprise IaC workflow
- the Infrastructure team path is separated from the application delivery path
- the project gains stronger platform-case credibility

### Negative

- the repository now has to manage workflow variables, secrets, and permissions for infrastructure delivery
- the infrastructure path becomes more dependent on GitHub Actions and Azure identity setup

## Alternatives considered

### Use local CLI execution only

Rejected because it weakens the CI/CD and review story for infrastructure.

### Delay infrastructure automation to a later stage

Rejected because controlled infrastructure delivery is one of the core Stage 1 signals.
