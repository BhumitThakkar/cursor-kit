# CSRF Security Policy v2.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Frontend-only validation is always a finding.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/csrf_reviewer.md` |
| Cursor invoke name | `csrf_reviewer` |
| Report path | `AI/csrf_reviewer/csrf_reviewer_report.md` |
| Report reviewer line | `csrf_reviewer v2.0 STRICT` |

---

## Verdict Vocabulary

**PASS**, **FAIL**, **MANUAL_REVIEW**, **N/A** only. `UNCLEAR` is forbidden.

---

## Resolution Requirement

Every finding: five Resolution rows (Pattern, Mechanism, Security property, Prohibited, Verify). Only Evidence may quote source.

---

## Auth models (CSRF00 — prerequisite, not scored)

Document in Scope Notes before CSRF01 family checks:

| Model | Definition |
|---|---|
| SESSION-COOKIE | `formLogin`, session cookies, session not STATELESS |
| STATELESS-API | HTTP Basic and/or Bearer only; no session cookies; no form login |
| BOTH | Session UI **and** stateless API |
| UNKNOWN | Cannot determine |

**Scan order:** CSRF00 → CSRF03/09/10/11 → CSRF07 → CSRF04–06, CSRF12–15.

---

## Data-flow trace (CSRF07)

Procedure: **SKILL.md §2.3**. Fail only when trace confidence is **HIGH**. LOW confidence → Scope Notes + manual follow-up, not scored Fail.

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| CSRF01 | State-changing requests protected | State-changing browser requests lack CSRF protection when CSRF00 is SESSION-COOKIE |
| CSRF03 | No global disable for session auth | Global `csrf().disable()` when CSRF00 is SESSION-COOKIE |
| CSRF05 | Critical mutations covered | Login, logout, password/email change, or admin mutations lack CSRF without documented stateless exception |
| CSRF07 | Session paths lack CSRF | State-changing session-auth path without CSRF token protection (HIGH trace confidence) |
| CSRF09 | CSRF disabled in hybrid app | Global `csrf().disable()` when CSRF00 is BOTH |

### High

| ID | Citation | Condition |
|---|---|---|
| CSRF02 | API exclusions documented | CSRF ignored on paths without STATELESS-API auth **and** inline code comment justification |
| CSRF04 | SameSite not sole control | Session mutations rely only on `SameSite` without synchronizer token |
| CSRF08 | Hybrid partial CSRF gap | CSRF00 BOTH, CSRF enabled globally, but API exclusions missing or undocumented |
| CSRF10 | CSRF disabled with unknown auth | Global `csrf().disable()` when CSRF00 is UNKNOWN |
| CSRF11 | CSRF meta tag missing | Session + AJAX, no `_csrf` meta in base layout |
| CSRF12 | CSRF missing in forms | POST form without `th:action` and without CSRF hidden field |
| CSRF13 | AJAX CSRF header missing | State-changing fetch/XHR without CSRF token header |

### Medium

| ID | Citation | Condition |
|---|---|---|
| CSRF14 | CSRF token repository mismatch | AJAX app uses `HttpSessionCsrfTokenRepository` without JS token read path |
| CSRF15 | CSRF cookie not JS-readable | `CookieCsrfTokenRepository` with `httpOnly(true)` on AJAX app |

---

## CSRF03 family pass rules

| CSRF00 model | Global `csrf().disable()` |
|---|---|
| SESSION-COOKIE | **CSRF03** FAIL |
| STATELESS-API | Pass |
| BOTH | **CSRF09** FAIL; Pass only if CSRF enabled + **CSRF02** for API paths |
| UNKNOWN | **CSRF10** FAIL |

---

## Scope N/A

| Condition | N/A checks |
|---|---|
| CSRF00 STATELESS-API only | CSRF11, CSRF12, CSRF13, CSRF07 |
| No Thymeleaf/AJAX | CSRF11, CSRF12 (if forms-only server path documented) |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| CSRF00 | Auth model documented in Scope Notes with cited evidence. |
| CSRF01 | CSRF active for session-backed mutations. |
| CSRF02 | Each `ignoringRequestMatchers` entry has stateless/token comment. |
| CSRF03 | CSRF enabled, or provably STATELESS-API with documentation. |
| CSRF04 | Synchronizer token plus any SameSite configuration. |
| CSRF05 | Critical endpoints require CSRF or documented stateless proof. |
| CSRF07 | §2.3.1 inventory complete; each session mutation protected or N/A. |
| CSRF08 | BOTH app has documented API exclusions per CSRF02. |
| CSRF09 | Hybrid app keeps CSRF enabled on UI chain. |
| CSRF10 | CSRF remains enabled until CSRF00 resolved. |
| CSRF11 | Base layout exposes CSRF meta tags when AJAX is used. |
| CSRF12 | POST forms use `th:action` or hidden CSRF field. |
| CSRF13 | Mutating AJAX sends CSRF header from meta or cookie. |
| CSRF14 | Repository matches client (cookie repo for AJAX). |
| CSRF15 | CSRF cookie readable by JS when AJAX reads cookie. |

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| CSRF00 | CSRF | — | Auth model documented |
| CSRF01 | CSRF | Critical | State-changing requests protected |
| CSRF02 | CSRF | High | API exclusions documented |
| CSRF03 | CSRF | Critical | No global disable for session auth |
| CSRF04 | CSRF | High | SameSite not sole control |
| CSRF05 | CSRF | Critical | Critical mutations covered |
| CSRF07 | CSRF | Critical | Session paths lack CSRF |
| CSRF08 | CSRF | High | Hybrid partial CSRF gap |
| CSRF09 | CSRF | Critical | CSRF disabled in hybrid app |
| CSRF10 | CSRF | High | CSRF disabled with unknown auth |
| CSRF11 | CSRF | High | CSRF meta tag missing |
| CSRF12 | CSRF | High | CSRF missing in forms |
| CSRF13 | CSRF | High | AJAX CSRF header missing |
| CSRF14 | CSRF | Medium | CSRF token repository mismatch |
| CSRF15 | CSRF | Medium | CSRF cookie not JS-readable |
