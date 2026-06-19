---
name: password_credentials_reviewer
version: 1.0
disable-model-invocation: true
---

# Password Credentials Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar. Frontend-only validation is always a finding.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/password_credentials_reviewer.md` |
| Skill directory | `.cursor/skills/password_credentials_reviewer/` |
| Cursor invoke name | `password_credentials_reviewer` |
| Report path | `AI/password_credentials_reviewer/password_credentials_reviewer_report.md` |
| Report reviewer line | `password_credentials_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications with local password authentication or credential storage.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |
| Servlet MVC or REST | `spring-boot-starter-web`, `@Controller`, `@RestController`, `SecurityFilterChain`, or MVC mappings |
| Password surface | `PasswordEncoder`, login endpoints, user entities with passwords, registration flows, password reset flows |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| Spring WebFlux primary stack only | Spring WebFlux |
| CLI/batch-only application | Batch-only |
| Pure OAuth2/SSO resource server with no local passwords | SSO-only |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for password_credentials_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application with local password authentication or credential storage.

You need a different, specialized security reviewer to review this application. This agent audits password and credential storage for Spring Boot servlet applications only.
```

No scored findings for out-of-scope projects.

---

## 2. File Discovery

Scan in this order.

### Build and Config

- `pom.xml`, `build.gradle`, `build.gradle.kts`
- `application.properties`, `application.yml`, and profile variants

### Spring Security Configuration

- `SecurityFilterChain` definitions
- `PasswordEncoder` bean definitions (`BCryptPasswordEncoder`, `Argon2PasswordEncoder`, `NoOpPasswordEncoder`)

### Password Validation

- User registration forms and DTOs (`@Size`, `@Pattern`, custom validators)
- Service classes handling password changes and validation
- Integration with breached password APIs (e.g., HaveIBeenPwned)

### Password Flows

- Registration endpoints
- Login endpoints
- Password change endpoints
- Password reset token generation and verification endpoints

### Lockout Mechanisms

- Authentication success/failure event listeners
- User entity fields tracking failed attempts
- Rate limiting filters or interceptors

### Mail Configuration

- `JavaMailSender` usage for password resets or initial passwords
- Email templates containing tokens or passwords

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find encoders | `rg -n "PasswordEncoder\|BCryptPasswordEncoder\|Argon2PasswordEncoder\|Pbkdf2PasswordEncoder\|NoOpPasswordEncoder\|\{noop\}" src .` |
| Find size validation | `rg -n "@Size.*password\|@Length.*password\|password.*length" src` |
| Find composition | `rg -n "@Pattern.*password\|(?=.*[A-Z])" src` |
| Find blocklists | `rg -n "blocklist\|blacklist\|breached\|pwned\|commonPassword" src` |
| Find rotation | `rg -n "passwordExpired\|credentialsExpired\|password.*age\|expirePassword" src` |
| Find password change | `rg -n "changePassword\|updatePassword\|oldPassword\|currentPassword" src` |
| Find emails | `rg -n "JavaMailSender\|mailSender\|sendMail\|email\|password.*email" src` |
| Find GET passwords | `rg -n "@GetMapping.*password\|@RequestParam.*password" src` |
| Find reset tokens | `rg -n "resetToken\|forgotPassword\|passwordReset\|generateToken\|SecureRandom" src` |
| Find lockout | `rg -n "AuthenticationFailureBadCredentialsEvent\|failedLogin\|loginAttempt\|lockout\|accountLocked" src` |
| Find plaintext | `rg -n "String password = \"\|password = \'" src` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| PWD01-PWD06, PWD10 | Application does not handle local user registration, password changes, or resets. |
| PWD07 | Application does not send any emails or SMS messages. |
| PWD09 | No login or credential endpoints exist. |
| PWD11-PWD14 | Application does not store or verify local passwords. |
| PWD15 | Application uses external IdP that handles lockout, or no local login endpoints exist. |

Do not use N/A because evidence was hard to trace. Use MANUAL_REVIEW.

---

## 5. CHECK-ID Scoring Procedure

### PWD01 - Minimum Length Enforcement
Fail when backend validation allows passwords shorter than 15 characters (single-factor) or 8 characters (MFA). Frontend-only validation is Fail.

### PWD02 - Maximum Length and Truncation
Fail when backend validation restricts maximum length to less than 64 characters, or silently truncates passwords before hashing.

### PWD03 - Password Blocklist Verification
Fail when new passwords are not checked against a blocklist of breached, common, or service-specific passwords.

### PWD04 - No Composition-Only Rules
Fail when complex composition rules (e.g., must contain upper/lower/number/special) are used as the main control instead of length and blocklists.

### PWD05 - No Forced Periodic Rotation
Fail when application enforces periodic password changes (e.g., every 90 days) without compromise evidence.

### PWD06 - Change Requires Old and New
Fail when password change endpoint does not require the user's current password.

