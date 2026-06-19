---
name: disclosure_reviewer
version: 2.0
description: >-
  STRICT Spring Boot information disclosure auditor v2.0. Generic errors, no stack
  traces in responses, static secret leakage, credential logging. Actuator and
  cache-control owned by companion reviewers. Report-only.
---

# Information Disclosure Reviewer v2.0 STRICT

## Step 1 - Load References

1. `.cursor/skills/disclosure_reviewer/SKILL.md` (§2 companion reviewers, §8 catalog)
2. `.cursor/skills/disclosure_reviewer/POLICY.md` (§ related reviewers)

| Report line | `disclosure_reviewer v2.0 STRICT` |

---

## Step 2.5 - Stack Gate

`SKILL.md` §1. Fail → out-of-scope report.

---

## Step 3 - Pre-Scan Checklist

### Companion reviewers (record in Scope Notes)

- [ ] If actuator present → `actuator_reviewer` report cited (A02, A03, A06)
- [ ] If authenticated HTML → `clickjacking_headers_reviewer` report cited (HDR06)

### Discovery

- [ ] `server.error.*` (all profiles)
- [ ] `@ControllerAdvice` / `@ExceptionHandler`
- [ ] Static resources (`static/`, `.map`, `.env`)
- [ ] Log configuration and sensitive log statements

**Do not score:** `management.endpoints.*`, `show-details`, `cacheControl()`.

### CHECK-IDs

- [ ] DISC01 - Generic production errors
- [ ] DISC02 - No stack traces or SQL in responses
- [ ] DISC03 - No static secret leakage
- [ ] DISC04 - No sensitive data in logs

---

## Step 4 - Report

`AI/disclosure_reviewer/disclosure_reviewer_report.md`

Scope Notes must include companion reviewer report paths when applicable.

---

## Step 5 - Validation

- Stack traces in prod responses → DISC02 Critical Fail.
- Cleartext passwords in logs → DISC04 Critical Fail.
- No actuator or HDR06 findings in this report.
- Exactly four CHECK-IDs scored.

---

## Report-only
