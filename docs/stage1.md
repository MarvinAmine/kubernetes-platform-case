# Stage 1 — Governed Platform Bootstrap and Controlled Delivery of a Regulated Internal Service

## Stage 1 title

**Stage 1 — Platform Bootstrapping and Controlled Delivery of a Regulated Internal Service**

## Platform case title

**Regulated Payment Exception Review Platform**

## Stage 1 application

**Payment Exception Review Status API**

## Related ADRs

The main Stage 1 design decisions are captured in:

- [docs/adrs/ADR-001-three-team-stage1-operating-model.md](/home/marvin/Documents/dev/kubernetes/docs/adrs/ADR-001-three-team-stage1-operating-model.md)
- [docs/adrs/ADR-002-separate-infrastructure-and-platform-terraform-responsibilities.md](/home/marvin/Documents/dev/kubernetes/docs/adrs/ADR-002-separate-infrastructure-and-platform-terraform-responsibilities.md)
- [docs/adrs/ADR-003-controlled-application-delivery-path.md](/home/marvin/Documents/dev/kubernetes/docs/adrs/ADR-003-controlled-application-delivery-path.md)
- [docs/adrs/ADR-004-observability-and-failure-scenarios-as-core-scope.md](/home/marvin/Documents/dev/kubernetes/docs/adrs/ADR-004-observability-and-failure-scenarios-as-core-scope.md)
- [docs/adrs/ADR-005-staged-maturity-evolution.md](/home/marvin/Documents/dev/kubernetes/docs/adrs/ADR-005-staged-maturity-evolution.md)

## 1. Stage 1 purpose

Stage 1 demonstrates how an **infrastructure team**, a **platform team**, and an **application team** collaborate in a controlled Kubernetes environment similar to what is expected in regulated organizations such as banks, insurers, and government-adjacent institutions.

The goal is not to build a customer-facing payment platform. The goal is to show a credible enterprise operating model where:
- the infrastructure team provisions the foundational Azure and AKS estate
- the platform team provisions a governed Kubernetes application boundary on top of that foundation
- the application team deploys a Java microservice into that environment
- delivery is automated through CI/CD
- the service exposes health, metrics, and realistic operational signals
- failures can be diagnosed like in production

This stage is intentionally small, but it is designed to feel like a real internal enterprise service rather than a demo toy.

## 2. Business context

A regulated organization processes a large number of payment operations.

Some payments cannot continue through the standard automated flow because they trigger internal exception rules such as:
- amount above a threshold
- missing payment reference
- suspicious duplicate
- blocked destination
- invalid metadata
- compliance review required

Instead of handling these cases in an ad hoc way, the organization exposes an internal service that tracks and publishes the lifecycle of these payment exceptions.

The **Payment Exception Review Status API** is the first service in that platform.

Its purpose is to let internal systems and operators:
- query the status of a payment exception
- view validation results
- understand whether manual review is required
- observe service health
- troubleshoot configuration and rollout issues

## 3. Stage 1 objective

Demonstrate that an infrastructure team can provision the foundational Azure and AKS estate with Terraform, that a platform team can provision a governed Kubernetes application boundary on top of it, and that an application team can deliver a Java microservice into that boundary through a controlled GitHub Actions + Helm deployment path.

This stage proves practical understanding of:
- Kubernetes operating model
- Terraform-based environment management
- CI/CD delivery
- containerized Java services
- probes and rollout behavior
- observability basics
- infrastructure, platform, and application ownership boundaries
- production-like troubleshooting

## 4. Why this project is credible

### For recruiters

It looks like an internal enterprise service used in a regulated environment, not a toy app.

### For hiring managers

It creates direct discussion points around:
- AKS
- Terraform
- GitHub Actions
- Docker
- Helm
- RBAC
- ConfigMaps and Secrets
- probes
- rollout troubleshooting
- observability
- production support mindset
- separation of responsibilities between infrastructure, platform, and application teams

### For technical interviews

It gives realistic stories such as:
- a rollout blocked by a broken readiness probe
- a startup failure caused by invalid application configuration
- a namespace and service account bootstrapped by platform engineering
- an application deployed through a controlled delivery path
- operational metrics exposed for monitoring and troubleshooting

## 5. Scope

### In scope for Stage 1

- AKS cluster already created
- Terraform-managed Kubernetes bootstrap resources
- infrastructure team foundation path
- platform team bootstrap path
- application team delivery path
- Java Spring Boot microservice
- Docker image build
- Helm-based deployment
- PostgreSQL-backed application behavior
- health endpoints and Prometheus metrics
- basic Grafana-ready observability
- two realistic failure scenarios
- documentation and runbook material

