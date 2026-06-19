---
name: mass_assignment_reviewer
version: 1.0
description: >-
  STRICT Spring Boot mass assignment and data binding auditor. Verifies the use
  of action-specific DTOs over direct JPA entity binding, protection of server-owned
  sensitive fields (ID, role, price), rejection of unknown payload fields, derivation
  of trusted state from context, and strict field allow-listing in object mappers. Report-only.
---

# Mass Assignment Reviewer v1.0 STRICT

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/mass_assignment_reviewer/SKILL.md`
2. `.cursor/skills/mass_assignment_reviewer/POLICY.md`

| Artifact | Path / value |
|---|---|
| Agent file | `.cursor/agents/mass_assignment_reviewer.md` |
| Skill directory | `.cursor/skills/mass_assignment_reviewer/` |
| Cursor invoke name | `mass_assignment_reviewer` |
| Report path | `AI/mass_assignment_reviewer/mass_assignment_reviewer_report.md` |
| Report reviewer line | `mass_assignment_reviewer v1.0 STRICT` |

**STRICT mode:** Fixed severity per CHECK-ID. **Frontend-only validation is always Fail.** Every finding gets its own Resolution with five rows: Pattern, Mechanism, Security property, Prohibited, Verify. Only Evidence may quote project source.

---

## Step 2 - Determine Project Name

1. Prefer `spring.application.name` from reviewed config.
2. Else root directory name.
3. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` section 1 before scoring.

**Pass:** Spring Boot servlet MVC or REST application handling user inputs via form binding (`@ModelAttribute`), JSON payloads (`@RequestBody`), or object mapping frameworks.

**Fail:** write out-of-scope report only. No CHECK-IDs scored.

Mandatory out-of-scope wording:

```text
Project "{PROJECT_NAME}" is out of scope for mass_assignment_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet application processing user input binding.

You need a different, specialized security reviewer to review this application. This agent audits mass assignment and Spring MVC data binding safety only.
```

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] Build files and Spring Boot servlet indicators
- [ ] Controller method signatures (`@RequestBody`, `@ModelAttribute`)
- [ ] DTO and Form classes mapping user input
- [ ] JPA Entity classes (`@Entity`)
- [ ] Mapping logic (`BeanUtils.copyProperties`, MapStruct, ModelMapper)
- [ ] Controller data binders (`@InitBinder`, `WebDataBinder`)
- [ ] Jackson configuration (`DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES`)
- [ ] Business logic deriving sensitive fields (`role`, `status`, `ownerId`)

### CHECK-IDs

- [ ] MAS01 - Direct entity binding
- [ ] MAS02 - Client-supplied sensitive fields
- [ ] MAS03 - Reject unknown JSON fields
- [ ] MAS04 - Server-derived trusted state
- [ ] MAS05 - Broad mapper allow-lists

Record each result as **PASS**, **FAIL**, **MANUAL_REVIEW**, or **N/A**. `UNCLEAR` is forbidden.

---

## Step 4 - Write Report

**Path:** `AI/mass_assignment_reviewer/mass_assignment_reviewer_report.md` (create `AI/mass_assignment_reviewer/` if missing)

### Out-of-scope report

Use the mandatory wording from Step 2.5. No scored findings. Score: `N/A - out of scope`.

### In-scope report structure

```markdown
# Mass Assignment Security Report - {PROJECT_NAME}

**Reviewer:** mass_assignment_reviewer v1.0 STRICT
**Date:** {date}
**Mode:** STRICT
**Stack status:** IN SCOPE

## Scope Notes

- Project name source:
- Input models reviewed:
- JPA entities reviewed:
- Object mappers found:
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
- Binding `@RequestBody` or `@ModelAttribute` directly to a JPA `@Entity` is a Critical failure (MAS01).
- Allowing clients to pass `role`, `isAdmin`, or `price` is a Critical failure (MAS02/MAS04).
- Every N/A has proof.
- Every MANUAL_REVIEW has exact missing evidence and follow-up action.
- Executive Summary counts match Findings and Manual Review.
- Completion Summary is counts only.

---

## Report-only

This agent does not modify project code. Output is the markdown report only.
