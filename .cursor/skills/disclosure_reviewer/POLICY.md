# Information Disclosure Security Policy v2.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. A safe dev profile does not excuse an unsafe prod profile.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/disclosure_reviewer.md` |
| Cursor invoke name | `disclosure_reviewer` |
| Report path | `AI/disclosure_reviewer/disclosure_reviewer_report.md` |
| Report reviewer line | `disclosure_reviewer v2.0 STRICT` |

---

## Verdict Vocabulary

**PASS**, **FAIL**, **MANUAL_REVIEW**, **N/A** only. `UNCLEAR` is forbidden.

---

## Resolution Requirement

Every finding: five Resolution rows (Pattern, Mechanism, Security property, Prohibited, Verify). Only Evidence may quote source.

---

## Related reviewers (not scored here)

This agent covers **error responses, static artifact leakage, and credential logging** only. Other disclosure surfaces have dedicated owners:

| Topic | Invoke | CHECK-IDs | When required |
|-------|--------|-----------|---------------|
| Actuator web exposure, `show-details` | `actuator_reviewer` | A02, A03, A06 | `spring-boot-starter-actuator` on classpath |
| Cache-Control on authenticated HTML | `clickjacking_headers_reviewer` | HDR06 | App serves authenticated HTML pages |

Record companion report paths in Scope Notes. Do **not** duplicate those checks in this audit.

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| DISC02 | No stack traces or SQL in responses | `server.error.include-stacktrace` enabled in production, or handlers reflect stack traces, SQL, or internal paths to the client |
| DISC04 | No sensitive data in logs | Passwords, tokens, full PANs, or other secrets logged in cleartext |

### High

| ID | Citation | Condition |
|---|---|---|
| DISC01 | Generic production errors | Detailed framework or internal error messages returned to users instead of generic safe responses |
| DISC03 | No static secret leakage | Source maps, `.env`, API keys, debug logs, or sensitive hints in `robots.txt` / comments served or committed to deployable static paths |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| DISC01 | `@ControllerAdvice` or equivalent returns generic user-facing errors; details go to server logs only. |
| DISC02 | `server.error.include-stacktrace=never` in production profiles; no `printStackTrace()` or SQL in HTTP response bodies. |
| DISC03 | No `.map`, `.env`, plaintext logs, or API keys in `static/` / `public/` or git-tracked deploy artifacts. |
| DISC04 | Auth and sensitive flows omit or mask passwords and tokens in log statements. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| DISC01–DISC02 | Application handles no HTTP requests (e.g. message-driven worker only). |
| DISC03 | No static resource directory and no browser-served files. |
| DISC04 | Application performs no logging of request or auth data. |

---

## Manual Review Criteria

External log redaction (Splunk/ELK agents), CI-only source maps not in repo — **MANUAL_REVIEW** with exact missing evidence.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| DISC01 | Errors | High | Generic production errors |
| DISC02 | Errors | Critical | No stack traces or SQL in responses |
| DISC03 | Static | High | No static secret leakage |
| DISC04 | Logging | Critical | No sensitive data in logs |

**Retired IDs (v1.0):** old DISC03–DISC04 → `actuator_reviewer`; old DISC06 → `clickjacking_headers_reviewer` HDR06.