### Out of scope for Stage 1

These are intentionally deferred to later stages:
- real payment execution
- real banking integrations
- customer-facing workflows
- real identity provider integration
- Vault
- ArgoCD
- OpenShift
- service mesh
- Kafka
- advanced AppSec toolchain
- multi-cloud failover
- advanced compliance automation

## 6. Actors and ownership model

### 1. Infrastructure team

Owns the foundational technical estate required before the governed runtime exists.

Responsibilities:
- Terraform
- resource group provisioning
- AKS cluster provisioning
- remote Terraform backend
- managed PostgreSQL foundation
- infrastructure-level access prerequisites
- environment connectivity and base infrastructure consistency

### 2. Platform team

Owns the governed Kubernetes application boundary and runtime conventions built on top of the infrastructure foundation.

Responsibilities:
- namespace creation
- service account creation
- role and rolebinding
- baseline ConfigMap
- baseline Secret pattern
- shared observability services such as Prometheus and Grafana
- platform-controlled workflow
- environment consistency

### 3. Application team

Owns the business service and its delivery path.

Responsibilities:
- Spring Boot application code
- schema usage and persistence logic
- Dockerfile
- Helm chart
- deployment values
- probes
- actuator endpoints and custom metrics
- business configuration
- application delivery workflow
- app-level metrics exposure

### 3. Internal consumer

Can be:
- internal operations UI
- manual review tool
- support operator
- downstream internal service

Consumes the API to retrieve payment exception state and service status.

## 7. Functional overview

The Payment Exception Review Status API represents a small internal enterprise service that exposes the lifecycle of a payment exception.

### Core concepts

A **payment exception** is a payment operation that requires non-standard handling.

### Example fields

- `exceptionId`
- `paymentReference`
- `status`
- `validationState`
- `reasonCode`
- `priority`
- `region`
- `createdAt`
- `lastUpdated`
- `requiresManualReview`

### Example statuses

- `RECEIVED`
- `VALIDATING`
- `PENDING_REVIEW`
- `APPROVED`
- `REJECTED`
- `ESCALATED`
- `CLOSED`

### Example reason codes

- `AMOUNT_THRESHOLD_EXCEEDED`
- `MISSING_REFERENCE`
- `DUPLICATE_SUSPECTED`
- `DESTINATION_BLOCKED`
- `COMPLIANCE_REVIEW_REQUIRED`
- `INVALID_METADATA`

### Example validation states

- `VALID`
- `INVALID`
- `INCOMPLETE`
- `REQUIRES_MANUAL_REVIEW`

## 8. Stage 1 API responsibilities

The service must:

1. **Expose payment exception status**  
   Let internal consumers know where the exception is in its lifecycle.

2. **Expose validation summary**  
   Show why a payment is blocked, flagged, or pending review.

3. **Expose service health**  
   Help operators know if the service is healthy and routable.

4. **Expose config validation state**  
   Make configuration issues visible and diagnosable.

5. **Expose operational metrics**  
   Provide monitoring and troubleshooting signals.

## 9. Stage 1 endpoints

### Business endpoints

- `GET /api/payment-exceptions/{id}/status`
- `GET /api/payment-exceptions/{id}/summary`
- `GET /api/payment-exceptions/service-status`
- `GET /api/payment-exceptions/config-check`

### Technical endpoints

- `GET /actuator/health`
- `GET /actuator/info`
- `GET /actuator/prometheus`

## 10. Data persistence

To make Stage 1 more credible, the service is backed by **PostgreSQL** rather than behaving like a stateless shell.

The database stores payment review records such as:
- payment reference
- review status
- review reason
- source system
- assigned queue
- timestamps

This matters because it turns the application into a more realistic internal service with a true dependency that must be deployed, configured, checked, and troubleshooted.

It also gives you stronger interview material around:
- service dependency health
- startup failures caused by invalid DB configuration
- environment variables and secret handling
- readiness versus true business readiness

## 11. Architecture summary

### Platform bootstrap path

The platform team uses Terraform to create or reconcile Kubernetes environment resources such as:
- namespace
- service account
- role
- rolebinding
- baseline ConfigMap
- baseline secret structure

This represents the **platform bootstrap path managed by the platform team on top of infrastructure prepared by the infrastructure team**.

### Application delivery path

The application team pushes code to GitHub.

GitHub Actions then:
- builds the Spring Boot service
- packages the Docker image
- pushes the image
- deploys the application with Helm into the pre-created namespace

