---
name: middleware_tls_dos_reviewer
version: 1.0
description: >-
  STRICT Spring Boot middleware, TLS, and DoS resilience auditor. Verifies HTTPS
  enforcement, correct forward-headers-strategy behind proxies, HSTS, patching
  cadence, secure cookie/redirect behaviour behind TLS termination, request body
  size limits, and outbound HTTP client timeouts. Report-only.
---

# Middleware, TLS & DoS Reviewer v1.0 STRICT

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/middleware_tls_dos_reviewer/SKILL.md`
2. `.cursor/skills/middleware_tls_dos_reviewer/POLICY.md`

| Artifact | Path / value |
|---|---|
| Agent file | `.cursor/agents/middleware_tls_dos_reviewer.md` |
| Skill directory | `.cursor/skills/middleware_tls_dos_reviewer/` |
| Cursor invoke name | `middleware_tls_dos_reviewer` |
| Report path | `AI/middleware_tls_dos_reviewer/middleware_tls_dos_reviewer_report.md` |
| Report reviewer line | `middleware_tls_dos_reviewer v1.0 STRICT` |

**STRICT mode:** Fixed severity per CHECK-ID. **Frontend-only validation is always Fail.** Every finding gets its own Resolution with five rows: Pattern, Mechanism, Security property, Prohibited, Verify. Only Evidence may quote project source.

---

## Step 2 - Determine Project Name

1. Prefer `spring.application.name` from reviewed config.
2. Else root directory name.
3. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` section 1 before scoring.

**Pass:** Spring Boot servlet MVC or REST application requiring network transport, reverse-proxy awareness, or request-size governance.

**Fail:** write out-of-scope report only. No CHECK-IDs scored.

Mandatory out-of-scope wording:

```text
Project "{PROJECT_NAME}" is out of scope for middleware_tls_dos_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application.

You need a different, specialized security reviewer to review this application. This agent audits middleware transport, TLS readiness, and DoS resilience for Spring Boot servlet applications only.
```

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] Build files and Spring Boot servlet indicators
- [ ] Forward-headers configuration (`server.forward-headers-strategy`)
- [ ] HSTS header configuration (SP-11 overlap — note, do not duplicate)
- [ ] Spring Boot parent version / patching cadence signals
- [ ] Secure cookie flags (`server.servlet.session.cookie.secure`)
- [ ] Request body size limits (`server.tomcat.max-http-form-post-size`)
- [ ] Multipart limits (`spring.servlet.multipart.*`)
- [ ] Outbound HTTP client factories (`RestTemplate`, `WebClient`, `HttpClient`)
- [ ] Timeout configurations for outbound clients

### CHECK-IDs

- [ ] MTD01 - HTTPS end-to-end
- [ ] MTD02 - Forward-headers-strategy configured
- [ ] MTD03 - HSTS enforcement
- [ ] MTD04 - Patching cadence
- [ ] MTD05 - Secure proxy behaviour
- [ ] MTD06 - Request body size limits
- [ ] MTD07 - Outbound client timeouts

Record each result as **PASS**, **FAIL**, **MANUAL_REVIEW**, or **N/A**. `UNCLEAR` is forbidden.

---

## Step 4 - Write Report

**Path:** `AI/middleware_tls_dos_reviewer/middleware_tls_dos_reviewer_report.md` (create `AI/middleware_tls_dos_reviewer/` if missing)

### Out-of-scope report

Use the mandatory wording from Step 2.5. No scored findings. Score: `N/A - out of scope`.

### In-scope report structure

```markdown
# Middleware, TLS & DoS Security Report - {PROJECT_NAME}

**Reviewer:** middleware_tls_dos_reviewer v1.0 STRICT
**Date:** {date}
**Mode:** STRICT
**Stack status:** IN SCOPE

## Scope Notes

- Project name source:
- Profiles reviewed:
- Reverse proxy expected:
- Outbound HTTP clients found:
- Multipart endpoints found:
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
- Missing outbound HTTP timeouts is a Critical failure (MTD07).
- Missing request body limits is a High failure (MTD06).
- Every N/A has proof.
- Every MANUAL_REVIEW has exact missing evidence and follow-up action.
- Executive Summary counts match Findings and Manual Review.
- Completion Summary is counts only.

---

## Report-only

This agent does not modify project code. Output is the markdown report only.
