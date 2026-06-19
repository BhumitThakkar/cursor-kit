# Mass Assignment & Data Binding Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Binding direct JPA entities to controllers or exposing sensitive state to clients are always findings.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/mass_assignment_reviewer.md` |
| Cursor invoke name | `mass_assignment_reviewer` |
| Report path | `AI/mass_assignment_reviewer/mass_assignment_reviewer_report.md` |
| Report reviewer line | `mass_assignment_reviewer v1.0 STRICT` |

---

## Verdict Vocabulary

Allowed values only:

- PASS
- FAIL
- MANUAL_REVIEW
- N/A

`UNCLEAR` is forbidden. If evidence is insufficient, use MANUAL_REVIEW and state the exact missing evidence.

---

## Resolution Requirement

Every finding must include a Resolution with five rows:

1. Pattern
2. Mechanism
3. Security property
4. Prohibited
5. Verify

Only Evidence may quote project source. Resolution rows must be prose, not pasteable code.

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| MAS01 | Direct entity binding | Application binds external request payloads (`@RequestBody` or `@ModelAttribute`) directly into JPA entity classes (`@Entity`), bypassing input DTOs |
| MAS02 | Client-supplied sensitive fields | Input DTOs or form objects expose setters for server-owned sensitive fields (e.g., `id`, `ownerId`, `role`, `authorities`, `isAdmin`, `status`, `price`, `approved`, `createdBy`, `tenantId`) |
| MAS04 | Server-derived trusted state | Business logic trusts client input for ownership, tenancy, permissions, price, or workflow status rather than deriving these strictly from the authenticated security context or trusted server state |
| MAS05 | Broad mapper allow-lists | Code uses indiscriminate mapping functions (`BeanUtils.copyProperties` without ignored fields, unchecked ModelMapper) to copy request properties into domain objects without explicit field allow-lists or safe DTOs |

### High

| ID | Citation | Condition |
|---|---|---|
| MAS03 | Reject unknown JSON fields | Application silently accepts and ignores unknown fields in JSON payloads (`FAIL_ON_UNKNOWN_PROPERTIES=false`) rather than explicitly rejecting unexpected properties |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| MAS01 | Controllers accept action-specific DTOs/Forms (e.g., `UpdateProfileRequest`) and never accept `@Entity` classes as input. |
| MAS02 | DTOs lack sensitive fields entirely, or use `@JsonIgnore` / `ReadOnly` patterns ensuring such fields cannot be deserialized from client input. |
| MAS03 | Jackson is configured to `FAIL_ON_UNKNOWN_PROPERTIES=true` globally, or endpoints use strict `@JsonIgnoreProperties(ignoreUnknown = false)`. |
| MAS04 | Roles, prices, approvals, and ownership IDs are set via `SecurityContextHolder.getContext().getAuthentication()` or database lookups within the service layer. |
| MAS05 | Object mappers explicitly define mappings, or `BeanUtils.copyProperties` is only invoked between safe matching DTOs, never directly copying unchecked client data into domain entities. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| MAS01-MAS05 | Application handles no `POST`/`PUT`/`PATCH` endpoints taking user payloads (strictly GET/read-only). |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- Application uses dynamic `Map<String, Object>` payloads where the field names processed by the service layer cannot be statically determined.
- A custom serialization/deserialization framework masks whether unknown fields are rejected or ignored.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| MAS01 | Binding | Critical | Direct entity binding |
| MAS02 | Binding | Critical | Client-supplied sensitive fields |
| MAS03 | Parsing | High | Reject unknown JSON fields |
| MAS04 | Trust | Critical | Server-derived trusted state |
| MAS05 | Mappers | Critical | Broad mapper allow-lists |
