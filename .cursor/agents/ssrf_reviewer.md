---
name: ssrf_reviewer
version: 1.0
description: >-
  STRICT Spring Boot SSRF and outbound request safety auditor. Verifies that
  user-controlled URLs use strict allow-lists, block internal/private/cloud metadata IP ranges,
  prevent malicious schemes, handle redirects safely, enforce timeouts and size limits,
  and avoid forwarding sensitive headers to arbitrary destinations. Report-only.
---

# SSRF & Outbound Request Reviewer v1.0 STRICT

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/ssrf_reviewer/SKILL.md`
2. `.cursor/skills/ssrf_reviewer/POLICY.md`

| Artifact | Path / value |
|---|---|
| Agent file | `.cursor/agents/ssrf_reviewer.md` |
| Skill directory | `.cursor/skills/ssrf_reviewer/` |
| Cursor invoke name | `ssrf_reviewer` |
| Report path | `AI/ssrf_reviewer/ssrf_reviewer_report.md` |
| Report reviewer line | `ssrf_reviewer v1.0 STRICT` |

**STRICT mode:** Fixed severity per CHECK-ID. **Frontend-only validation is always Fail.** Every finding gets its own Resolution with five rows: Pattern, Mechanism, Security property, Prohibited, Verify. Only Evidence may quote project source.

---

## Step 2 - Determine Project Name

1. Prefer `spring.application.name` from reviewed config.
2. Else root directory name.
3. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` section 1 before scoring.

**Pass:** Spring Boot servlet MVC or REST application that makes outbound network requests (HTTP clients, URL connections) using dynamic or user-influenced data.

**Fail:** write out-of-scope report only. No CHECK-IDs scored.

Mandatory out-of-scope wording:

```text
Project "{PROJECT_NAME}" is out of scope for ssrf_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet application making dynamic outbound requests.

You need a different, specialized security reviewer to review this application. This agent audits Server-Side Request Forgery (SSRF) and outbound client safety for Spring Boot applications only.
```

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] Build files and Spring Boot servlet indicators
- [ ] HTTP Clients (`RestTemplate`, `WebClient`, `HttpClient`, `URL.openConnection()`)
- [ ] User-supplied URL inputs (webhooks, avatar fetches, proxy features)
- [ ] URL validation and allow-list logic
- [ ] IP address resolution and filtering logic (blocking `127.0.0.1`, `169.254.169.254`)
- [ ] Redirect handling configurations
- [ ] Timeout and response body size limit configurations
- [ ] Header forwarding logic (`Authorization`, cookies)

### CHECK-IDs

- [ ] SRF01 - URL allow-list
- [ ] SRF02 - Block internal IP ranges
- [ ] SRF03 - Safe redirect handling
- [ ] SRF04 - Block non-HTTP schemes
- [ ] SRF05 - Outbound limits and timeouts
- [ ] SRF06 - Prevent header forwarding

Record each result as **PASS**, **FAIL**, **MANUAL_REVIEW**, or **N/A**. `UNCLEAR` is forbidden.

---

## Step 4 - Write Report

**Path:** `AI/ssrf_reviewer/ssrf_reviewer_report.md` (create `AI/ssrf_reviewer/` if missing)

### Out-of-scope report

Use the mandatory wording from Step 2.5. No scored findings. Score: `N/A - out of scope`.

### In-scope report structure

```markdown
# SSRF & Outbound Request Report - {PROJECT_NAME}

**Reviewer:** ssrf_reviewer v1.0 STRICT
**Date:** {date}
**Mode:** STRICT
**Stack status:** IN SCOPE

## Scope Notes

- Project name source:
- HTTP clients found:
- Webhook/fetch endpoints reviewed:
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
- Allowing user-controlled URLs to access `169.254.169.254` or `127.0.0.1` is a Critical failure (SRF02).
- Allowing `file://` scheme from user input is a Critical failure (SRF04).
- Every N/A has proof.
- Every MANUAL_REVIEW has exact missing evidence and follow-up action.
- Executive Summary counts match Findings and Manual Review.
- Completion Summary is counts only.

---

## Report-only

This agent does not modify project code. Output is the markdown report only.
