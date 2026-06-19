---
name: identifier_enumeration_reviewer
version: 1.0
disable-model-invocation: true
---

# Identifiers & Enumeration Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/identifier_enumeration_reviewer.md` |
| Skill directory | `.cursor/skills/identifier_enumeration_reviewer/` |
| Cursor invoke name | `identifier_enumeration_reviewer` |
| Report path | `AI/identifier_enumeration_reviewer/identifier_enumeration_reviewer_report.md` |
| Report reviewer line | `identifier_enumeration_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications that expose resource identifiers in URLs, APIs, or view templates.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |
| Identifier surface | `@PathVariable`, `@RequestParam`, entity IDs in DTOs, URL patterns |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| No resource endpoints | Batch/CLI application |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for identifier_enumeration_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application exposing resource identifiers.
```

---

## 2. File Discovery

Scan in this order.

### Entities and DTOs

- JPA entity classes with `@Id` and `@GeneratedValue`
- Response DTOs and JSON serialization classes

### Controllers

- `@PathVariable Long id` patterns
- `@PathVariable UUID id` patterns
- `@GetMapping`, `@PutMapping`, `@DeleteMapping` with resource identifiers

### Authorization

- `@PreAuthorize` annotations on controller or service methods
- Custom ownership/access-check service methods
- JPA repository queries with user/tenant scoping

### Auth Flows

- Login controllers and error message responses
- Password-reset controllers and email-sending logic
- Registration controllers

### Search / List

- Paginated list endpoints (`Pageable`, `Page<>`)
- Search endpoints with filter parameters

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find sequential IDs | `rg -n "@PathVariable.*Long\|@PathVariable.*long\|@RequestParam.*Long" src` |
| Find UUID IDs | `rg -n "@PathVariable.*UUID\|@PathVariable.*String.*id" src` |
| Find GeneratedValue | `rg -n "@GeneratedValue" src` |
| Find exposed IDs | `rg -n "getId\(\)\|\.id\b" src` (in DTOs / response objects) |
| Find ownership checks | `rg -n "@PreAuthorize\|checkOwnership\|belongsTo\|currentUser" src` |
| Find login messages | `rg -n "Invalid.*credentials\|not found\|does not exist\|already registered" src` |
| Find search endpoints | `rg -n "Pageable\|Page<\|findAll\|search" src` |
| Find tenant filters | `rg -n "tenantId\|tenant_id\|currentTenant\|organizationId" src` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| ENUM01 | Application has no user-owned or tenant-owned resources exposed via API. |
| ENUM03 | Application has no login, registration, or password-reset flows. |
| ENUM05 | Application is single-tenant with no multi-user data isolation. |

---

## 5. CHECK-ID Scoring Procedure

### ENUM01 - No Sequential PKs in APIs
Fail when controllers expose `@PathVariable Long id` for endpoints operating on user-owned resources (e.g., `/order/{id}`, `/profile/{id}`), making IDs trivially guessable by incrementing.

### ENUM02 - Authorize by Resource ID
Fail when a controller fetches a resource by ID and returns it without verifying that the authenticated user owns or is authorized to access that resource.

### ENUM03 - No User-Existence Leakage
Fail when login returns "User not found" for missing accounts vs "Wrong password" for existing accounts, or when password-reset confirms existence ("Email sent" vs "User does not exist").

### ENUM04 - Public ID Entropy
Fail when public-facing IDs are base64-encoded sequential integers, or encode tenant/user/timestamp in a reversible format without encryption.

### ENUM05 - Server-side Tenant/User Filters
Fail when list/search endpoints use `repository.findAll()` without injecting a server-side tenant or user filter, allowing users to see other tenants' data or total counts.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:
- Ownership checks are implemented in a shared abstract base controller or service that is not directly visible at the endpoint level.
- Timing-based enumeration (login response differences) requires runtime measurement.

---

## 7. Report Requirements

Every scored finding must include: File, Evidence, Policy Rule, Possible Attack Scenario, and five Resolution rows.

### 7.1 Verify Row Rules

Every Verify row must include: Action + pass signal.

---

## 8. Secure Resolution Catalog

Use one row set per finding.

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| ENUM01 | Opaque public ID | Add a `UUID publicId` field to the entity and expose only that in APIs; keep the sequential `Long id` internal | Attackers cannot enumerate resources by incrementing an integer | Sequential IDs in URLs/responses | Increment ID in URL; confirm 404 or mismatched UUID response |
| ENUM02 | Ownership gate | Add `@PreAuthorize("@ownershipService.check(#id, principal)")` or scope JPA queries to the authenticated user | Accessing another user's resource by ID is impossible | Unchecked resource fetch | Copy User B's UUID into User A's request; confirm 403 Forbidden |
| ENUM03 | Generic messages | Return identical messages like "If an account exists, instructions have been sent" for both valid and invalid inputs | Account enumeration via error differential is impossible | Distinct messages per account status | Submit login for unknown email; confirm same message as known email |
| ENUM04 | Random IDs | Use `UUID.randomUUID()` or ULID; do not embed decodable metadata | Public IDs reveal no internal structure | Base64 sequential or timestamp-encoded IDs | Decode 10 public IDs; confirm no sequential or structural pattern |
| ENUM05 | Server-side scoping | Inject `WHERE tenant_id = :currentTenantId` in repository queries using `@Query` or Spring Data specifications | Users cannot access or count other tenants' records | Unfiltered `findAll()` for multi-tenant data | Query list as Tenant A; confirm Tenant B's data is absent |

---

## 9. Scoring Formula

Base Score: 100
Critical: -20, High: -10, Medium: -5, Low: -2, Info: 0
Floor: 0

---

## 10. Final Self-Validation

Before finalizing a report:
- Confirm stack gate result.
- Confirm every failed CHECK-ID has 5 resolution rows.
- Confirm sequential IDs in APIs (ENUM01) is Critical.
- Confirm missing ownership checks (ENUM02) is Critical.
