---
name: api-contract
description: Contract-first OpenAPI 3.0, DTOs, standard errors, pagination, filtering, versioning, rate limits, auth docs, Postman, and consumer contract tests.
---

# API Contract

## When to Use

- New HTTP surface or breaking API change.
- Aligning Backend controllers with documented behaviour.

## Instructions

- Publish OpenAPI 3.0 as source of truth; generate or sync springdoc output.
- Standardise errors: `code`, `message`, `correlationId`.
- Document pagination (cursor vs offset) and allowlisted filters.

## Safety Checklist

- [ ] Breaking change has version bump + migration notes
- [ ] Consumer contract tests referenced in CI config
