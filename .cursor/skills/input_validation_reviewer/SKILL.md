---
name: input_validation_reviewer
version: 1.0
disable-model-invocation: true
---

# Input Validation Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar. Frontend-only validation is always a finding.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/input_validation_reviewer.md` |
| Skill directory | `.cursor/skills/input_validation_reviewer/` |
| Cursor invoke name | `input_validation_reviewer` |
| Report path | `AI/input_validation_reviewer/input_validation_reviewer_report.md` |
| Report reviewer line | `input_validation_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications that accept external input.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |
| Servlet MVC or REST | `spring-boot-starter-web`, `@Controller`, `@RestController`, `SecurityFilterChain`, or MVC mappings |
| External input surface | Controllers, forms, JSON APIs, headers, cookies, multipart, webhooks, imports, scheduled feeds, or backend feeds |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| Spring WebFlux primary stack only | Spring WebFlux |
| CLI/batch-only application with no external input boundary | Batch-only |
| Static website only | Static site |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for input_validation_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application with externally reachable inputs.

You need a different, specialized security reviewer to review this application. This agent audits backend/server-side input validation for Spring Boot servlet applications only.
```

No scored findings for out-of-scope projects.

---

## 2. File Discovery

Scan in this order.

### Build and Config

- `pom.xml`, `build.gradle`, `build.gradle.kts`
- `application.properties`, `application.yml`, and profile variants
- Jackson configuration, MVC configuration, converters, binders

### Java/Kotlin Entry Points

- `@Controller`, `@RestController`
- `@RequestMapping`, `@GetMapping`, `@PostMapping`, `@PutMapping`, `@PatchMapping`, `@DeleteMapping`
- `@RequestParam`, `@PathVariable`, `@RequestHeader`, `@CookieValue`, `@RequestBody`, `@ModelAttribute`
- `MultipartFile`
- Webhook controllers, scheduled imports, message/listener entry points, backend feed parsers

### Validation Evidence

- Bean Validation annotations: `@Valid`, `@Validated`, `@Pattern`, `@Size`, `@Min`, `@Max`, `@Email`, `@NotBlank`, custom validators
- DTOs and form classes
- Central validation constants and regex patterns
- Service-layer semantic validation
- Tests proving invalid direct requests are rejected

### Frontend Validation Evidence

- HTML `required`, `pattern`, `min`, `max`, `maxlength`
- JavaScript validation logic
- Thymeleaf form constraints

Frontend evidence never proves Pass by itself. It only creates a requirement to find matching backend enforcement.

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find controllers | `rg -n "@(Controller|RestController|RequestMapping|GetMapping|PostMapping|PutMapping|DeleteMapping|PatchMapping)" src` |
| Find raw input parameters | `rg -n "@(RequestParam|PathVariable|RequestHeader|CookieValue|RequestBody|ModelAttribute)" src` |
| Find raw servlet access | `rg -n "HttpServletRequest|ServletRequest|getParameter|getHeader|getCookies" src` |
| Find validation annotations | `rg -n "@(Valid|Validated|Pattern|Size|Email|Min|Max|NotBlank|NotNull|Constraint)" src` |
| Find regex definitions | `rg -n "Pattern\\.compile|matches\\(|replaceAll\\(|regex|regexp|@Pattern" src` |
| Find frontend validation | `rg -n "required|pattern=|maxlength|min=|max=|checkValidity|setCustomValidity|addEventListener\\(.*submit" src` |
| Find multipart metadata | `rg -n "MultipartFile|getOriginalFilename|getContentType|Content-Type|filename" src` |
| Find webhooks/imports | `rg -n "webhook|import|csv|scheduled|@Scheduled|listener|MessageMapping|KafkaListener|RabbitListener" src` |
| Find Jackson unknown-field settings | `rg -n "FAIL_ON_UNKNOWN_PROPERTIES|ignoreUnknown|@JsonIgnoreProperties|ObjectMapper|Jackson2ObjectMapperBuilder" src` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| IV01-IV08 | No external input surface after stack gate inventory; rare for in-scope app |
| IV03 | No frontend/UI validation exists after template and JS scan |
| IV09 | No multipart/file metadata or other client metadata is used |
| IV10 | Project has no test framework or no runnable tests in repo; still create MANUAL_REVIEW if release gate needs runtime proof |

Do not use N/A because evidence was hard to trace. Use MANUAL_REVIEW.

---

## 5. CHECK-ID Scoring Procedure

### IV01 - External Input Allow-list or Typed Parser

Fail when an external input enters controller/service logic without a field-specific allow-list, typed parser, enum conversion, or Bean Validation rule.

Pass requires evidence that each input has a positive shape/type rule.

### IV02 - Backend Validation Required

Fail when backend accepts raw user input without server-side validation.

Client-side validation, browser constraints, UI JavaScript, API docs, or comments are not backend validation.

### IV03 - Frontend Validation Independently Enforced Backend-side

Fail when frontend validates a field and no equivalent or stricter backend validation exists.

Required evidence: frontend constraint plus backend enforcement or direct request test.

### IV04 - Reject Mismatch Fail-Closed

Fail when invalid input is sanitized, coerced, truncated, defaulted, or ignored in a way that still accepts the request without explicit safe business reason.

Pass requires reject behavior such as 400/422, validation error, or safe domain-specific denial.

### IV05 - Syntax and Semantic Validation

Fail when syntax is checked but business meaning is not checked for values that affect state, ownership, amount, date ranges, roles, workflow state, or tenant boundaries.

### IV06 - Trust Boundary Coverage

