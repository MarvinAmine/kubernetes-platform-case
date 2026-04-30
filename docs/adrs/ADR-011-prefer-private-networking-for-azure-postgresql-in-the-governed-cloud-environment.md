# ADR-011 - Prefer Private Networking for Azure PostgreSQL in the Governed Cloud Environment

## Status

Accepted

## Context

For the cloud-side database, the repository needs a posture that is closer to enterprise best practice than simple unrestricted public access.

At the same time, Stage 1 must remain finishable.

For Azure Database for PostgreSQL Flexible Server, the stronger cloud posture is typically based on:

- a delegated subnet
- private DNS
- application-to-database private connectivity through the governed runtime network path

This is a more credible controlled-access model than treating the managed database like a generic public endpoint.

## Decision

The preferred governed-cloud posture for Azure Database for PostgreSQL is:

- **delegated subnet**
- **private DNS**
- **no direct public laptop access as a normal validation path**
- **application or in-cluster tooling as the normal database access path**

Environment mapping:

- `local` development uses local PostgreSQL
- governed cloud `dev` uses Azure Database for PostgreSQL with private access

Implementation direction for the Azure Terraform layer:

- one platform VNet
- one AKS subnet
- one delegated PostgreSQL subnet
- one private DNS zone for PostgreSQL
- one private DNS link between the zone and the VNet
- AKS attached to the VNet so workloads can reach the database privately

This decision defines the intended Stage 1 architecture, not only a later aspiration.

## Consequences

### Positive

- the database posture is closer to real enterprise networking practice
- the cloud environment becomes more credible for regulated-environment discussions
- the design aligns with a stronger separation between local development and governed cloud delivery
- database validation in cloud flows through the same trusted runtime path as the application

### Negative

- infrastructure complexity increases compared with a simple public-access first setup
- Stage 1 implementation effort becomes heavier because networking must be designed from the start
- infrastructure churn is likely while moving from a simple public server to the private-networked model

## Alternatives considered

### Public access as the primary intended cloud model

Rejected because it is weaker from a platform and security perspective.

### Temporary firewall-rule validation from a developer laptop

Rejected as the intended design because it bypasses the governed network path and makes the cloud database behave like a public endpoint.

### Private endpoint as the primary first-choice pattern

Rejected for now because delegated subnet plus private DNS is the cleaner baseline direction for this PostgreSQL Flexible Server case.
