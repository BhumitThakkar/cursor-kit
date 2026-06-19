---
name: open_redirect_reviewer
version: 1.0
description: >-
  STRICT Spring Boot open redirect auditor. Verifies redirect allow-lists, strict
  canonicalization of URLs to prevent bypasses, strict OAuth redirect_uri matching,
  prevention of CRLF injection, and forbids unvalidated dynamic redirects based on
  client input like 'next' or 'returnUrl'. Report-only.
---

# Open Redirect Reviewer v1.0 STRICT

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/open_redirect_reviewer/SKILL.md`
2. `.cursor/skills/open_redirect_reviewer/POLICY.md`

| Artifact | Path / value |
|---|---|
| Agent file | `.cursor/agents/open_redirect_reviewer.md` |
| Skill directory | `.cursor/skills/open_redirect_reviewer/` |
| Cursor invoke name | `open_redirect_reviewer` |
| Report path | `AI/open_redirect_reviewer/open_redirect_reviewer_report.md` |
| Report reviewer line | `open_redirect_reviewer v1.0 STRICT` |

**STRICT mode:** Fixed severity per CHECK-ID. **Frontend-only validation is always Fail.** Every finding gets its own Resolution with five rows: Pattern, Mechanism, Security property, Prohibited, Verify. Only Evidence may quote project source.

---

## Step 2 - Determine Project Name

1. Prefer `spring.application.name` from reviewed config.
2. Else root directory name.
3. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` section 1 before scoring.

**Pass:** Spring Boot servlet MVC or REST application issuing HTTP redirects, handling OAuth flows, or processing "next"/"returnUrl" parameters.

**Fail:** write out-of-scope report only. No CHECK-IDs scored.

Mandatory out-of-scope wording:

```text
Project "{PROJECT_NAME}" is out of scope for open_redirect_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application that issues HTTP redirects or OAuth flows.

You need a different, specialized security reviewer to review this application. This agent audits open redirect prevention for Spring Boot servlet applications only.
```

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] Build files and Spring Boot servlet indicators
- [ ] Endpoints returning `"redirect:"` or `RedirectView`
- [ ] `HttpServletResponse.sendRedirect()` calls
- [ ] Controller parameters named `next`, `returnUrl`, `redirect_uri`
- [ ] Spring Security `defaultSuccessUrl` or custom `AuthenticationSuccessHandler`
- [ ] OAuth2/OIDC configuration and client registrations
- [ ] Redirect validation utility methods/services
- [ ] Response header setting logic (`setHeader("Location", ...)`)

### CHECK-IDs

- [ ] RED01 - Redirect allow-list
- [ ] RED02 - No unvalidated redirect inputs
- [ ] RED03 - Strict URL canonicalization
- [ ] RED04 - Exact OAuth redirect_uri
- [ ] RED05 - No CRLF in redirects

Record each result as **PASS**, **FAIL**, **MANUAL_REVIEW**, or **N/A**. `UNCLEAR` is forbidden.

---

## Step 4 - Write Report

**Path:** `AI/open_redirect_reviewer/open_redirect_reviewer_report.md` (create `AI/open_redirect_reviewer/` if missing)

### Out-of-scope report

Use the mandatory wording from Step 2.5. No scored findings. Score: `N/A - out of scope`.

### In-scope report structure

```markdown
# Open Redirect Security Report - {PROJECT_NAME}

**Reviewer:** open_redirect_reviewer v1.0 STRICT
**Date:** {date}
**Mode:** STRICT
**Stack status:** IN SCOPE

## Scope Notes

- Project name source:
- Profiles reviewed:
- Redirect controllers found:
- Next/return parameters found:
- OAuth client config found:
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
- Using client `returnUrl` directly in `redirect:` is a Critical failure (RED02).
- Every N/A has proof.
- Every MANUAL_REVIEW has exact missing evidence and follow-up action.
- Executive Summary counts match Findings and Manual Review.
- Completion Summary is counts only.

---

## Report-only

This agent does not modify project code. Output is the markdown report only.
