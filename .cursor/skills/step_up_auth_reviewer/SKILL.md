---
name: step_up_auth_reviewer
version: 1.0
disable-model-invocation: true
---

# Step-up Authentication Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar. Frontend-only confirmation is always a finding.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/step_up_auth_reviewer.md` |
| Skill directory | `.cursor/skills/step_up_auth_reviewer/` |
| Cursor invoke name | `step_up_auth_reviewer` |
| Report path | `AI/step_up_auth_reviewer/step_up_auth_reviewer_report.md` |
| Report reviewer line | `step_up_auth_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications with authenticated users and state-changing or high-impact operations.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |
| Servlet MVC or REST | `spring-boot-starter-web`, `@Controller`, `@RestController`, `SecurityFilterChain`, or MVC mappings |
| Authentication | Spring Security configuration, login endpoints, session management, user/role model |
| State-changing operations | `@PostMapping`, `@PutMapping`, `@PatchMapping`, `@DeleteMapping`, or service-layer mutations on sensitive data |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| Spring WebFlux primary stack only | Spring WebFlux |
| CLI/batch-only application with no authenticated users | Batch-only |
| Static website only | Static site |
| No authentication or user model | Unauthenticated app |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for step_up_auth_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application with authenticated users and state-changing or high-impact operations.

You need a different, specialized security reviewer to review this application. This agent audits step-up authentication for critical flows in Spring Boot servlet applications only.
```

No scored findings for out-of-scope projects.

---

## 2. File Discovery

Scan in this order.

### Build and Config

- `pom.xml`, `build.gradle`, `build.gradle.kts`
- `application.properties`, `application.yml`, and profile variants
- Spring Security configuration classes
- Session configuration and timeout settings

### Java/Kotlin Entry Points

- `@Controller`, `@RestController`
- `@RequestMapping`, `@GetMapping`, `@PostMapping`, `@PutMapping`, `@PatchMapping`, `@DeleteMapping`
- `@PreAuthorize`, `@Secured`, `@RolesAllowed`
- Custom security annotations and interceptors

### Critical Flow Surfaces

- Password change endpoints and services
- Email change endpoints and services
- MFA enable/disable endpoints
- Account deletion endpoints
- PII export/download endpoints
- Privilege escalation or role change endpoints
- Payout/bank detail change endpoints
- Secret/key rotation endpoints
- High-value transaction approval endpoints
- Admin override and impersonation endpoints

### Step-up Mechanism Surfaces

- Re-authentication controllers and filters
- OTP generation, sending, and validation logic
- TOTP/WebAuthn/passkey integration
- MFA challenge-response flow
- Email confirmation link generation and validation
- Step-up session attributes, tokens, or claims
- Step-up expiry and scope management

### Token/OTP Properties

