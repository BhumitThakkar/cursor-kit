---
name: mass_assignment_reviewer
version: 1.0
disable-model-invocation: true
---

# Mass Assignment Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/mass_assignment_reviewer.md` |
| Skill directory | `.cursor/skills/mass_assignment_reviewer/` |
| Cursor invoke name | `mass_assignment_reviewer` |
| Report path | `AI/mass_assignment_reviewer/mass_assignment_reviewer_report.md` |
| Report reviewer line | `mass_assignment_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications that handle incoming data payloads.

| Required signal | Evidence |
|---|---|
| Spring Boot MVC | `spring-boot-starter-web`, `@RestController`, `@Controller` |
| Input binding | `@RequestBody`, `@ModelAttribute`, JSON frameworks |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| No Input Binding | Batch application / API gateway with no payloads |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for mass_assignment_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet application processing user input binding.
```

---

## 2. File Discovery

Scan in this order.

### Models and Entities

- JPA `@Entity` classes
- DTO (Data Transfer Object) packages
- Form/Request payload classes (`*Request`, `*Form`)

### Controllers

- Methods taking `@RequestBody` or `@ModelAttribute`
- Custom `WebDataBinder` logic (`@InitBinder`)

### Business Logic

- Services invoking `BeanUtils.copyProperties`
- MapStruct, ModelMapper, or Dozer interface/configuration files
- Methods looking up entity prices or statuses

### Properties

- `application.properties`/`yml` (Jackson configurations)

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find entity binding | `rg -n "@RequestBody\|@ModelAttribute" src | grep EntityName` (manual inspection required) |
| Find sensitive inputs | `rg -n "private\s+.*\(role\|isAdmin\|price\|status\|ownerId\|tenantId\)" src --glob "*Request.java"` |
| Find copy logic | `rg -n "copyProperties\|modelMapper\.map" src` |
| Find Jackson config | `rg -n "FAIL_ON_UNKNOWN_PROPERTIES" src` |
| Find data binder config | `rg -n "setDisallowedFields" src` |
| Find auth lookups | `rg -n "SecurityContextHolder" src` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| MAS01-MAS05 | Application has absolutely no endpoints accepting request bodies or form data (GET/DELETE only). |

---

## 5. CHECK-ID Scoring Procedure

### MAS01 - Direct Entity Binding
Fail when a controller method parameter annotated with `@RequestBody` or `@ModelAttribute` is a class also annotated with `@Entity` or `@Table`, allowing Hibernate models to be directly populated by the web layer.

### MAS02 - Client-Supplied Sensitive Fields
Fail when input DTOs (e.g., `CreateUserRequest`) contain fields like `role`, `isAdmin`, `price`, or `approved` that clients can populate via JSON or form submission.

### MAS03 - Reject Unknown JSON Fields
Fail when `spring.jackson.deserialization.fail-on-unknown-properties=false` is configured, or endpoints lack strict Jackson annotations, silently ignoring extra fields submitted by attackers.

### MAS04 - Server-Derived Trusted State
Fail when a service method accepts a price, tenant ID, or role directly from the controller's payload rather than looking it up from the database or Spring Security context.

### MAS05 - Broad Mapper Allow-Lists
Fail when `BeanUtils.copyProperties(source, target)` copies from a broad DTO/payload directly into an `@Entity` without explicitly ignoring sensitive properties (or using a strict field-by-field mapper).

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:
- MapStruct mapping interfaces use complex implicit mappings that require compilation to verify safety.
- Jackson is configured programmatically in a `ObjectMapper` bean where unknown property behaviour is not statically obvious.

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
| MAS01 | Action-specific DTOs | Create a dedicated `UpdateRequest` class containing only editable fields and bind to that instead of `@Entity` | Domain models are isolated from external input formats | `@RequestBody UserEntity` | Attempt to submit non-editable field; confirm 400 Bad Request or ignorance |
| MAS02 | Clean DTOs | Remove `role`, `price`, `isAdmin` fields from input request objects | Sensitive data cannot be parsed from client payloads | Client-side sensitive fields | Submit payload with `role=ADMIN`; confirm role does not change |
| MAS03 | Strict parsing | Set `spring.jackson.deserialization.fail-on-unknown-properties=true` | Undocumented fields cause immediate payload rejection | Ignoring unknown JSON fields | Submit `{ "known": "x", "unknown": "y" }`; confirm 400 Bad Request |
| MAS04 | Context derivation | Lookup the product price from the DB and the user ID from `SecurityContext` in the service tier | System relies exclusively on cryptographically trusted or persistent state | Trusting payload for price/tenant | Submit request altering price; confirm final checkout uses DB price |
| MAS05 | Strict mappers | Avoid `BeanUtils.copyProperties` to entities; use explicit setter mapping or configure MapStruct explicitly | Object copying only touches intended fields | Blind object-to-object copying | Submit unexpected DTO field; confirm entity value is unchanged |

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
- Confirm binding directly to `@Entity` (MAS01) is Critical.
- Confirm blind property copying (MAS05) is Critical.
