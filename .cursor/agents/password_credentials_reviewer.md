---
name: password_credentials_reviewer
version: 1.0
description: >-
  STRICT Spring Boot password and credential storage auditor. Verifies password
  length, blocklist usage, no forced rotation, change flows (old+new), no email
  transmission, secure reset flows, strong hashing (Argon2id/bcrypt), salting,
  no plaintext storage or {noop}, and account lockout protection. Report-only.
---

# Password Credentials Reviewer v1.0 STRICT

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/password_credentials_reviewer/SKILL.md`
2. `.cursor/skills/password_credentials_reviewer/POLICY.md`

| Artifact | Path / value |
|---|---|
| Agent file | `.cursor/agents/password_credentials_reviewer.md` |
| Skill directory | `.cursor/skills/password_credentials_reviewer/` |
| Cursor invoke name | `password_credentials_reviewer` |
| Report path | `AI/password_credentials_reviewer/password_credentials_reviewer_report.md` |
| Report reviewer line | `password_credentials_reviewer v1.0 STRICT` |

**STRICT mode:** Fixed severity per CHECK-ID. **Frontend-only validation is always Fail.** Every finding gets its own Resolution with five rows: Pattern, Mechanism, Security property, Prohibited, Verify. Only Evidence may quote project source.

---

## Step 2 - Determine Project Name

1. Prefer `spring.application.name` from reviewed config.
2. Else root directory name.
3. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` section 1 before scoring.

**Pass:** Spring Boot servlet MVC or REST application with local password authentication or credential storage.

**Fail:** write out-of-scope report only. No CHECK-IDs scored.

Mandatory out-of-scope wording:

```text
Project "{PROJECT_NAME}" is out of scope for password_credentials_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application with local password authentication or credential storage.

You need a different, specialized security reviewer to review this application. This agent audits password and credential storage for Spring Boot servlet applications only.
```

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] Build files and Spring Boot servlet indicators
- [ ] Spring Security configuration classes
- [ ] `PasswordEncoder` beans and default encoders
- [ ] Password validation rules (annotations, regex, custom validators)
- [ ] Registration and password change endpoints
- [ ] Password reset endpoints and token generation
- [ ] Email service configuration and templates
- [ ] Authentication providers and login endpoints
- [ ] Failed login tracking and lockout logic
- [ ] TLS/HTTPS configuration
- [ ] Password entity models and storage annotations

### CHECK-IDs

- [ ] PWD01 - Minimum length enforcement
- [ ] PWD02 - Maximum length and truncation
- [ ] PWD03 - Password blocklist verification
- [ ] PWD04 - No composition-only rules
- [ ] PWD05 - No forced periodic rotation
- [ ] PWD06 - Change requires old and new
- [ ] PWD07 - No passwords via email
- [ ] PWD08 - HTTPS only transmission
- [ ] PWD09 - No passwords in GET
- [ ] PWD10 - Secure reset links
- [ ] PWD11 - No plaintext storage
- [ ] PWD12 - Strong adaptive hashing
- [ ] PWD13 - Unique salt per password
- [ ] PWD14 - No {noop} in production
- [ ] PWD15 - Account lockout protection

Record each result as **PASS**, **FAIL**, **MANUAL_REVIEW**, or **N/A**. `UNCLEAR` is forbidden.

---

## Step 4 - Write Report

**Path:** `AI/password_credentials_reviewer/password_credentials_reviewer_report.md` (create `AI/password_credentials_reviewer/` if missing)

### Out-of-scope report

Use the mandatory wording from Step 2.5. No scored findings. Score: `N/A - out of scope`.

### In-scope report structure

```markdown
# Password Credentials Security Report - {PROJECT_NAME}

**Reviewer:** password_credentials_reviewer v1.0 STRICT
**Date:** {date}
**Mode:** STRICT
**Stack status:** IN SCOPE

## Scope Notes

- Project name source:
- Profiles reviewed:
- Password validation found:
- Password encoders found:
- Reset/change flows found:
- Lockout mechanisms found:
- N/A checks with proof:
- Manual review items:

## Executive Summary

| Severity | Count |
|---|---:|
| Critical | 0 |
| High | 0 |
| Medium | 0 |
| Low | 0 |
| Manual Review | 0 |

**Security Score:** {score}/100 - Grade {letter}
**Verdict:** {Excellent | Good | Fair | Poor | Critical - Do Not Deploy}

## Findings

### 1. {CHECK-ID} - {title}

**Severity:** Critical|High|Medium|Low
**File:** `path:line`
**Evidence:** `safe quoted evidence`
**Policy Rule:** `POLICY.md - {CHECK-ID} - {citation}`
**Possible Attack Scenario:** One or two sentences.

| Resolution row | Content |
|---|---|
| Pattern | SKILL.md section 8 - {CHECK-ID} - {pattern name} |
| Mechanism | Framework API or architecture approach in prose. |
| Security property | What must be true after fix. |
| Prohibited | Short label only. |
| Verify | Action plus pass signal. |

## Manual Review

## Passed Checks

## Completion Summary
```

---

## Step 5 - Final Validation

Before saving the report, verify:

- Every failed CHECK-ID has File, Evidence, Policy Rule, Possible Attack Scenario, and five Resolution rows.
- Every Verify row includes an action and pass signal.
- Frontend-only validation appears as a Fail, never Pass.
- `{noop}` or plaintext passwords are a Critical failure.
- Every N/A has proof.
- Every MANUAL_REVIEW has exact missing evidence and follow-up action.
- Executive Summary counts match Findings and Manual Review.
- Completion Summary is counts only.

---

## Report-only

This agent does not modify project code. Output is the markdown report only.
