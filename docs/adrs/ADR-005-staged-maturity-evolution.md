# ADR-005 - Keep the Overall Case Staged and Maturity-Driven

## Status

Accepted

## Context

The repository is designed as a three-stage case:

- Stage 1 for delivery credibility
- Stage 2 for governance and shared-platform credibility
- Stage 3 for enterprise and hybrid-platform credibility

Without explicit staging, the project risks becoming a flat collection of tools rather than a coherent operating-model evolution.

## Decision

The case evolves through deliberate maturity stages:

- **Stage 1**: Infrastructure + Platform + Application
- **Stage 2**: add Security/IAM explicitly
- **Stage 3**: add SRE / Production Engineering explicitly

Each stage adds capabilities only when they materially support the next maturity objective.

## Consequences

### Positive

- the project stays finishable
- the story remains coherent for recruiters and hiring managers
- each stage has a defendable purpose
- future additions like Vault, ArgoCD, Okta, and hybrid cloud fit into a clear maturity model

### Negative

- some readers may expect later-stage capabilities earlier
- the repo must be explicit about what is current scope versus planned evolution

## Alternatives considered

### Add all technologies to Stage 1

Rejected because it would create shallow breadth instead of credible depth.

### Keep all stages informal

Rejected because the maturity path is one of the main strengths of the case and should be explicit.