- Random number generation for tokens
- Token storage (database, cache, session)
- Token hashing before storage
- Token comparison logic (constant-time or not)
- Token TTL and expiry enforcement
- Token single-use invalidation
- Rate limiting on verification endpoints

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find controllers | `rg -n "@(Controller\|RestController\|RequestMapping\|GetMapping\|PostMapping\|PutMapping\|DeleteMapping\|PatchMapping)" src` |
| Find state changes | `rg -n "@(PostMapping\|PutMapping\|PatchMapping\|DeleteMapping)\|save\(\|delete\(\|update\(" src` |
| Find security annotations | `rg -n "@(PreAuthorize\|Secured\|RolesAllowed\|WithMockUser)" src` |
| Find password change | `rg -n -i "password.*change\|changePassword\|updatePassword\|resetPassword\|newPassword\|oldPassword" src` |
| Find email change | `rg -n -i "email.*change\|changeEmail\|updateEmail\|newEmail\|verifyEmail" src` |
| Find MFA/OTP | `rg -n -i "mfa\|totp\|otp\|twoFactor\|2fa\|webauthn\|passkey\|authenticator\|verif" src` |
| Find account delete | `rg -n -i "deleteAccount\|removeAccount\|deactivate\|closeAccount\|accountDelet" src` |
| Find PII export | `rg -n -i "export\|download.*data\|gdpr\|dataSubject\|personalData\|piiExport" src` |
| Find privilege elevation | `rg -n -i "role.*change\|promote\|elevate\|grant.*role\|admin.*create\|setRole\|updateRole" src` |
| Find payout/bank | `rg -n -i "payout\|bank.*detail\|bankAccount\|routing\|iban\|swift\|paymentMethod" src` |
| Find secret rotation | `rg -n -i "rotate.*secret\|rotate.*key\|apiKey.*generate\|regenerate.*token\|resetApiKey" src` |
| Find step-up mechanisms | `rg -n -i "stepUp\|step.up\|reAuth\|re.auth\|confirmIdentity\|verifyIdentity\|challengeRequired\|secondFactor" src` |
| Find token generation | `rg -n -i "SecureRandom\|RandomStringUtils\|UUID\|generateToken\|tokenValue\|otpCode" src` |
| Find token storage/hash | `rg -n -i "BCrypt\|hash\|digest\|MessageDigest\|sha256\|sha512\|tokenHash\|hashedToken" src` |
| Find rate limiting | `rg -n -i "rateLimit\|rate.limit\|throttle\|maxAttempt\|lockout\|cooldown\|Bucket4j\|RateLimiter\|@RateLimit" src` |
| Find session freshness | `rg -n -i "lastAuthenticated\|authTime\|auth_time\|authenticatedAt\|sessionAge\|sessionCreated\|freshAuth" src` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| SUA01 | No authenticated users or no state-changing operations exist after complete inventory |
| SUA02 | No high-impact operations from the SP-03 examples list exist after scanning all controllers, services, and admin endpoints |
| SUA03 | No step-up mechanism exists (likely triggers SUA01 FAIL unless no critical flows exist) |
| SUA04 | No OTP or link token is used; other step-up methods (password re-entry, WebAuthn hardware) are used instead |
| SUA05 | No API endpoints perform sensitive mutations after complete inventory |
| SUA06 | No step-up mechanism exists (likely triggers SUA01 FAIL unless no critical flows exist) |

Do not use N/A because evidence was hard to trace. Use MANUAL_REVIEW.

---

## 5. CHECK-ID Scoring Procedure

### SUA01 - Critical Flows Require Fresh Identity Proof

Fail when any irreversible or high-impact flow (password change, email change, MFA disable, account delete, PII export, privilege elevation, payout/bank change, secret rotation, high-value transaction) executes without requiring fresh proof of identity beyond the existing session cookie.

Pass requires evidence that each critical flow has backend-enforced step-up before the mutation executes.

### SUA02 - Critical Flow Inventory Completeness

Fail when one or more high-impact operations from the SP-03 examples list exist in the codebase but lack step-up enforcement. The agent must actively search for all categories: password change, email change, MFA disable, account delete, PII export, privilege elevation, payout/bank change, secret rotation, and high-value transaction approval.

Pass requires a documented inventory of all critical flows with step-up evidence for each, or proof that the operation category does not exist.

### SUA03 - Recent Authenticator Event Required

Fail when step-up accepts an old session cookie, a stale authentication timestamp, or a long-lived bearer token as proof of identity instead of requiring a fresh authenticator event (password re-entry, OTP verification, MFA challenge, WebAuthn assertion).

Pass requires evidence that step-up enforcement checks authentication freshness with a verifiable timestamp or challenge-response, and rejects stale sessions.

### SUA04 - OTP/Token Security Properties

Fail when any OTP or link token used for step-up is missing one or more of:
1. Short TTL (minutes, not hours or days)
2. Single-use enforcement (invalidated immediately after successful use)
3. Rate limiting (brute-force protection on verification endpoint)
4. High entropy (cryptographically random, sufficient length)
5. Server-side hashed storage (not stored in plaintext)
6. Constant-time comparison where applicable

Each missing property is a separate finding under SUA04.

Pass requires evidence for all six properties.

### SUA05 - API Cannot Skip Step-up

Fail when an API endpoint performs a sensitive mutation and the caller can complete the request by presenting only a session cookie or bearer token without completing a step-up challenge. Test by tracing the API request flow for sensitive endpoints: if no step-up gate exists in the backend path, fail.

