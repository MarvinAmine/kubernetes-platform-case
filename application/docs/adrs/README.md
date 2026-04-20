# Architecture Decision Records

This directory contains the lightweight Architecture Decision Records for the Stage 1 **Payment Exception Review Service**.

These ADRs capture the decisions that materially shape implementation and explain why the service is designed the way it is.

## ADR Index

- [ADR-001 - Keep Stage 1 as a single Spring Boot service](./ADR-001-single-spring-boot-service.md)
- [ADR-002 - Use Java 21 and Spring Boot 3.x](./ADR-002-java21-spring-boot3x.md)
- [ADR-003 - Use PostgreSQL for persisted payment exception review data](./ADR-003-postgresql-persistence.md)
- [ADR-004 - Use Kubernetes-native runtime patterns without Eureka or OpenFeign](./ADR-004-kubernetes-native-runtime.md)
- [ADR-005 - Use OpenAPI as the formal API contract](./ADR-005-openapi-formal-contract.md)
