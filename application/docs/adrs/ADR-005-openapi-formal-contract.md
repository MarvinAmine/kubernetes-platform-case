# ADR-005 - Use OpenAPI as the formal API contract

## Status

Accepted

## Context

The service needs a contract that is:

- precise enough for implementation
- easy to review before coding
- professional enough to support future documentation and tooling

Markdown is useful for explanation, but not enough on its own as the formal contract source.

## Decision

Use:

- Markdown API notes for explanatory context
- OpenAPI as the formal REST API contract

## Consequences

### Positive

- Reduces ambiguity between design and implementation.
- Creates a standard machine-readable artifact.
- Supports future Swagger UI or tooling integration.

### Negative

- Requires the Markdown and OpenAPI documents to stay aligned.

## Revisit trigger

Revisit only if contract-first tooling or code generation becomes part of a later-stage delivery model.
