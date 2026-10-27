# Clickjacking & Headers Security Policy v2.1 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. Spring Security implicit defaults alone do **not** pass when headers are customized. JS-only frame busting is always a finding.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/clickjacking_headers_reviewer.md` |
| Cursor invoke name | `clickjacking_headers_reviewer` |
| Report path | `AI/agents/security_reviewers/clickjacking_headers_reviewer/clickjacking_headers_reviewer_report.md` |
| Report reviewer line | `clickjacking_headers_reviewer v2.1 STRICT` |
| Fleet position line | `#12 — Phase 4 (Browser & transport)` |

---

## Verdict Vocabulary

**PASS**, **FAIL**, **MANUAL_REVIEW**, **N/A** only.

---

## Resolution Requirement

Five Resolution rows per finding. Only Evidence may quote source.

Every scored finding and Manual Review CHECK-ID explanation must include `#### Picture in your head` — concrete mental model / analogy / before-after (prefer **In even simpler terms...** or **Here's a practical example:**).

---

## Related reviewers

**HDR06** (Cache-Control on authenticated HTML) is scored only here. For error responses, static leaks, and log redaction, invoke **`disclosure_reviewer` v2.0** (DISC01–DISC04).

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| HDR01 | HTTP CSP frame-ancestors | No enforcing HTTP `Content-Security-Policy` with `frame-ancestors` and no equivalent `frameOptions().deny()` / `.sameOrigin()` in reviewed chain |
| HDR03 | CSP Report-Only is not enforcement | `frame-ancestors` only in `Content-Security-Policy-Report-Only` |

### High

| ID | Citation | Condition |
|---|---|---|
| HDR02 | No meta tag frame-ancestors | `frame-ancestors` attempted via HTML `<meta>` instead of HTTP header |
| HDR04 | No JS-only frame busting | JS `window.top` checks are primary defense without HTTP frame controls |
| HDR05 | Standard security headers | `headers().disable()` or unguarded `defaultsDisabled()` without re-enabling protections |
| HDR06 | Safe Cache-Control for auth pages | Authenticated HTML lacks `Cache-Control: no-store` policy |
| HDR07 | HSTS configured | No `httpStrictTransportSecurity()` with `maxAge >= 31536000`, or HSTS disabled / `maxAge=0` |
| HDR08 | CSP configured | No `contentSecurityPolicy()` in reviewed security headers |
| HDR09 | No unguarded defaultsDisabled | `headers().defaultsDisabled()` without re-enabling frame, nosniff, HSTS, CSP |

### Medium

| ID | Citation | Condition |
|---|---|---|
| HDR10 | Explicit nosniff | No `contentTypeOptions()` / `noSniff()` when headers are customized |
| HDR11 | CSP no unsafe script-src | `unsafe-inline` or `unsafe-eval` in `script-src` |
| HDR12 | CSP no wildcard script-src | `*` in `script-src` |
| HDR15 | CSP no unsafe style-src | `unsafe-inline` or `unsafe-eval` in `style-src` (ZAP 10055 / style injection weakening) |
| HDR16 | No inline style attributes | `style=` on Thymeleaf HTML templates or JS-built HTML strings when UI chain emits enforcing CSP |

### Low

| ID | Citation | Condition |
|---|---|---|
| HDR13 | Referrer-Policy set | No `referrerPolicy()` configured |

### Info (not scored)

| ID | Citation | Condition |
|---|---|---|
| HDR14 | X-XSS-Protection disabled | Explicitly set to `0` only |

---

## N/A Criteria

| ID | N/A when |
|---|---|
| HDR01–HDR04, HDR06, HDR15–HDR16 | Pure JSON/XML API with no HTML responses |
| HDR05–HDR13 | Headers provably injected at edge — **MANUAL_REVIEW** if not in repo |

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| HDR01 | Clickjacking | Critical | HTTP CSP frame-ancestors |
| HDR02 | Clickjacking | High | No meta tag frame-ancestors |
| HDR03 | Clickjacking | Critical | CSP Report-Only is not enforcement |
| HDR04 | Clickjacking | High | No JS-only frame busting |
| HDR05 | Security Headers | High | Standard security headers |
| HDR06 | Security Headers | High | Safe Cache-Control for auth pages |
| HDR07 | Security Headers | High | HSTS configured |
| HDR08 | Security Headers | High | CSP configured |
| HDR09 | Security Headers | High | No unguarded defaultsDisabled |
| HDR10 | Security Headers | Medium | Explicit nosniff |
| HDR11 | Security Headers | Medium | CSP no unsafe script-src |
| HDR12 | Security Headers | Medium | CSP no wildcard script-src |
| HDR13 | Security Headers | Low | Referrer-Policy set |
| HDR14 | Security Headers | Info | X-XSS-Protection disabled |
| HDR15 | Security Headers | Medium | CSP no unsafe style-src |
| HDR16 | Security Headers | Medium | No inline style attributes |
