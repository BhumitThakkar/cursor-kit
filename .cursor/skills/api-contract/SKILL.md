---
name: api-contract
description: OpenAPI 3.0, DTOs, errors, pagination, filtering, versioning, rate limits, auth; Postman collections and contract tests. Use for API design and contract-first workflow.
---

# API Contract Skill

## When to Use

- User asks for "OpenAPI", "API spec", "contract", "Postman", "pagination", or "API versioning".
- New endpoint or change to existing API surface.

## Instructions

1. **OpenAPI 3.0**
   - Paths, schemas (request/response DTOs), security schemes, examples.
   - Version file (e.g. `openapi-v1.yaml`); document versioning strategy.

2. **Standards**
   - **Errors**: Same structure (e.g. code, message, correlationId); document in spec.
   - **Pagination**: Cursor or offset; max page size; document in spec.
   - **Filtering**: Allowlist of query params; document validation.

3. **Postman**
   - Keep collection in sync with OpenAPI; use examples from spec.
   - Add contract tests (status, body schema, required headers); run in CI if possible.

4. **Breaking changes**
   - Any breaking change → new API version; run compatibility check (e.g. diff old vs new spec, contract tests).
   - Document in changelog or migration guide.

## Safety Checklist

- [ ] Contract-first: spec exists before/with implementation
- [ ] Breaking changes trigger version bump and checks
- [ ] Consumer contract tests present and run in CI
