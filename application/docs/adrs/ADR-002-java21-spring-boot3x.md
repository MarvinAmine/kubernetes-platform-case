# ADR-002 - Use Java 21 and Spring Boot 3.x

## Status

Accepted

## Context

The service needs a modern but stable technology baseline that is easy to defend in enterprise-style environments.

The project also wants to preserve a clean path toward later identity work without forcing an early migration to a newer major Spring line.

## Decision

Use:

- Java 21
- Spring Boot 3.x

## Consequences

### Positive

- Java 21 provides a strong LTS baseline.
- Spring Boot 3.x keeps broad ecosystem compatibility.
- The stack is modern without being unnecessarily aggressive.

### Negative

- The service does not adopt Spring Boot 4.x at this stage.

## Revisit trigger

Revisit when later-stage requirements justify a migration to a newer major framework line.