Fail when headers, cookies, path variables, query parameters, JSON bodies, multipart metadata, webhooks, scheduled imports, or backend feeds are treated as trusted or skipped by validation inventory.

### IV07 - Canonicalize Before Validation

Fail when validation is applied before decoding/normalization, when values are decoded multiple times after validation, or when encoded bypasses are possible.

### IV08 - ReDoS-safe Anchored Regex

Fail when regex validation is unanchored, uses partial matching for allow-list checks, or contains high-risk nested quantifiers/backtracking without tests or safe engine constraints.

### IV09 - Client Metadata Not Trusted

Fail when `Content-Type`, file extension, original filename, request header, hidden field, cookie value, or other client metadata is trusted as proof of safety without server-side verification.

### IV10 - Backend Bypass Tests

Fail when no tests or documented runtime evidence prove invalid direct requests are rejected by the backend for externally reachable mutation or high-risk input paths.

This check enforces the non-negotiable frontend-bypass requirement.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:

- validation is implemented in a helper whose behavior is not visible from the repository,
- validation rules are loaded from deployment config not present in repo,
- semantic validation depends on database state or authenticated user ownership,
- backend bypass proof needs a running app or two authenticated roles,
- regex safety cannot be determined statically,
- import/webhook trust model depends on upstream signatures not visible in code.

Manual review is not Pass.

---

## 7. Report Requirements

Every scored finding must include:

| Field | Requirement |
|---|---|
| File | Project-relative file path and line number |
| Evidence | Exact source/config/test line or runtime proof |
| Policy Rule | `POLICY.md - {CHECK-ID} - {citation}` |
| Possible Attack Scenario | Realistic impact in one or two sentences |
| Resolution | Five rows from section 8 |

Evidence is the only field that may quote project source. Resolution rows are prose, not pasteable code.

### 7.1 Verify Row Rules

Every Verify row must include:

1. Action: what to test, inspect, or search.
2. Pass signal: observable result that proves the fix.

Forbidden Verify text:

- `Review validation`
- `Grep codebase`
- `Add tests`
- `Check manually`

Replace with direct action and pass signal.

---

## 8. Secure Resolution Catalog

Use one row set per finding.

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| IV01 | Field-specific allow-list | Bean Validation, enum conversion, typed parsers, or custom validators per DTO field | Every external input has a positive expected shape or type | Raw unbounded input | Submit malformed, oversized, null, and unexpected values for each field; backend rejects invalid values |
| IV02 | Server-side validation gate | `@Valid` or service-layer validation on every controller/import boundary | Backend rejects invalid requests without relying on browser code | Client-only validation | Send invalid request directly with curl/test client; backend returns validation failure |
| IV03 | Frontend bypass resistance | Mirror or strengthen every UI constraint in DTO/service validation | UI bypass cannot submit invalid state | Frontend-only rule | Bypass HTML/JS and submit invalid value directly; backend rejects with validation error |
| IV04 | Reject on mismatch | Validation failure returns controlled 400/422 or safe business error | Unknown shapes are not accepted or silently transformed | Sanitize-and-accept | Send payload with disallowed characters or wrong enum; request is rejected and state does not change |
| IV05 | Syntax plus semantics | Combine type/format validation with business-rule checks in service layer | Values are valid for this user, tenant, workflow, and operation | Shape-only approval | Submit syntactically valid but semantically invalid value; backend rejects and state is unchanged |
| IV06 | Complete trust-boundary inventory | Inventory controllers, headers, cookies, path/query/body fields, multipart metadata, webhooks, imports, and feeds | Every untrusted boundary is validated | Trusted external feed | Scope Notes list each boundary and validation evidence; no unreviewed input group remains |
| IV07 | Canonical validation | Decode/normalize once at boundary, validate canonical value, and avoid post-validation decoding | Encoded bypasses cannot pass validation | Validate-before-decode | Submit encoded and double-encoded invalid payloads; backend rejects canonical invalid value |
| IV08 | Safe full-string regex | Anchored regexes, bounded quantifiers, safe validators, and ReDoS tests for complex patterns | Validation cannot be bypassed by substring match or abused for CPU exhaustion | Unanchored unsafe regex | Long malicious regex payload completes within limit and is rejected |
| IV09 | Server-trusted evidence only | Verify file/type/path/security decisions with server-side checks, not client metadata | Spoofed client metadata cannot mark input safe | Trust client metadata | Spoof Content-Type, filename, extension, or hidden field; backend still rejects or verifies independently |
| IV10 | Backend bypass test coverage | Add direct controller/integration tests for invalid requests that skip browser constraints | Security validation has executable proof | No bypass tests | Test suite includes direct invalid request cases and they fail closed |

---

## 9. Scoring Formula

```text
Base Score: 100

Critical: -20
High:     -10
Medium:   -5
Low:      -2
Info:      0

Floor: 0

Grade:
90-100 = A
75-89  = B
60-74  = C
40-59  = D
0-39   = F
```

Manual review does not reduce the score, but it blocks a clean security conclusion.

---

## 10. Final Self-Validation

Before finalizing a report:

- Confirm stack gate result and evidence.
- Confirm every CHECK-ID is PASS, FAIL, MANUAL_REVIEW, or N/A.
- Confirm no `UNCLEAR` appears.
- Confirm every failed CHECK-ID has the required finding fields.
- Confirm every N/A includes proof.
- Confirm frontend-only validation is Fail.
- Confirm IV10 is Fail or Pass with actual backend bypass test evidence.
- Confirm Executive Summary totals match Findings and Manual Review.
- Confirm no code changes were made.