### PWD07 - No Passwords via Email
Fail when initial, temporary, or reset passwords are sent via email or SMS.

### PWD08 - HTTPS Only Transmission
Fail when application accepts credentials over unencrypted HTTP.

### PWD09 - No Passwords in GET
Fail when passwords are sent in URL query strings.

### PWD10 - Secure Reset Links
Fail when password reset links use weak tokens, lack short time limits, or are stored in plaintext.

### PWD11 - No Plaintext Storage
Fail when passwords are stored in plaintext or reversibly encrypted.

### PWD12 - Strong Adaptive Hashing
Fail when hashing uses weak algorithms (MD5, SHA-1, SHA-256) instead of Argon2id, bcrypt, scrypt, or PBKDF2.

### PWD13 - Unique Salt Per Password
Fail when hashing does not use a unique salt per password (bcrypt/argon2 do this automatically).

### PWD14 - No {noop} in Production
Fail when `{noop}` or `NoOpPasswordEncoder` is used in production.

### PWD15 - Account Lockout Protection
Fail when application lacks temporary account lockout or throttling after N failed logins.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:
- Password validation uses an external service API.
- Lockout relies on infrastructure (WAF, API Gateway).
- Password storage library details are unknown.

---

## 7. Report Requirements

Every scored finding must include: File, Evidence, Policy Rule, Possible Attack Scenario, and five Resolution rows.

### 7.1 Verify Row Rules

Every Verify row must include: Action + pass signal.
Forbidden: `Review passwords`, `Check manually`.

---

## 8. Secure Resolution Catalog

Use one row set per finding.

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| PWD01 | Length enforcement | Use `@Size(min=15)` or `min=8` with MFA in DTOs | Passwords are long enough to resist brute force | Short passwords | Submit short password to backend; confirm validation error |
| PWD02 | Generous max length | Use `@Size(max=64)` or higher; remove truncation logic | Passwords can be long and use passphrases | Restrictive max length or truncation | Submit 64-character password; confirm successful registration/login |
| PWD03 | Blocklist check | Implement custom validator against HIBP API or local blocklist | Common/breached passwords are rejected | Allowing 'Password123' | Submit breached password; confirm validation error |
| PWD04 | Rely on length/blocklist | Remove strict composition regexes; enforce length and blocklist | Users can use secure passphrases without arbitrary constraints | Composition-only rules | Submit long passphrase without numbers/specials; confirm success |
| PWD05 | No forced rotation | Remove periodic expiration logic (`credentialsExpired`) | Passwords are only changed upon compromise | Arbitrary 90-day rotation | Inspect user entity/logic; confirm no forced periodic expiration |
| PWD06 | Old password required | Change endpoint verifies `PasswordEncoder.matches(old, current)` | Account takeover via abandoned session is prevented | Changing password without old password | Submit password change without old password; confirm rejection |
| PWD07 | Token-based reset | Send only secure token links via email, never passwords | Passwords are never exposed in email transit or storage | Plaintext passwords in email | Trigger reset; inspect email content; confirm only token link is present |
| PWD08 | HTTPS enforcement | Configure `server.ssl.enabled=true` or enforce via proxy | Passwords are encrypted in transit | HTTP login | Access login via HTTP; confirm redirect to HTTPS or rejection |
| PWD09 | POST for credentials | Use `@PostMapping` and `@RequestBody` or form data | Passwords are not logged in server access logs or browser history | GET parameters for passwords | Submit login via GET; confirm 405 Method Not Allowed |
| PWD10 | Secure reset tokens | Use `SecureRandom` for tokens, short TTL (e.g., 15 mins), and store hashed | Reset links cannot be guessed, reused, or stolen from DB | Predictable, long-lived, or plaintext tokens | Request reset; wait > TTL; confirm token expired; verify DB stores token hash |
| PWD11 | One-way hashing | Only store output of `PasswordEncoder` | Passwords cannot be recovered from DB | Plaintext or reversible encryption | Inspect DB; confirm passwords look like hashes |
| PWD12 | Strong adaptive hashing | Use `BCryptPasswordEncoder` or `Argon2PasswordEncoder` | Hashes resist offline cracking | MD5, SHA-1, un-iterated SHA-256 | Inspect config; confirm strong encoder is bean |
| PWD13 | Automatic salting | Rely on bcrypt/argon2 internal salting | Rainbow table attacks are prevented | Static or no salt | Register two users with same password; confirm DB hashes differ |
| PWD14 | Remove {noop} | Remove `{noop}` prefix and `NoOpPasswordEncoder` from prod config | Production passwords are hashed | `{noop}` in prod | Search prod config; confirm `{noop}` is absent |
| PWD15 | Temporary lockout | Track failed logins; block account for time period after N failures | Online brute force and stuffing are mitigated | Unlimited login attempts | Attempt 10 failed logins; confirm account locked or throttled |

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
- Confirm `{noop}` is Critical failure.
- Confirm frontend-only validation is Fail.
