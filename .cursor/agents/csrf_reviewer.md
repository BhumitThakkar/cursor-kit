---
name: csrf_reviewer
version: 2.0
description: >-
  STRICT Spring Boot CSRF auditor v2.0. Auth-model gating, session mutation
  inventory, hybrid app rules, Thymeleaf/AJAX token coverage, repository
  alignment, and documented API exclusions. Report-only.
---

# CSRF Reviewer v2.0 STRICT

## Step 1 - Load References

1. `.cursor/skills/csrf_reviewer/SKILL.md` (§2.3 CSRF07 trace, §7 catalog)
2. `.cursor/skills/csrf_reviewer/POLICY.md`

| Report reviewer line | `csrf_reviewer v2.0 STRICT` |
| Report path | `AI/csrf_reviewer/csrf_reviewer_report.md` |

---

## Step 2 - Determine Project Name

Prefer `spring.application.name`, else root directory.

---

## Step 2.5 - Stack Gate

`SKILL.md` §1. Fail → §1.1 out-of-scope report. No CHECK-IDs.

---

## Step 3 - Pre-Scan Checklist

### Discovery

- [ ] SecurityFilterChain and CSRF config
- [ ] Auth model evidence → **CSRF00** in Scope Notes
- [ ] Mutating endpoints and POST forms
- [ ] Thymeleaf base layout CSRF meta
- [ ] AJAX clients and token headers
- [ ] Token repository type

### CHECK-IDs (order matters)

- [ ] CSRF00 - Auth model (prerequisite)
- [ ] CSRF03 / CSRF09 / CSRF10 - Global disable (per model)
- [ ] CSRF07 - Session paths (§2.3.1 + trace confidence)
- [ ] CSRF08 - Hybrid partial gap
- [ ] CSRF01, CSRF02, CSRF04, CSRF05
- [ ] CSRF11 - Meta tag (N/A if STATELESS-API)
- [ ] CSRF12 - Forms (N/A if STATELESS-API)
- [ ] CSRF13 - AJAX header (N/A if STATELESS-API)
- [ ] CSRF14, CSRF15 - Repository alignment

Scope Notes must include: auth model, **session mutation inventory**, trace confidence for CSRF07.

---

## Step 4 - Write Report

`AI/csrf_reviewer/csrf_reviewer_report.md` — include Authentication Model from CSRF00 in header.

---

## Step 5 - Final Validation

- CSRF07 Fail only when trace confidence HIGH.
- Global disable mapped to correct CSRF03/09/10 per CSRF00.
- Every FAIL has five Resolution rows with Verify action + pass signal.

---

## Report-only
