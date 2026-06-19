---
name: cors_reviewer
version: 2.0
description: >-
  STRICT Spring Boot CORS auditor v2.0. Origin allow-lists, wildcard prohibition,
  origin reflection, dev/tunnel origins in any profile, pattern allow-lists,
  credentials+header rules, and SecurityFilterChain wiring. Report-only.
---

# CORS Configuration Reviewer v2.0 STRICT

## Step 1 - Load References

Read completely before scanning:

1. `.cursor/skills/cors_reviewer/SKILL.md` (§3 allow-lists, §6 CORS08 procedure, §8 resolution catalog)
2. `.cursor/skills/cors_reviewer/POLICY.md`

| Artifact | Path / value |
|---|---|
| Cursor invoke name | `cors_reviewer` |
| Report path | `AI/cors_reviewer/cors_reviewer_report.md` |
| Report reviewer line | `cors_reviewer v2.0 STRICT` |

**STRICT mode:** Fixed severity per CHECK-ID. Every finding gets five Resolution rows. Only Evidence may quote project source.

---

## Step 2 - Determine Project Name

Prefer `spring.application.name`, else root directory name. Document source in Scope Notes.

---

## Step 2.5 - Technology Stack Gate

Run `SKILL.md` §1. **Fail** → out-of-scope report only (§1.1 wording). No CHECK-IDs scored.

---

## Step 3 - Mandatory Pre-Scan Checklist

Skip if stack gate failed.

### Discovery

- [ ] All `SecurityFilterChain` and CORS beans
- [ ] `@CrossOrigin` annotations
- [ ] Custom CORS filters
- [ ] All profile variants of `application*.properties` / `application*.yml`

Record **CORS10 allow-list** in Scope Notes (default: empty) before scoring CORS10.

### CHECK-IDs

- [ ] CORS01 - No wildcard with credentials
- [ ] CORS02 - No arbitrary origin reflection
- [ ] CORS03 - Explicit CORS justification
- [ ] CORS04 - Safe subdomain patterns
- [ ] CORS05 - No null origin
- [ ] CORS06 - CORS is not authorization
- [ ] CORS07 - Explicit methods and headers
- [ ] CORS08 - No dev/tunnel CORS origins (all profiles; SKILL §6)
- [ ] CORS09 - No wildcard origin
- [ ] CORS10 - CORS pattern not allow-listed
- [ ] CORS11 - Explicit allowed methods
- [ ] CORS12 - CORS bean wired
- [ ] CORS13 - No credentials with wildcard headers

Verdicts: **PASS**, **FAIL**, **MANUAL_REVIEW**, **N/A** only.

---

## Step 4 - Write Report

**Path:** `AI/cors_reviewer/cors_reviewer_report.md`

In-scope report must include Scope Notes (profiles reviewed, CORS10 allow-list, N/A proof), Executive Summary, Findings with Possible Attack Scenario + five Resolution rows, Passed Checks, Completion Summary.

---

## Step 5 - Final Validation

- CORS08 evidence quotes a CORS origin line, not merely "localhost exists in repo".
- CORS10 scored only after allow-list documented.
- Every FAIL has Verify with action + pass signal.
- Executive Summary counts match Findings.

---

## Report-only

This agent does not modify project code.
