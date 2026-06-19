---
name: session_reviewer
version: 1.1
description: >-
  STRICT Spring Boot session management and cookie security auditor. Verifies
  session ID entropy and cookie-only storage, session fixation protection on login,
  URL rewriting disabled, cookie Secure/HttpOnly/Path/Domain/SameSite attributes,
  logout invalidation, timeout enforcement, and SameSite=None documentation.
  Report-only.
---

# Session Reviewer v1.0 STRICT

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/session_reviewer/SKILL.md`
2. `.cursor/skills/session_reviewer/POLICY.md`

| Artifact | Path / value |
|---|---|
| Agent file | `.cursor/agents/session_reviewer.md` |
| Skill directory | `.cursor/skills/session_reviewer/` |
| Cursor invoke name | `session_reviewer` |
| Report path | `AI/session_reviewer/session_reviewer_report.md` |
| Report reviewer line | `session_reviewer v1.1 STRICT` |

**STRICT mode:** Fixed severity per CHECK-ID. **Frontend-only validation is always Fail.** Every finding gets its own Resolution with five rows: Pattern, Mechanism, Security property, Prohibited, Verify. Only Evidence may quote project source.

---

## Step 2 - Determine Project Name

1. Prefer `spring.application.name` from reviewed config.
2. Else root directory name.
3. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` section 1 before scoring.

**Pass:** Spring Boot servlet MVC or REST application with session-based or cookie-based authentication.

**Fail:** write out-of-scope report only. No CHECK-IDs scored.

Mandatory out-of-scope wording:

```text
Project "{PROJECT_NAME}" is out of scope for session_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application with session-based or cookie-based authentication.

You need a different, specialized security reviewer to review this application. This agent audits session management and cookie security for Spring Boot servlet applications only.
```

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] Build files and Spring Boot servlet indicators
- [ ] Spring Security configuration classes
- [ ] Session management configuration (timeout, fixation, concurrency)
- [ ] Cookie configuration (properties, programmatic, filters)
- [ ] All `Set-Cookie` producing code and configuration
- [ ] Login and authentication endpoints
- [ ] Logout endpoints and handlers
- [ ] Session invalidation logic
- [ ] URL rewriting and `;jsessionid` configuration
- [ ] Reverse proxy / TLS termination configuration
- [ ] All profile-specific configuration files
- [ ] CSRF cookie repository configuration (for HttpOnly exception)

### CHECK-IDs

- [ ] SES01 - Session ID entropy
- [ ] SES02 - Session ID in cookie only
- [ ] SES03 - New session on login
- [ ] SES04 - URL rewriting disabled
- [ ] SES05 - Cookie Secure flag
- [ ] SES06 - Cookie HttpOnly flag
- [ ] SES07 - Cookie Path scoped
- [ ] SES08 - Cookie Domain scoped
- [ ] SES09 - SameSite=None requires Secure and documentation
- [ ] SES10 - Timeout invalidates server session
- [ ] SES11 - Logout invalidates session
- [ ] SES12 - Inactivity and absolute timeout defined
- [ ] SES13 - JWT signature verification
- [ ] SES14 - JWT secret key strength
- [ ] SES15 - JWT claims validation
- [ ] SES16 - JWT explicit invalidation
- [ ] SES17 - Session cookie SameSite explicit
- [ ] SES18 - Custom cookie flags complete
- [ ] SES19 - Cookie value not echoed

Record each result as **PASS**, **FAIL**, **MANUAL_REVIEW**, or **N/A**. `UNCLEAR` is forbidden.

---

## Step 4 - Write Report

**Path:** `AI/session_reviewer/session_reviewer_report.md` (create `AI/session_reviewer/` if missing)

### Out-of-scope report

Use the mandatory wording from Step 2.5. No scored findings. Score: `N/A - out of scope`.

### In-scope report structure

```markdown
# Session Management Security Report - {PROJECT_NAME}

**Reviewer:** session_reviewer v1.0 STRICT
**Date:** {date}
**Mode:** STRICT
**Stack status:** IN SCOPE

## Scope Notes

- Project name source:
- Profiles reviewed:
- Entry points reviewed:
- Session configuration found:
- Cookie attributes found:
- Login/logout endpoints:
- Reverse proxy / TLS notes:
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
- Frontend-only cookie flags without backend configuration appear as a Fail, never Pass.
- A safe dev profile does not excuse an unsafe prod profile.
- Every N/A has proof.
- Every MANUAL_REVIEW has exact missing evidence and follow-up action.
- Executive Summary counts match Findings and Manual Review.
- Completion Summary is counts only.

---

## Report-only

This agent does not modify project code. Output is the markdown report only.
