# Executive Summary

## Project

**Regulated Payment Exception Review Platform**

This repository is a staged Kubernetes platform case built to demonstrate how a
regulated internal service can be provisioned, governed, observed, and
delivered through a realistic operating model.

Stage 1 focuses on one concrete outcome:

- turn internal service delivery from a fragile manual effort into a repeatable
  cloud and Kubernetes workflow

## What Stage 1 Proves

Stage 1 shows that three teams can collaborate through clear boundaries:

- the **Infrastructure team** provisions the Azure foundation with Terraform
- the **Platform team** bootstraps the governed Kubernetes runtime and shared
  observability layer
- the **Application team** builds and deploys a Spring Boot service through
  GitHub Actions, GHCR, Docker, and Helm

The resulting platform includes:

- a remote Terraform backend
- an Azure foundation with AKS and managed PostgreSQL
- a governed Kubernetes namespace and runtime boundary
- a shared Prometheus, Grafana, and Alertmanager stack
- a PostgreSQL-backed Spring Boot API
- documented failure scenarios and troubleshooting runbooks

## Why It Matters

This is not intended to be a consumer-facing payment product.

It is intended to demonstrate a credible internal enterprise operating model
for environments such as banking, insurance, or public-sector-adjacent
platforms where delivery is shaped by:

- infrastructure controls
- platform standards
- observability expectations
- stateful service dependencies
- operational troubleshooting requirements

## Delivery Model

The project intentionally separates:

- Azure foundation ownership
- Kubernetes platform ownership
- application delivery ownership

It also separates:

- local validation workflows
- dev cloud workflows
- shared Kubernetes logic reused across environments

This gives the repository a practical shape for discussing:

- Terraform state management
- AKS provisioning
- CI/CD workflow design
- Helm-based deployment
- RBAC and namespace bootstrap
- secret injection patterns
- observability as a shared platform service

## Current Stage 1 End State

At the end of Stage 1, the repository demonstrates:

- local platform and application validation on Kubernetes
- controlled Azure and AKS provisioning
- GitHub Actions workflows for Azure, Kubernetes resources, observability, and
  application deployment
- a working internal API with health, metrics, and persistent storage
- realistic production-style troubleshooting scenarios

## Next Stage Direction

Later stages expand this foundation toward:

- stronger platform governance
- deeper security and secret management
- stronger internal access patterns
- GitOps and policy-driven operations
- hybrid-cloud and OpenShift-oriented platform maturity

## Where To Go Next

- for the main technical entrypoint, see [README.md](./README.md)
- for the detailed Stage 1 narrative, see [stage1.md](./stage1.md)
- for the workflow order and prerequisites, see
  [github-actions-workflows.md](./github-actions-workflows.md)
