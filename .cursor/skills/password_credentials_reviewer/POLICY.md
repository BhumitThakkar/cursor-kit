# Password Credentials Security Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Frontend-only validation is always a finding.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/password_credentials_reviewer.md` |
| Cursor invoke name | `password_credentials_reviewer` |
| Report path | `AI/password_credentials_reviewer/password_credentials_reviewer_report.md` |
| Report reviewer line | `password_credentials_reviewer v1.0 STRICT` |

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
| PWD07 | No passwords via email | Application sends an initial, temporary, or reset password in plaintext via email or SMS |
| PWD08 | HTTPS only transmission | Application accepts credentials over an unencrypted HTTP connection |
| PWD11 | No plaintext storage | Application stores passwords in plaintext or uses reversible two-way encryption instead of hashing |
| PWD12 | Strong adaptive hashing | Password hashing uses MD5, SHA-1, SHA-256 (without salt/iterations), or custom algorithms instead of Argon2id, bcrypt, scrypt, or PBKDF2 |
| PWD14 | No {noop} in production | Spring Security uses `{noop}` prefix or equivalent `NoOpPasswordEncoder` in production configuration |

### High

| ID | Citation | Condition |
|---|---|---|
| PWD01 | Minimum length enforcement | Password minimum length is less than 15 characters (single-factor) or 8 characters (MFA context) |
| PWD03 | Password blocklist verification | Application does not compare new passwords against a blocklist of common, expected, breached, or context-specific values |
| PWD06 | Change requires old and new | Password change endpoint does not require the user to provide their old (current) password to set a new one |
| PWD09 | No passwords in GET | Password is sent in a URL query string (GET parameter) rather than the body of a POST/PUT request |
| PWD10 | Secure reset links | Password reset token is not one-time use, lacks a short time limit, or is stored in plaintext in the database |
| PWD13 | Unique salt per password | Password hashing does not use a unique salt per password (note: bcrypt/argon2 handle this automatically) |
| PWD15 | Account lockout protection | Application lacks temporary account lockout or progressive throttling after N failed login attempts |

### Medium

| ID | Citation | Condition |
|---|---|---|
| PWD02 | Maximum length and truncation | Password maximum length is less than 64 characters, or application silently truncates submitted passwords |
| PWD04 | No composition-only rules | Application uses composition rules (e.g., must contain upper, lower, number, special) as the primary security control instead of length and blocklist |
| PWD05 | No forced periodic rotation | Application forces periodic password expiration/rotation (e.g., every 90 days) without evidence of compromise |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| PWD01 | Backend enforces minimum length of 15 characters (or 8 characters if MFA is strictly enforced). |
| PWD02 | Backend allows passwords of at least 64 characters without silent truncation. |
| PWD03 | Backend validation includes a check against a breached/common password list or an internal blocklist. |
| PWD04 | Application relies on length and blocklist for strength; composition rules (if present) are not the sole strength control. |
| PWD05 | No code enforces arbitrary periodic password expiration. |
| PWD06 | Password change endpoint requires both the old password and the new password. |
| PWD07 | Passwords are never sent via email or SMS. Reset flows use secure one-time links instead. |
| PWD08 | Login and credential endpoints require HTTPS. |
| PWD09 | Credentials are only accepted via POST/PUT request bodies or standard Auth headers, never in GET query strings. |
| PWD10 | Password reset links use high-entropy tokens that are one-time use, time-limited, and stored as a hash server-side. |
| PWD11 | All stored passwords are one-way hashed. |
| PWD12 | Application uses `BCryptPasswordEncoder`, `Argon2PasswordEncoder`, or equivalent strong adaptive hashing with current work factors. |
| PWD13 | Hashing algorithm includes a unique salt per user (inherent to bcrypt/argon2). |
| PWD14 | No `{noop}` or `NoOpPasswordEncoder` is present in any production profile. |
| PWD15 | Backend tracks failed logins and enforces a temporary lockout or progressive delay. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| PWD01-PWD06, PWD10 | Application does not handle local user registration, password changes, or resets (e.g., uses external IdP/SSO exclusively). |
| PWD07 | Application does not send any emails or SMS messages. |
| PWD08 | Covered by stack-level TLS reviewer (if out of scope for specific component analysis). |
| PWD09 | No login or credential endpoints exist. |
| PWD11-PWD14 | Application does not store or verify local passwords (e.g., pure OAuth2 resource server, SSO only). |
| PWD15 | Application uses external IdP that handles lockout, or no local login endpoints exist. |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- password validation uses external service (e.g., HIBP API) whose integration cannot be fully verified from code,
- lockout mechanism relies on infrastructure components (e.g., WAF, API Gateway) not defined in the repository,
- password storage uses a library whose internal hashing algorithm is not clear,
- token hashing for reset links happens in a library where storage format is unknown,
- MFA status (for length requirements) is determined at runtime or by an external system.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| PWD01 | Passwords | High | Minimum length enforcement |
| PWD02 | Passwords | Medium | Maximum length and truncation |
| PWD03 | Passwords | High | Password blocklist verification |
| PWD04 | Passwords | Medium | No composition-only rules |
| PWD05 | Passwords | Medium | No forced periodic rotation |
| PWD06 | Passwords | High | Change requires old and new |
| PWD07 | Passwords | Critical | No passwords via email |
| PWD08 | Passwords | Critical | HTTPS only transmission |
| PWD09 | Passwords | High | No passwords in GET |
| PWD10 | Passwords | High | Secure reset links |
| PWD11 | Passwords | Critical | No plaintext storage |
| PWD12 | Passwords | Critical | Strong adaptive hashing |
| PWD13 | Passwords | High | Unique salt per password |
| PWD14 | Passwords | Critical | No {noop} in production |
| PWD15 | Passwords | High | Account lockout protection |
