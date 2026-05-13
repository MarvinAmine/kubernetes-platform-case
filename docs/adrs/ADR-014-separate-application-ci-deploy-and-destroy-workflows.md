# ADR-014: Separate application CI, deploy, and destroy workflows

## Status

Accepted

## Context

The repository now includes a dedicated application validation workflow for the Spring Boot service.

As the delivery path matures, the repository will also need:

- an application deployment workflow
- an application destruction workflow

It would be possible to combine validation, deployment, and teardown into a single GitHub Actions workflow, but that would make the workflow harder to reason about and would mix very different operational concerns.

These concerns do not have the same purpose, trigger model, or risk profile:

- CI validation should be fast, safe, and routine
- deployment should be environment-aware and use more privileged credentials
- destruction should be explicit, manual, and tightly controlled

## Decision

The repository will use separate GitHub Actions workflows for the application lifecycle:

- `application-app-ci.yml` for compile, test, and verify
- `application-app-deploy.yml` for application delivery into Kubernetes
- `application-app-destroy.yml` for explicit application teardown

The application CI workflow is allowed to run automatically on `push` and `pull_request`.

The deployment workflow may later run from `workflow_dispatch` and can evolve toward controlled promotion automation if needed.

The destroy workflow should remain explicitly manual by default.

## Consequences

Positive:

- validation remains fast and easy to trust
- deployment permissions stay separate from normal CI execution
- destructive actions are clearer and easier to audit
- troubleshooting is simpler because validation, deployment, and teardown failures are isolated

Negative:

- more workflow files must be maintained
- the delivery path is split across multiple pipeline definitions

## Rationale

This repository is intentionally designed to demonstrate controlled delivery, operational discipline, and clear team boundaries.

Separating application CI, deployment, and destruction workflows is consistent with that goal because it makes operator intent explicit and avoids hiding privileged or destructive actions inside a routine validation pipeline.
