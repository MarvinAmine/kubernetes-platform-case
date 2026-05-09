# Stage 1 Remaining TODO

This document tracks the remaining implementation and validation work for
Stage 1.

The goal is to finish the Stage 1 platform in a controlled order instead of
adding features ad hoc.

## Status

Already implemented:

- remote Terraform backend bootstrap
- Azure foundation with AKS, networking, and managed PostgreSQL
- Kubernetes bootstrap layer
- shared observability stack
- Spring Boot application delivery
- local validation path
- dev validation path
- GitHub Actions workflows for Azure, Kubernetes resources, observability, and
  app deployment
- main architecture, runbooks, troubleshooting, and workflow documentation

Remaining Stage 1 work is now mostly platform polish and operational
completeness.

## Ordered checklist

### 1. Create Grafana dashboards as code

Goal:
- turn the current observability validation into reusable dashboards stored in
  the repository

Why it matters:
- dashboards become versioned
- local and dev stay aligned
- the platform demonstrates stronger operational maturity

Definition of done:
- at least one dashboard is provisioned through Kubernetes resources
- dashboard works locally
- dashboard works in AKS dev

Implementation note:
- keep the dashboard JSON in a separate file first
- do not commit a very long inline JSON blob directly as the primary authoring
  format
- create the dashboard in the Grafana UI, validate it, then export the JSON
  into the repository
- wire that JSON into the ConfigMap or generation logic afterward

Suggested first panels:
- service availability
- request volume
- request latency
- JVM basics
- HikariCP / JDBC pool health

### 2. Add meaningful alerting

Goal:
- move from passive observability to actionable platform monitoring

Why it matters:
- shared observability becomes more production-oriented
- the project demonstrates better operational judgment

Definition of done:
- alert rules exist as code
- at least a few useful alerts are defined
- alerts are documented even if downstream routing stays simple in Stage 1

Suggested first alerts:
- application target down
- repeated pod restart
- readiness failure
- database connectivity or startup failure symptoms

### 3. Finalize the manual-trigger GitHub Actions documentation

Goal:
- make the workflow usage obvious for readers and reviewers

Why it matters:
- the repo now has multiple workflow entry points
- the delivery story should be easy to follow without guesswork

Definition of done:
- manual trigger expectations are explicit in the workflow docs
- workflow order is explicit
- bootstrap vs normal workflow responsibilities are explicit

### 4. Finalize architecture artifacts

Goal:
- keep the visual architecture set aligned with the implemented Stage 1 model

Why it matters:
- the repo is now strong enough that diagrams are part of the project value
- future Stage 2 and Stage 3 evolution should be visually grounded

Definition of done:
- Stage 1 architecture artifacts reflect the current implemented access model
- Stage 2 architecture artifacts are clearly future-oriented
- stale or confusing visuals are removed or clarified

### 5. Run one final full lifecycle verification pass

Goal:
- prove that the full Stage 1 path still works end to end after the refactors

Why it matters:
- validates the local/dev/shared script split
- validates the GitHub Actions story against the shell workflow story
- catches path or documentation drift before Stage 2 work begins

Definition of done:
- local create and destroy path works
- dev create and destroy path works
- observability and app validation still pass

Suggested verification order:
- local platform and app create
- local platform and app destroy
- Azure and Kubernetes dev provision
- observability provision
- app deploy
- validation checks
- app destroy
- observability destroy
- Kubernetes resources destroy
- Azure destroy

## Deferred to later stages

These are important, but they are not required to call Stage 1 complete:

- full internal ingress model
- OpenShift
- ArgoCD
- Vault
- enterprise IAM integration
- hybrid-cloud expansion
- Terragrunt

## Working rule

For the remaining Stage 1 work:

- finish repository-backed dashboards before adding more platform sprawl
- add a small number of useful alerts before designing advanced routing
- prefer one complete, validated operational path over many partially finished
  enhancements
