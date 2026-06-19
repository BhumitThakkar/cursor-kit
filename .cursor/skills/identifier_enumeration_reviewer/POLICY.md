# Identifiers & Enumeration Security Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Exposing sequential IDs without authorization is always a finding.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/identifier_enumeration_reviewer.md` |
| Cursor invoke name | `identifier_enumeration_reviewer` |
| Report path | `AI/identifier_enumeration_reviewer/identifier_enumeration_reviewer_report.md` |
| Report reviewer line | `identifier_enumeration_reviewer v1.0 STRICT` |

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
| ENUM01 | No sequential PKs in APIs | Sequential integer primary keys (`Long id`) are exposed in URLs or API response bodies as the sole identifier for user-owned or tenant-owned resources, enabling trivial IDOR enumeration |
| ENUM02 | Authorize by resource ID | Controller or service methods accept a resource ID but do not perform ownership or authorization checks before returning, updating, or deleting the resource |

### High

| ID | Citation | Condition |
|---|---|---|
| ENUM03 | No user-existence leakage | Login, registration, or password-reset flows return different error messages or noticeably different response timings for existing vs non-existing accounts, enabling account enumeration |
| ENUM04 | Public ID entropy | Public-facing identifiers encode tenant, user, or timestamp information in a reversible, predictable way (e.g., base64-encoded sequential IDs) without encryption or signing |
| ENUM05 | Server-side tenant/user filters | Search or list endpoints do not enforce server-side tenant or user-scoped filters, allowing users to enumerate or access other tenants' data by manipulating query parameters or pagination |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| ENUM01 | API endpoints expose UUIDs, ULIDs, or random opaque tokens instead of database sequential IDs for user-owned resources. Internal surrogate keys remain private. |
| ENUM02 | Every read/update/delete endpoint for a user-owned resource includes `@PreAuthorize`, an ownership service check, or a JPA repository query scoped to the authenticated user. |
| ENUM03 | Login and password-reset endpoints return identical generic messages (e.g., "If an account exists, you will receive an email") regardless of whether the account exists. |
| ENUM04 | Public IDs use UUIDs (128-bit entropy) or equivalent and do not encode internal structure (tenant ID, timestamps) in a decodable format. |
| ENUM05 | Repository queries for list/search endpoints include a `WHERE tenant_id = :currentTenant` (or equivalent user scope) that is injected server-side, not from a client parameter. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| ENUM01 | Application has no user-owned or tenant-owned resources exposed via API. |
| ENUM03 | Application has no login, registration, or password-reset flows. |
| ENUM05 | Application is single-tenant with no multi-user data isolation requirement. |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- Ownership checks are implemented in a shared base service class that is not directly visible in the scanned controller code.
- Timing differences in login responses require runtime measurement beyond static analysis.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| ENUM01 | Identifiers | Critical | No sequential PKs in APIs |
| ENUM02 | Identifiers | Critical | Authorize by resource ID |
| ENUM03 | Enumeration | High | No user-existence leakage |
| ENUM04 | Identifiers | High | Public ID entropy |
| ENUM05 | Enumeration | High | Server-side tenant/user filters |
