# Project Team Ownership Model

This document defines the team model used across the three stages of this project.

The goal is to stay credible for a large, highly regulated organization in Montreal without inventing unnecessary bureaucracy.

## 1. Core principle

This project uses a distinction between:

- **Infrastructure**: the foundational technical estate
- **Platform**: the governed, consumable capabilities built on top of that estate
- **Application**: the service logic delivered by product or service teams

That means **Infrastructure** and **Platform** are related, but they are not the same thing.

## 2. Core teams used in this project

### 2.1 Infrastructure team

Primary mission:
- Own the foundational cloud and infrastructure estate that supports the platform

Typical role names:
- Cloud Engineer
- Infrastructure Engineer
- Cloud Infrastructure Engineer
- Network Infrastructure Engineer
- Systems Engineer

Main ownership:
- Azure subscription-level foundations
- AKS cluster provisioning
- networking and connectivity foundations
- storage foundations
- managed PostgreSQL provisioning or base database hosting pattern
- remote Terraform backend
- foundational IAM wiring at infrastructure level

Typical deliverables in this project:
- Terraform for Azure infrastructure
- AKS cluster creation
- backend state storage
- OIDC/Azure access prerequisites

### 2.2 Platform team

Primary mission:
- Turn infrastructure into a governed delivery and runtime path that application teams can safely consume

Typical role names:
- Platform Engineer
- Kubernetes Platform Engineer
- Cloud Platform Engineer

Main ownership:
- namespace conventions
- service account and RBAC model
- workload onboarding standards
- Helm delivery conventions
- CI/CD paved-road standards
- observability defaults
- baseline ConfigMaps and Secret patterns
- runtime guardrails for applications

Typical deliverables in this project:
- Kubernetes bootstrap resources
- deployment standards
- application delivery path on AKS
- observability and operational defaults

### 2.3 Application team

Primary mission:
- Build, package, deploy, and operate the business service inside the governed platform boundary

Typical role names:
- Backend Engineer
- Software Engineer
- Java Developer
- Application Developer

Main ownership:
- Spring Boot service implementation
- API contract implementation
- domain logic
- schema usage inside the service boundary
- Docker image
- Helm chart values owned by the app
- application tests
- application troubleshooting

Typical deliverables in this project:
- Payment Exception Review Status API
- business configuration validation
- health endpoints
- metrics exposure
- delivery through the approved path

## 3. Supporting teams that improve credibility

These teams are realistic in a highly regulated organization, but they do not all need to be fully implemented in Stage 1.

### 3.1 Security and IAM team

Primary mission:
- Define and enforce identity, access, and secrets controls

Typical role names:
- Security Engineer
- Cloud Security Engineer
- IAM Engineer
- Application Security Engineer

When it becomes material:
- Stage 2 and later

Main ownership examples:
- identity provider integration
- secrets governance
- workload identity controls
- least-privilege review
- policy and access standards

### 3.2 SRE / Production Engineering team

Primary mission:
- Improve production reliability, observability, operability, and incident response readiness

Typical role names:
- Site Reliability Engineer
- Reliability Engineer
- Production Engineer in organizations that use Google's naming style

When it becomes material:
- Stage 2 and especially Stage 3

Main ownership examples:
- SLO and alerting design
- operational readiness
- incident response supportability
- reliability reviews
- capacity and resilience practices

### 3.3 Data platform or DBA team

Primary mission:
- Govern shared database platforms and data-operational controls when data services are centralized

Typical role names:
- Database Administrator (DBA)
- Database Engineer
- Database Reliability Engineer
- Data Platform Engineer when the team owns a broader shared data platform

When it becomes material:
- Only if PostgreSQL is treated as a centrally governed shared service rather than an app-local persistence concern

Main ownership examples:
- PostgreSQL standards
- backup and restore policy
- database hardening
- instance-level access and operations

## 4. Recommended team model by stage

### Stage 1

Use these teams explicitly:

- **Infrastructure team**
- **Platform team**
- **Application team**

Mention these as collaborating or future-stage actors, but do not force them into every deliverable:

- **Security and IAM team**
- **SRE / Production Engineering**

Why this is credible:
- large regulated organizations often separate raw foundations from platform enablement
- Stage 1 is stronger when it already shows that distinction
- adding too many active teams too early makes the case feel inflated

### Stage 2

Make these teams more explicit:

- Infrastructure team
- Platform team
- Application team
- Security and IAM team

This matches the stage where governance, secrets, identity, and stronger controls become part of the platform story.

### Stage 3

At this stage the broader operating model becomes credible:

- Infrastructure team
- Platform team
- Application team
- Security and IAM team
- SRE / Production Engineering

Optionally:
- Data platform / DBA team

Use the database team only if Stage 3 genuinely introduces centralized database operations or stronger data-governance controls.

## 5. Practical naming guidance for this repository

### In narrative documents

Use the three core names clearly:

- `Infrastructure team`
- `Platform team`
- `Application team`

### In service metadata

If the service exposes ownership metadata, it is reasonable to expose both:

- `infrastructureOwner`
- `platformOwner`

That is the most precise option if the goal is to show the distinction rather than collapse it.

### Why both fields are acceptable

They answer two different questions:

- `infrastructureOwner`: who owns the foundational technical estate supporting this service?
- `platformOwner`: who owns the governed runtime and delivery model the service consumes?

## 6. Recommendation for this project

To stay credible without overcomplicating the repo:

- **Stage 1 should explicitly model Infrastructure, Platform, and Application**
- **Stage 2 should bring Security/IAM into the operating model**
- **Stage 3 should make SRE/Production Engineering visible**

That progression is believable for a regulated Montreal organization and avoids pretending that every specialized enterprise team is already fully active in Stage 1.

## 7. Notes on role-title realism

- `Platform Engineer`, `Kubernetes Platform Engineer`, `Infrastructure Engineer`, `Cloud Infrastructure Engineer`, `IAM Engineer`, and `Site Reliability Engineer` are all current role titles visible in public job postings.
- `DevOps Engineer` still exists as a title, but it is often used as a broad hybrid role rather than a clean team boundary. It is better used sparingly in this repository.
- `Production Engineer` is a real title in some large organizations, but it is less universal than `Site Reliability Engineer`.