Pass requires evidence that direct API calls to sensitive endpoints without step-up completion are rejected with 403 or equivalent error.

### SUA06 - Step-up Scoped and Short-lived

Fail when step-up authorization grants broad access to multiple critical flows (e.g., a single "elevated" flag that unlocks all sensitive operations) or when the step-up result does not expire within a short time window.

Pass requires evidence that step-up is scoped to the specific action (or narrow action category) and expires quickly, so completing step-up for one action does not silently authorize other critical flows.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:

- step-up enforcement depends on service-layer ownership logic or role hierarchy not visible from source,
- authentication freshness is checked by an external identity provider or SSO whose behavior is not verifiable from repo,
- OTP/token properties depend on a third-party identity service configuration,
- rate limiting is enforced by infrastructure (API gateway, WAF, CDN) not visible in repo,
- critical flow inventory completeness requires business domain knowledge about which operations are high-impact,
- step-up scope and expiry are managed by session attributes or tokens whose lifecycle depends on runtime configuration,
- MFA/WebAuthn integration depends on external service not present in codebase.

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

- `Review authentication`
- `Grep codebase`
- `Add step-up`
- `Check manually`

Replace with direct action and pass signal.

---

## 8. Secure Resolution Catalog

Use one row set per finding.

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| SUA01 | Step-up gate on critical flows | Service-layer or security-filter check that requires fresh proof of identity before executing any irreversible or high-impact mutation | No critical flow executes without fresh identity verification beyond the existing session | Session-cookie-only authorization for sensitive mutations | Attempt sensitive action with valid session but without completing step-up; backend returns 403 or step-up challenge |
| SUA02 | Complete critical flow inventory | Documented list of all high-impact operations with step-up enforcement evidence for each; new critical flows require step-up by default | Every high-impact operation is inventoried and protected; no unprotected critical flow exists | Unprotected sensitive operations discovered by search but missing from step-up inventory | Search for all SP-03 example categories; confirm each has step-up enforcement or documented absence proof |
| SUA03 | Fresh authenticator event | Step-up requires a recent authenticator event with verifiable timestamp or challenge-response; stale session age triggers re-authentication | An old session cookie alone cannot satisfy step-up; fresh proof within a short window is required | Accepting stale session cookie or old authentication timestamp as step-up proof | Authenticate, wait beyond freshness window, attempt step-up; backend rejects with re-authentication prompt |
| SUA04 | Secure OTP/token properties | OTP/link tokens use cryptographically random generation, short TTL, single-use invalidation, rate-limited verification, server-side hashed storage, and constant-time comparison | Tokens cannot be brute-forced, replayed, intercepted from storage, or guessed | Plaintext token storage, long-lived tokens, reusable tokens, unlimited verification attempts, low-entropy tokens, timing-vulnerable comparison | Replay used OTP and confirm rejection; verify token hash in storage; submit rapid verification attempts and confirm rate limit; inspect token entropy |
| SUA05 | Backend API step-up enforcement | API endpoints for sensitive mutations enforce step-up in the server-side request processing path; no bypass through direct API call | Direct API calls without step-up completion are rejected regardless of valid session | API endpoint executing sensitive mutation with only session cookie or bearer token | Call sensitive API endpoint directly with valid session but no step-up token; confirm 403 or step-up challenge response |
| SUA06 | Action-scoped short-lived step-up | Step-up authorization is bound to the specific action and expires within minutes; separate critical actions require their own step-up | Completing step-up for one action does not unlock other critical flows; expired step-up requires re-verification | Single elevated flag unlocking all critical flows; step-up without expiry | Complete step-up for action A, immediately attempt action B without new step-up; confirm action B is rejected; wait beyond expiry and retry action A; confirm re-verification is required |

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
- Confirm frontend-only confirmation dialogs without backend enforcement are Fail.
- Confirm session-cookie-only authorization for sensitive mutations is always Fail.
- Confirm OTP replay is always Fail if token is not single-use.
- Confirm Executive Summary totals match Findings and Manual Review.
- Confirm no code changes were made.