This represents the **application delivery path used by the application team**.

### Runtime model

Inside the AKS cluster, the application runs with:
- Deployment
- Service
- ConfigMap usage
- Secret usage
- readiness probe
- liveness probe
- resource requests and limits
- app metrics exposure

## 12. Technical stack for Stage 1

- **Azure AKS**
- **Terraform**
- **GitHub Actions**
- **Docker**
- **Helm**
- **Java Spring Boot**
- **PostgreSQL**
- **Kubernetes RBAC**
- **Prometheus-compatible metrics**
- **Grafana-compatible dashboards**

This is intentionally enough to look credible without diluting the project.

## 13. Observability design

A regulated internal service must be diagnosable when:
- review traffic spikes
- pods restart
- rollout is blocked
- configuration is broken
- requests slow down
- the service becomes unavailable

### Stage 1 metrics ideas

- `payment_exception_requests_total`
- `payment_exception_status_queries_total`
- `payment_exception_validation_failures_total`
- `payment_exception_escalations_total`
- `payment_exception_config_validation_failures_total`
- `payment_exception_processing_duration_seconds`

### Useful dashboards

- service availability
- request volume
- latency
- pod restarts
- validation failures
- escalation count
- JVM basics
- health trend

This gives you credible material for platform health discussions and incident response conversations.

## 14. Failure scenarios

### Failure scenario 1 — wrong readiness probe

The application is running, but the readiness probe points to the wrong path.

#### Impact

- pod stays unready
- rollout appears broken
- service is not available through normal routing
- deployment is blocked even though the container is alive

#### What this proves

- understanding of readiness versus liveness
- Kubernetes troubleshooting ability
- rollout diagnosis
- production-style incident reasoning

### Failure scenario 2 — invalid application configuration

The application starts with an invalid business configuration value.

Example:

`VALIDATION_MODE=AGGRESSIVE`

when only `STRICT` or `STANDARD` are supported.

#### Impact

- startup validation fails
- health becomes unhealthy or app exits
- configuration problem appears in logs and actuator state
- deployment becomes unstable or unavailable

#### What this proves

- config governance mindset
- safe startup validation
- production realism
- ability to make misconfiguration visible instead of silently dangerous

## 15. Design principles

### 1. Internal enterprise realism

The service must feel like one internal microservice in a regulated organization.

### 2. Controlled delivery

No manual snowflake deployment.

### 3. Clear ownership boundaries

Infrastructure, platform, and application responsibilities are separated.

### 4. Config-driven behavior

Behavior changes through configuration, not hardcoded rewrites.

### 5. Operational transparency

Health, logs, and metrics are first-class concerns.

### 6. Small but credible scope

Avoid fake complexity. Keep it narrow, but make it realistic.

### 7. Forward compatibility

Design Stage 1 so it can later absorb:
- ArgoCD
- Vault
- Okta or Entra ID
- ELK/Kibana
- OpenShift
- hybrid Azure/AWS
- Kafka
- stronger policy and governance controls

## 16. What Stage 1 proves to hiring managers

Stage 1 proves that you understand how to work in a production-shaped operating model where:
- environment creation is governed
- foundational infrastructure and governed platform responsibilities are distinct
- application delivery is separated from cluster bootstrapping
- application behavior is containerized and observable
- rollout failures can be analyzed
- configuration mistakes are surfaced early
- infrastructure, platform, and application responsibilities are clearly separated

That is much stronger than just showing “I deployed a Java app on Kubernetes.”

## 17. Strong recruiter-facing summary

You can describe Stage 1 like this:

**Stage 1 of the Regulated Payment Exception Review Platform simulates how a bank-like organization operates an internal payment exception service in Kubernetes. An infrastructure team provisions the Azure and AKS foundation with Terraform, a platform team provisions a governed Kubernetes application boundary on top of it, and an application team delivers a Spring Boot microservice through GitHub Actions, Docker, and Helm. The service exposes payment exception status, service health, config validation, and operational metrics, and includes realistic rollout and misconfiguration failure scenarios.**

## 18. Recommended repo naming

### Broad case name

`regulated-payment-exception-review-platform`

### Stage 1 application module

`payment-exception-review-status-api`

## 19. Recommended Stage 1 positioning on resume / LinkedIn

You should frame it as:
- **platform engineering case**
- **regulated-environment Kubernetes delivery model**
- **controlled CI/CD and environment governance**
- **Spring Boot microservice on AKS**
- **Terraform + Helm + GitHub Actions**
- **observability and troubleshooting-focused**

Not as a “toy banking simulator.”
