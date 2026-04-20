# ADR-003 - Use PostgreSQL for persisted payment exception review data

## Status

Accepted

## Context

The Stage 1 service is no longer intended to behave like a stateless shell.

To make the service more credible as an internal enterprise workload, payment exception review data should be persisted.

The current domain is still narrow:

- one service
- one main persisted business concept
- straightforward read-oriented API behavior

## Decision

Use PostgreSQL as the persistence layer for Stage 1 payment exception review data.

The service should persist payment exception review records in a simple relational model centered on the `payment_exception_reviews` table.

## Consequences

### Positive

- Makes the Stage 1 service more realistic and stateful.
- Gives the application a credible persistence model.
- Fits well with internal enterprise service expectations.

### Negative

- Adds schema, connectivity, and persistence concerns to Stage 1.
- Increases the amount of implementation and testing required.

## Revisit trigger

Revisit if later stages require:

- more complex audit/history handling
- multi-service ownership boundaries
- event-driven persistence patterns
