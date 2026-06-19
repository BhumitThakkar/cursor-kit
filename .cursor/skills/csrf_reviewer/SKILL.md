---
name: csrf_reviewer
version: 2.0
disable-model-invocation: true
---

# CSRF Security Reviewer - Scan Skill v2.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Cursor invoke name | `csrf_reviewer` |
| Report path | `AI/csrf_reviewer/csrf_reviewer_report.md` |
| Report reviewer line | `csrf_reviewer v2.0 STRICT` |

---

## 1. Supported Technology Stack

Spring Boot servlet MVC or REST with session cookies, Thymeleaf forms, and/or same-origin AJAX.

| Required signal | Evidence |
|---|---|
| Spring Boot servlet | `spring-boot-starter-web`, `SecurityFilterChain` |
| CSRF surface | Spring Security, forms, `fetch`/XHR, session cookies |

### 1.1 Out of Scope

Not Spring Boot servlet MVC/REST, or purely public app with no auth and no mutations.

```text
Project "{PROJECT_NAME}" is out of scope for csrf_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application with session-cookie authentication or state-changing browser requests.

You need a different, specialized security reviewer to review this application. This agent audits CSRF prevention for Spring Boot servlet applications only.
```

---

## 2. File Discovery

### Security

- `SecurityFilterChain`, `csrf().disable()`, `ignoringRequestMatchers()`
- `CookieCsrfTokenRepository`, `HttpSessionCsrfTokenRepository`
- `formLogin()`, `httpBasic()`, Bearer filters, `SessionCreationPolicy`

### Mutations

- `@PostMapping`, `@PutMapping`, `@PatchMapping`, `@DeleteMapping`
- `<form method="post">` in templates
- `fetch(`, `XMLHttpRequest`, `$.ajax` in JS

### Layout

- Base Thymeleaf layout: `<meta name="_csrf"`, `<meta name="_csrf_header"`

---

## 3. Scope N/A

| Condition | Skip | Report as |
|---|---|---|
| CSRF00 STATELESS-API only | CSRF11, CSRF12, CSRF13, CSRF07 | N/A — stateless API |

---

## 4. Data-flow trace — CSRF07 (§2.3)

**Trace confidence**

| Level | When |
|---|---|
| HIGH | Procedure complete; chain documented |
| LOW | Inventory incomplete or link unproven |

**LOW rules:** Do not Fail CSRF07. Log `Trace confidence · CSRF07: LOW — {gap}` in Scope Notes.

### 2.3.1 CSRF07 — Session endpoint CSRF inventory

1. Grep mutating mappings and POST forms.
2. Exclude STATELESS-API paths (CSRF00 evidence).
3. Exclude paths with documented CSRF02 exclusion.
4. Build **session mutation inventory** in Scope Notes: path, method, file.
5. For each row: confirm CSRF applies or mark unprotected.
6. **Fail CSRF07 (HIGH only):** listed session-auth mutation lacks CSRF.
7. **LOW:** incomplete inventory — list unchecked items under Recommended Hardening.

---

## 5. CHECK-ID Scoring Procedure

**Order:** CSRF00 → CSRF03/09/10/11 → CSRF07 → remainder.

### CSRF00 — Authentication Model

Classify SESSION-COOKIE | STATELESS-API | BOTH | UNKNOWN in Scope Notes. Not scored.

### CSRF03 — Global Disable (Session)

Fail when global disable and CSRF00 is SESSION-COOKIE.

### CSRF09 — Global Disable (Hybrid)

Fail when global disable and CSRF00 is BOTH.

### CSRF10 — Global Disable (Unknown)

Fail when global disable and CSRF00 is UNKNOWN.

### CSRF07 — Session Paths Lack CSRF

Procedure §2.3.1. Fail only at HIGH confidence.

### CSRF08 — Hybrid Partial Gap

Fail when CSRF00 BOTH, CSRF on, but API paths lack CSRF02-documented exclusions.

### CSRF11 — CSRF Meta Tag

