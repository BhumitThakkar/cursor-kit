---
name: clickjacking_headers_reviewer
version: 2.0
description: >-
  STRICT Spring Boot security headers auditor. Verifies HTTP CSP frame-ancestors
  enforcement, absence of meta-tag frame configurations, rejection of JS-only frame
  busting, enforcement of Cache-Control on authenticated pages, and presence of standard
  security headers (HSTS, nosniff, etc.). Report-only.
---

# Clickjacking & Headers Reviewer v2.0 STRICT

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/clickjacking_headers_reviewer/SKILL.md`
2. `.cursor/skills/clickjacking_headers_reviewer/POLICY.md`

| Artifact | Path / value |
|---|---|
| Agent file | `.cursor/agents/clickjacking_headers_reviewer.md` |
| Skill directory | `.cursor/skills/clickjacking_headers_reviewer/` |
| Cursor invoke name | `clickjacking_headers_reviewer` |
| Report path | `AI/clickjacking_headers_reviewer/clickjacking_headers_reviewer_report.md` |
| Report reviewer line | `clickjacking_headers_reviewer v2.0 STRICT` |

**STRICT mode:** Fixed severity per CHECK-ID. HDR06 owns auth-page Cache-Control — not `disclosure_reviewer`. Companion: **`disclosure_reviewer` v2.0** for errors, static leaks, logs.

---

## Step 2 - Determine Project Name

1. Prefer `spring.application.name` from reviewed config.
2. Else root directory name.
3. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` section 1 before scoring.

**Pass:** Spring Boot servlet MVC or REST application returning HTML pages or requiring standard HTTP security headers.

**Fail:** write out-of-scope report only. No CHECK-IDs scored.

Mandatory out-of-scope wording:

```text
Project "{PROJECT_NAME}" is out of scope for clickjacking_headers_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application returning HTML pages or requiring standard HTTP security headers.

You need a different, specialized security reviewer to review this application. This agent audits clickjacking defenses and security headers for Spring Boot servlet applications only.
```

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] Build files and Spring Boot servlet indicators
- [ ] Spring Security configuration (`SecurityFilterChain` headers config)
- [ ] Custom `Filter` classes manipulating `HttpServletResponse` headers
- [ ] HTML view templates (Thymeleaf, Freemarker)
- [ ] JavaScript files for frame-busting logic
- [ ] Application properties disabling default Spring Security headers
- [ ] Cache-Control configurations for authenticated endpoints

### CHECK-IDs

- [ ] HDR01 - HTTP CSP frame-ancestors
- [ ] HDR02 - No meta tag frame-ancestors
- [ ] HDR03 - CSP Report-Only is not enforcement
- [ ] HDR04 - No JS-only frame busting
- [ ] HDR05 - Standard security headers
- [ ] HDR06 - Safe Cache-Control for auth pages
- [ ] HDR07 - HSTS configured
- [ ] HDR08 - CSP configured
- [ ] HDR09 - No unguarded defaultsDisabled
- [ ] HDR10 - Explicit nosniff
- [ ] HDR11 - CSP no unsafe script-src
- [ ] HDR12 - CSP no wildcard script-src
- [ ] HDR13 - Referrer-Policy set
- [ ] HDR14 - X-XSS-Protection (Info only)

Record each result as **PASS**, **FAIL**, **MANUAL_REVIEW**, or **N/A**. `UNCLEAR` is forbidden.

---

## Step 4 - Write Report

**Path:** `AI/clickjacking_headers_reviewer/clickjacking_headers_reviewer_report.md` (create `AI/clickjacking_headers_reviewer/` if missing)

### Out-of-scope report

Use the mandatory wording from Step 2.5. No scored findings. Score: `N/A - out of scope`.

### In-scope report structure

```markdown
# Clickjacking & Headers Security Report - {PROJECT_NAME}

**Reviewer:** clickjacking_headers_reviewer v2.0 STRICT
**Date:** {date}
**Mode:** STRICT
**Stack status:** IN SCOPE

## Scope Notes

- Project name source:
- Profiles reviewed:
- Header configurations found:
- Disabled headers found:
- HTML templates found:
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
- Frontend JS-only frame busting appears as a Fail, never Pass (HDR04).
- Placing `frame-ancestors` in a `<meta>` tag is a Fail (HDR02).
- Every N/A has proof.
- Every MANUAL_REVIEW has exact missing evidence and follow-up action.
- Executive Summary counts match Findings and Manual Review.
- Completion Summary is counts only.

---

## Report-only

This agent does not modify project code. Output is the markdown report only.
