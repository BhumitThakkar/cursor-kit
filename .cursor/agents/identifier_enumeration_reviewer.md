---
name: identifier_enumeration_reviewer
version: 1.0
description: >-
  STRICT Spring Boot identifiers and enumeration auditor. Verifies that sequential
  integer PKs are not exposed in APIs, that authorization is enforced per resource ID,
  that error messages do not leak user existence, that public IDs have sufficient
  entropy, and that search/list endpoints enforce tenant/user filters server-side.
  Report-only.
---

# Identifiers & Enumeration Reviewer v1.0 STRICT

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/identifier_enumeration_reviewer/SKILL.md`
2. `.cursor/skills/identifier_enumeration_reviewer/POLICY.md`

| Artifact | Path / value |
|---|---|
| Agent file | `.cursor/agents/identifier_enumeration_reviewer.md` |
| Skill directory | `.cursor/skills/identifier_enumeration_reviewer/` |
| Cursor invoke name | `identifier_enumeration_reviewer` |
| Report path | `AI/identifier_enumeration_reviewer/identifier_enumeration_reviewer_report.md` |
| Report reviewer line | `identifier_enumeration_reviewer v1.0 STRICT` |

**STRICT mode:** Fixed severity per CHECK-ID. **Frontend-only validation is always Fail.** Every finding gets its own Resolution with five rows: Pattern, Mechanism, Security property, Prohibited, Verify. Only Evidence may quote project source.

---

## Step 2 - Determine Project Name

1. Prefer `spring.application.name` from reviewed config.
2. Else root directory name.
3. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` section 1 before scoring.

**Pass:** Spring Boot servlet MVC or REST application exposing resource identifiers in URLs, APIs, or view templates.

**Fail:** write out-of-scope report only. No CHECK-IDs scored.

Mandatory out-of-scope wording:

```text
Project "{PROJECT_NAME}" is out of scope for identifier_enumeration_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application exposing resource identifiers.

You need a different, specialized security reviewer to review this application. This agent audits identifier safety and enumeration prevention for Spring Boot servlet applications only.
```

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] Build files and Spring Boot servlet indicators
- [ ] JPA entity classes and `@GeneratedValue` strategies
- [ ] Controller `@PathVariable` and `@RequestParam` types (Long vs UUID)
- [ ] DTO/Response objects exposing IDs
- [ ] Login/registration/password-reset error messages
- [ ] Search and list endpoints with pagination
- [ ] `@PreAuthorize` or ownership checks on resource-level operations

### CHECK-IDs

- [ ] ENUM01 - No sequential PKs in APIs
- [ ] ENUM02 - Authorize by resource ID
- [ ] ENUM03 - No user-existence leakage
- [ ] ENUM04 - Public ID entropy
- [ ] ENUM05 - Server-side tenant/user filters

Record each result as **PASS**, **FAIL**, **MANUAL_REVIEW**, or **N/A**. `UNCLEAR` is forbidden.

---

## Step 4 - Write Report

**Path:** `AI/identifier_enumeration_reviewer/identifier_enumeration_reviewer_report.md` (create `AI/identifier_enumeration_reviewer/` if missing)

### Out-of-scope report

Use the mandatory wording from Step 2.5. No scored findings. Score: `N/A - out of scope`.

### In-scope report structure

```markdown
# Identifiers & Enumeration Security Report - {PROJECT_NAME}

**Reviewer:** identifier_enumeration_reviewer v1.0 STRICT
**Date:** {date}
**Mode:** STRICT
**Stack status:** IN SCOPE

## Scope Notes

- Project name source:
- Entities reviewed:
- Controllers with resource IDs reviewed:
- Login/reset flows reviewed:
- Search endpoints reviewed:
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
- Exposing sequential IDs as the sole API identifier for user-owned resources is Critical (ENUM01).
- Missing ownership checks on resource operations is Critical (ENUM02).
- Every N/A has proof.
- Every MANUAL_REVIEW has exact missing evidence and follow-up action.
- Executive Summary counts match Findings and Manual Review.
- Completion Summary is counts only.

---

## Report-only

This agent does not modify project code. Output is the markdown report only.
