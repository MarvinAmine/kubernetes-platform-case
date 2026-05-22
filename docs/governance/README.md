# Governance Documentation

[MAIN DOC: Stage 1 of 3 - Governed AKS delivery foundation for an internal payment review service ->](../README.md)

This folder captures high-level direction that would normally come from product,
architecture, risk, compliance, platform leadership, or service ownership
forums.

It is not an implementation folder.
It defines constraints before tools are selected.

Implementation teams consume these directives:

- `infrastructure/` implements infrastructure boundaries
- `platform/` implements platform controls
- `application/` implements service behavior
- `reliability/` operationalizes service-level targets, runbooks, and validation
- `.github/workflows/` automates validation and promotion evidence

## Stage 2 use

Stage 2 uses governance documents to define shared-platform constraints before
tools are added.

Examples:

- approved environment model
- cluster isolation model
- production isolation rule
- promotion policy
- GitHub workflow evolution rule
- service-level target direction
- MTTR target
- SLA boundary
- compliance boundary
- artifact promotion rule

## Stage 3+ use

Later stages can expand this area with:

- certification-environment governance
- control owners
- compliance mappings
- audit evidence model
- ITSM / CAB direction
- risk register
