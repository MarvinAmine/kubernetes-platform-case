# Interview Notes

## Purpose

This document is a compact interview aid for discussing the Stage 1 platform
case.

It is not a runbook.
It is not a detailed architecture guide.

Its purpose is to help explain:

- what the project demonstrates
- why the design was split the way it was
- what tradeoffs were made
- what problems were solved in practice

## One-Minute Project Summary

This project is a staged Kubernetes platform case for a regulated internal
service.

Stage 1 demonstrates how:

- an **Infrastructure team** provisions the Azure foundation with Terraform
- a **Platform team** bootstraps the governed Kubernetes runtime and shared
  observability layer
- an **Application team** deploys a Spring Boot service through GitHub
  Actions, GHCR, Docker, and Helm

The service is intentionally small, but the operating model is designed to
feel realistic for regulated environments.

## What Stage 1 Proves

- Terraform can bootstrap a governed Azure and AKS foundation
- Kubernetes resources can be split cleanly between infrastructure, platform,
  and application ownership
- a Java service with a real PostgreSQL dependency can be deployed through a
  controlled CI/CD path
- shared observability can be installed once at platform level instead of
  duplicated per application
- realistic rollout and configuration failures can be diagnosed with probes,
  logs, metrics, and runbooks

## How AI Is Used

The project uses AI as an accelerator for planning, draft generation, and
tradeoff analysis, but not as a replacement for ownership.

Strong answer:

- AI helps explore options faster
- important code and design decisions are still reviewed deliberately
- critical implementation paths are often rewritten or retyped manually to
  improve retention and authorship
- the target is not just output speed, but being able to explain and defend
  the final design without depending on AI in the room

## Core Design Choices

### Three-team operating model

Why:

- it reflects how real organizations separate concerns
- it makes ownership boundaries explicit
- it avoids pretending one team owns everything

### Separate infrastructure and platform Terraform layers

Why:

- Azure foundation and Kubernetes bootstrap do not have the same ownership
- platform changes should not require reopening the full infrastructure layer
- the separation makes the repo easier to explain and safer to evolve

### Shared observability stack

Why:

- Prometheus, Grafana, and Alertmanager are better treated as platform
  services in this case
- it reduces duplication across applications
- it is a better fit for regulated environments with stronger governance needs

### Backend bootstrap outside the normal GitHub Actions chain

Why:

- Terraform needs the remote backend before the normal cloud workflows can use
  remote state
- backend creation is a bootstrap concern, not a day-two delivery concern

## Good Interview Talking Points

### Why AKS?

- it gives a realistic managed Kubernetes target
- it keeps the Stage 1 cloud story concrete
- it supports later progression toward broader hybrid-platform discussions

### Why Helm?

- it gives a standard application packaging model
- it keeps deployment inputs explicit
- it fits the separation between application-owned manifests and
  environment-specific runtime values

### Why local and dev paths?

- local reduces cost and iteration time
- dev proves the same model on a real managed Kubernetes platform
- shared cluster-generic scripts make the portability story stronger

### Why not one giant script for everything?

- because local, dev, cloud-specific, and cluster-generic concerns should not
  be mixed
- the repo now separates:
  - local wrappers
  - dev wrappers
  - shared cluster logic
  - cloud-only validation and access logic

### Why not one observability stack per application?

- it would duplicate Prometheus, Grafana, storage, dashboards, and upgrade
  effort
- the shared stack is the better default unless strict tenancy or compliance
  requirements justify a separate stack

## Real Problems Encountered

### Local observability timeout

Issue:

- `kube-prometheus-stack` initially failed with `context deadline exceeded`
  during local installation

Root cause:

- Grafana was still initializing when Helm timed out

Fix:

- confirm pod state in `monitoring`
- wait for Grafana to become ready
- increase the shared Helm timeout to `600s`

### Prometheus API validation confusion

Issue:

- calling `/api/v1/query` without a `query=` parameter returned an error

Fix:

- use a real query such as:
  - `curl 'http://127.0.0.1:9090/api/v1/query?query=up'`

### Grafana datasource confusion

Issue:

- using `127.0.0.1:9090` inside Grafana is wrong

Fix:

- Grafana should use the in-cluster Prometheus service:
  - `http://kube-prometheus-stack-prometheus.monitoring:9090`

## Good Questions To Expect

### “Why did you split infrastructure and platform?”

Strong answer:

- because Azure foundation ownership and Kubernetes bootstrap ownership are not
  the same thing
- the split makes the repo match a real team operating model
- it improves change safety and makes the responsibilities easier to explain

### “How is the database password handled?”

Strong answer:

- the source of truth is `POSTGRES_ADMIN_PASSWORD`
- locally it comes from `.env`
- in GitHub Actions it comes from a repository secret
- Azure provisioning uses it as
  `TF_VAR_postgres_admin_password`
- the platform layer injects it into Kubernetes as
  `payment-review-db / POSTGRES_ADMIN_PASSWORD`
- the application Helm release consumes that existing secret

### “How do you validate the platform locally?”

Strong answer:

- create a local Kubernetes cluster
- run the local platform and app scripts
- port-forward the app, Prometheus, and Grafana
- validate health, metrics, targets, datasource connectivity, and the API
  response path

### “What would you do next?”

Strong answer:

- add Kubernetes-managed Grafana dashboards
- extend alerting
- harden internal access patterns in later stages
- consider Terragrunt in the later hybrid and multi-environment stages if the
  Terraform stack count and shared wiring become noisy
- continue toward stronger GitOps, secrets management, and hybrid-platform
  maturity

## What Not To Oversell

- this is not a full banking platform
- Stage 1 does not yet implement a full internal ingress path
- Stage 1 does not yet include Vault, ArgoCD, OpenShift, or enterprise IAM
- the value is the operating model, separation of responsibilities, delivery
  path, and troubleshooting credibility

## References

- [README.md](./README.md)
- [stage1.md](./stage1.md)
- [ai-collaboration-model.md](./ai-collaboration-model.md)
- [sre-portfolio-leverage.md](./sre-portfolio-leverage.md)
- [executive-summary.md](./executive-summary.md)
- [github-actions-workflows.md](./github-actions-workflows.md)
- [local-platform-and-app-validation.md](./local-platform-and-app-validation.md)
