# Generic Team Ownership Model

This document is a reusable reference for separating infrastructure, platform, application, security, reliability, and data ownership in modern software organizations.

It is not specific to this repository.

## 1. Purpose

Modern engineering organizations often use similar words for very different scopes of ownership.

This model separates those scopes so architecture, operating models, and service metadata stay clear.

## 2. Team definitions

### 2.1 Infrastructure team

Primary mission:
- Own the foundational technical estate

Typical role names:
- Cloud Engineer
- Infrastructure Engineer
- Cloud Infrastructure Engineer
- Network Infrastructure Engineer
- Systems Engineer

Common ownership:
- cloud accounts and subscriptions
- networking
- clusters and compute foundations
- storage foundations
- database hosting foundations
- foundational IAM and connectivity
- infrastructure-as-code for foundational resources

### 2.2 Platform team

Primary mission:
- Turn infrastructure into standardized capabilities that application teams can safely consume

Typical role names:
- Platform Engineer
- Kubernetes Platform Engineer
- Cloud Platform Engineer

Common ownership:
- paved-road deployment patterns
- workload onboarding standards
- CI/CD standards
- runtime guardrails
- namespace and RBAC conventions
- developer self-service capabilities
- observability defaults

### 2.3 Application team

Primary mission:
- Build and operate business-facing or internal services within the approved platform model

Typical role names:
- Software Engineer
- Backend Engineer
- Application Developer
- Java Developer

Common ownership:
- service logic
- APIs
- domain behavior
- application tests
- Docker and deployment artifacts owned by the app team
- service-level troubleshooting

### 2.4 Security and IAM team

Primary mission:
- Define and enforce identity, secrets, and security controls

Typical role names:
- Security Engineer
- Cloud Security Engineer
- IAM Engineer
- Application Security Engineer

Common ownership:
- identity provider integration
- secrets governance
- policy controls
- least-privilege reviews
- security standards for platform and applications

### 2.5 SRE / Reliability team

Primary mission:
- Improve production reliability, operability, and incident response readiness

Typical role names:
- Site Reliability Engineer
- Reliability Engineer
- Production Engineer in some organizations

Common ownership:
- service-level objectives
- reliability reviews
- observability and alerting maturity
- operational readiness
- incident response practices
- toil reduction through automation

### 2.6 Data platform or database team

Primary mission:
- Govern shared database and data-platform services when data operations are centralized

Typical role names:
- Database Administrator (DBA)
- Database Engineer
- Database Reliability Engineer
- Data Platform Engineer

Common ownership:
- shared database platforms
- backup and restore standards
- database hardening
- performance governance
- data-operational controls

## 3. Common boundary questions

### Infrastructure vs Platform

- `Infrastructure` owns the raw technical foundation
- `Platform` owns the governed, reusable capabilities built on top of that foundation

### Platform vs Application

- `Platform` owns the shared operating model
- `Application` owns the service that runs inside that model

### SRE vs Platform

- `Platform` improves the paved road
- `SRE` improves production reliability and operational readiness

In some organizations these are separate teams. In others they overlap.

## 4. Naming guidance

Use team names that match actual ownership, not aspirational terminology.

Examples:
- use `Infrastructure team` when the scope is raw cloud and network foundations
- use `Platform team` when the scope is delivery standards, runtime guardrails, and shared developer capabilities
- use `Application team` when the scope is the business service itself

## 5. Notes on role-title realism

- `Platform Engineer`, `Kubernetes Platform Engineer`, `Infrastructure Engineer`, `Cloud Infrastructure Engineer`, `IAM Engineer`, and `Site Reliability Engineer` are all common current job titles.
- `DevOps Engineer` is still widely used as a title, but it often spans multiple scopes and is less precise as a team-definition term.
- `Production Engineer` is a valid title in some companies, but it is less universal than `Site Reliability Engineer`.