Fail when session + AJAX but base layout lacks CSRF meta tags.

### CSRF12 — CSRF in Forms

Fail when POST form lacks `th:action` and hidden CSRF field.

### CSRF13 — AJAX CSRF Header

Fail when mutating AJAX omits CSRF header.

### CSRF02 — API Exclusions Documented

Fail when exclusion on state-changing path lacks STATELESS-API auth **and** code comment.

### CSRF14 — Token Repository Mismatch

Fail when AJAX app uses session repository without server-only forms.

### CSRF15 — CSRF Cookie Not JS-Readable

Fail when AJAX reads cookie but CSRF cookie is HttpOnly without meta alternative.

### CSRF01, CSRF04, CSRF05

As v1.0 — session mutations protected; SameSite not sole control; critical endpoints covered.

---

## 6. Report Requirements

Possible Attack Scenario: 1–2 sentences, plain English, no code fences.

Resolution: five rows; Verify = action + pass signal.

---

## 7. Secure Resolution Catalog

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| CSRF00 | Auth model documented | Classify model in Scope Notes with cited config | CSRF03 family judged correctly | Scoring before CSRF00 | Scope Notes states model with evidence |
| CSRF01 | Synchronizer token | Spring CSRF enabled; token on mutations | Forged cross-site POSTs fail | Disabled CSRF on session mutations | Tokenless POST returns 403 |
| CSRF02 | Documented exclusions | Comment above each `ignoringRequestMatchers` | Exceptions are intentional | Undocumented exclusions | Each exclusion has stateless API comment |
| CSRF03 | CSRF enabled for sessions | Remove global disable on session apps | Session mutations require token | Global disable on SESSION-COOKIE | Tokenless POST returns 403 |
| CSRF04 | Token plus SameSite | `CookieCsrfTokenRepository` with SameSite | Defense in depth | SameSite-only CSRF | Token repository configured |
| CSRF05 | Critical mutation coverage | CSRF on login/logout/credential change | Login CSRF blocked | Open critical mutations | Logout POST without token fails |
| CSRF07 | All mutations protected | CSRF on every inventoried session mutation | No open session POST/PUT/DELETE | Unprotected inventory rows | §2.3.1 complete; tokenless mutating request returns 403 |
| CSRF08 | Documented API exclusions | `ignoringRequestMatchers` only on stateless API paths | UI not excluded | Broad undocumented exclusions | Each exclusion targets documented API path |
| CSRF09 | CSRF on hybrid UI | CSRF on UI chain; stateless API excluded per CSRF02 | UI protected | Global disable on BOTH | UI POST without token returns 403 |
| CSRF10 | CSRF until auth known | Keep CSRF enabled while UNKNOWN | No disable while unknown | Disable when UNKNOWN | CSRF filter enabled; resolution plan in Scope Notes |
| CSRF11 | CSRF meta propagation | CSRF attributes in base layout meta | AJAX can read token | Missing meta on AJAX layout | Page source shows CSRF meta tags |
| CSRF12 | Form token or th:action | `th:action` or hidden CSRF parameter | POST forms protected | Bare `action=` without token | Form POST without token fails |
| CSRF13 | AJAX header injection | Attach CSRF header on mutating fetch/XHR | Mutating AJAX sends token | POST fetch without header | Network tab shows CSRF header |
| CSRF14 | Repository matches client | `CookieCsrfTokenRepository` for AJAX | Token reachable by client | Session repo on AJAX-only | Token readable from meta or cookie |
| CSRF15 | JS-readable CSRF cookie | `withHttpOnlyFalse()` when JS reads cookie | Client can send header | HttpOnly CSRF cookie on AJAX | Mutating AJAX with token succeeds |

---

## 8. Scoring Formula

Base 100 · Critical −20 · High −10 · Medium −5 · Low −2 · Floor 0

---

## 9. Final Self-Validation

- CSRF00 before CSRF03 family.
- CSRF07 Fail only at HIGH trace confidence.
- Hybrid/global-disable findings cite correct CSRF00 model.
