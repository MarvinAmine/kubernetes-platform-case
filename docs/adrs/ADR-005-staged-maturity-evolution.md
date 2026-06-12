# ADR-005 - Keep the Overall Case Staged and Maturity-Driven

## Status

Accepted

## Context

The repository is designed as a staged maturity case:

- Stage 1 for delivery credibility
- Stage 2 for governance and shared-platform credibility
- Stage 3 for enterprise and hybrid-platform credibility
- Stage 4+ for formal compliance and enterprise risk operations credibility

Without explicit staging, the project risks becoming a flat collection of tools rather than a coherent operating-model evolution.

## Decision

The case evolves through deliberate maturity stages:

- **Stage 1**: Infrastructure + Platform + Application
- **Stage 2**: add Security/IAM explicitly
- **Stage 3**: add SRE / Production Engineering explicitly
- **Stage 4+**: add formal Compliance / Risk / SOC / Audit program scope explicitly

Each stage adds capabilities only when they materially support the next maturity objective.

Stage 4+ is intentionally separated from Stage 3. Stage 3 can be
compliance-aware and enterprise-integration-aware, but it should not claim a
formal ISO, NIST, SOC 2, PCI DSS, ISO/IEC 20000, SIEM/SOC, or enterprise risk
program implementation.

## Consequences

### Positive

- the project stays finishable
- the story remains coherent for recruiters and hiring managers
- each stage has a defendable purpose
- future additions like Vault, ArgoCD, Okta, Microsoft Entra ID, Active
  Directory / AD DS, hybrid identity, hybrid cloud, SIEM/SOC integration, and
  formal compliance work fit into a clear maturity model

### Negative

- some readers may expect later-stage capabilities earlier
- the repo must be explicit about what is current scope versus planned evolution

## Alternatives considered

### Add all technologies to Stage 1

Rejected because it would create shallow breadth instead of credible depth.

### Keep all stages informal

Rejected because the maturity path is one of the main strengths of the case and should be explicit.
