# ADR-017 - Use Managed PostgreSQL for Non-Prod Parity and Conditional External DB Proof in OpenShift Sandbox

## Status

Accepted

## Context

Stage 2 introduces a stronger environment model and starts comparing the AKS
delivery foundation with OpenShift-oriented platform behavior.

The application still needs PostgreSQL. The question is whether every
environment should use the same database hosting model.

Using the same model everywhere would make the architecture look simple, but it
would hide two different concerns:

- AKS non-prod should validate the same managed-service contract expected in
  production.
- OpenShift Sandbox should validate workload portability without pretending it
  is production or that the Azure foundation is portable.

Azure Database for PostgreSQL is part of the Azure-specific infrastructure
foundation. It is not something that OpenShift Sandbox provisions or owns.

## Decision

Stage 2 uses an environment-specific PostgreSQL strategy:

| Environment | PostgreSQL model | Purpose |
| --- | --- | --- |
| Local developer runtime | PostgreSQL pod | Fast, low-cost local validation |
| OpenShift Sandbox | Preferred: external Azure PostgreSQL if networking allows it. Fallback: PostgreSQL pod or mocked DB contract | Workload and manifest portability validation |
| AKS dev | Azure Database for PostgreSQL | Non-prod validation of the real managed-service contract |
| AKS staging | Azure Database for PostgreSQL | Production-like promotion validation |
| AKS prod | Azure Database for PostgreSQL | Managed production dependency |

AKS non-prod keeps Azure PostgreSQL because dev and staging should validate the
same dependency shape as production:

```text
Spring Boot workload in AKS
  -> Kubernetes ConfigMap / Secret contract
  -> Azure Database for PostgreSQL
```

OpenShift Sandbox is not `prod`, and it is not a production-like environment.
It is a temporary, shared, limited compatibility lab. The strongest Sandbox
database proof is external Azure PostgreSQL connectivity if firewall and
networking constraints allow it:

```text
Spring Boot workload in OpenShift Sandbox
  -> OpenShift Project
  -> Route / Service exposure
  -> pull secret
  -> ConfigMap / Secret contract
  -> Azure PostgreSQL public or otherwise reachable endpoint
```

If that path is blocked by Sandbox networking limits, firewall rules, DNS, or
uncontrolled egress IPs, the fallback proof is:

```text
Spring Boot workload in OpenShift Sandbox
  -> OpenShift Project
  -> Route / Service exposure
  -> pull secret
  -> ConfigMap / Secret contract
  -> PostgreSQL pod or mocked DB contract
```

## OpenShift Sandbox Boundary

OpenShift Sandbox validates the portable workload contract, not the Azure
infrastructure foundation.

The following stay Azure-specific:

- AKS Terraform
- Azure networking
- Azure PostgreSQL provisioning
- Azure Storage remote Terraform backend
- Azure OIDC / Microsoft Entra federation
- AKS cluster access and lifecycle scripts

In Sandbox, the validation scope is:

- OpenShift Project compatibility
- Route / Service exposure behavior
- image pull behavior and pull-secret contract
- ConfigMap / Secret runtime wiring
- non-root and security-context compatibility
- preferred external Azure PostgreSQL connectivity when feasible
- fallback in-cluster PostgreSQL substitute

The main practical blocker for external Azure PostgreSQL from Sandbox is network
control. Azure PostgreSQL may require firewall allow-listing of Sandbox egress
IP addresses, and the shared Sandbox environment may not expose stable or
controllable egress IPs.

## Stage 3 Database Direction

Even when Stage 3 introduces real OpenShift runtime proof, the default
regulated-style architecture should still keep the critical database outside
OpenShift:

```text
OpenShift application platform
  -> external managed PostgreSQL
  -> cloud provider service or enterprise DBA-managed database platform
```

Running PostgreSQL inside OpenShift is an advanced alternative, not the default.
It should only become the main path if Stage 3 intentionally studies stateful
database operations on Kubernetes / OpenShift through an approved operator
model.

Examples of that alternative include:

- Crunchy Data Postgres Operator
- EDB Postgres for Kubernetes
- CloudNativePG
- other enterprise-approved PostgreSQL operator patterns

Those options require explicit ownership for backup, restore, patching, HA,
encryption, audit, RPO / RTO, and on-call support.

## Consequences

### Positive

- AKS non-prod remains close to production.
- OpenShift Sandbox stays affordable and focused.
- The architecture avoids pretending Azure infrastructure is portable to
  OpenShift.
- The same application runtime contract can be tested across local, AKS, and
  OpenShift-style environments.
- Sandbox can produce a stronger proof if it connects to Azure PostgreSQL.
- Sandbox still has a low-cost fallback when external connectivity is blocked.
- Stage 2 can compare Kubernetes portability without turning into a full
  OpenShift infrastructure migration.

### Negative

- Sandbox database behavior is not identical to AKS dev, staging, or prod.
- Azure PostgreSQL private networking, private DNS, and managed backup behavior
  are not proven in Sandbox.
- External Azure PostgreSQL connectivity from Sandbox may fail because egress IP
  and firewall control are limited.
- Documentation must clearly distinguish production parity from portability
  validation.

## Alternatives Considered

### Always require Azure PostgreSQL from OpenShift Sandbox

Rejected because it can be blocked or complicated by Sandbox networking limits,
firewall rules, public/private access, DNS behavior, and unknown egress IPs.

Azure PostgreSQL remains the preferred stronger proof when the environment
allows it.

### Use PostgreSQL in OpenShift for production by default

Rejected as the default regulated-style posture because critical databases need
clear ownership for backup, restore, patching, HA, encryption, audit, RPO /
RTO, and on-call support.

OpenShift database operators remain a valid later alternative if Stage 3
intentionally studies stateful platform operations.

### Run PostgreSQL in a pod for AKS dev and staging

Rejected because AKS non-prod should validate the same managed-service contract
used by production.

Running the database in a pod is useful for local and portability labs, but it
weakens the production-parity signal for governed cloud environments.

### Treat OpenShift Sandbox as a full replacement for AKS non-prod

Rejected because Sandbox does not own or reproduce the Azure infrastructure
foundation.

It is a compatibility lab, not the canonical dev, staging, certification, or
production estate.
