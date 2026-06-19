# CORS Configuration Security Policy v2.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Dev, local, and test profiles use the same bar as production for origin allow-lists.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/cors_reviewer.md` |
| Cursor invoke name | `cors_reviewer` |
| Report path | `AI/cors_reviewer/cors_reviewer_report.md` |
| Report reviewer line | `cors_reviewer v2.0 STRICT` |

---

## Verdict Vocabulary

Allowed values only: **PASS**, **FAIL**, **MANUAL_REVIEW**, **N/A**

`UNCLEAR` is forbidden. If evidence is insufficient, use MANUAL_REVIEW and state the exact missing evidence.

---

## Resolution Requirement

Every finding must include a Resolution with five rows: Pattern, Mechanism, Security property, Prohibited, Verify.

Only Evidence may quote project source. Resolution rows must be prose, not pasteable code. See **SKILL.md §7** and **§8**.

---

## Organization allow-lists

Default: **empty** — fail until the auditor documents approved entries in Scope Notes before scoring CORS10 or SUP-related script checks elsewhere.

Record in Scope Notes before scoring CORS10:

```text
CORS10 allow-list: (comma-separated patterns or explicit origins)
```

| Config | Result |
|---|---|
| Explicit full origin, no `*` in value (e.g. `https://app.example.com`) | **PASS** |
| Relative / same-origin API calls (no CORS config needed) | **PASS** — not a CORS finding |
| `allowedOriginPatterns` containing `*` (subdomain wildcard) | **FAIL** unless pattern exactly matches an entry in CORS10 allow-list |
| Empty allow-list + any wildcard subdomain pattern | **FAIL** |

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| CORS01 | No wildcard with credentials | `allowCredentials(true)` paired with wildcard origin (`*`, `allowedOriginPatterns("*")`, or `addAllowedOrigin("*")`) |
| CORS02 | No arbitrary origin reflection | `Origin` header reflected into `Access-Control-Allow-Origin` without strict allow-list validation |
| CORS09 | No wildcard origin | Any wildcard origin in reviewed CORS configuration, even when credentials are disabled |
| CORS08 | No dev or tunnel CORS origins | Dev/tunnel hostnames in **CORS origin configuration** in any reviewed file or profile (not JDBC, Redis, comments; no dev/local exemption) |

### High

| ID | Citation | Condition |
|---|---|---|
| CORS04 | Safe subdomain patterns | `allowedOriginPatterns` uses overly broad wildcards (e.g. `https://*.com`) instead of bounded organizational suffixes |
| CORS05 | No null origin | `"null"` in allow-list or dynamic reflection of `null` without documented desktop/file-origin use case |
| CORS06 | CORS is not authorization | Sensitive endpoints rely on CORS alone without server-side authentication |
| CORS07 | Explicit methods and headers | Wildcard `*` for `allowedMethods` or `allowedHeaders` on sensitive or credentialed APIs |
| CORS10 | CORS pattern not allow-listed | Wildcard subdomain pattern not listed in CORS10 allow-list |
| CORS13 | No credentials with wildcard headers | `allowCredentials(true)` combined with `allowedHeaders("*")` |

### Medium

| ID | Citation | Condition |
|---|---|---|
| CORS03 | Explicit CORS justification | Global CORS mappings lack documentation of which external clients require cross-origin access |
| CORS12 | CORS bean wired | CORS bean exists but is not applied via `http.cors()` in `SecurityFilterChain` |

### Low

| ID | Citation | Condition |
|---|---|---|
| CORS11 | Explicit allowed methods | CORS bean exists but `addAllowedMethod()` was never called (OPTIONS must be included when CORS is active) |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| CORS01 | Origins are enumerated; `*` never used when `allowCredentials` is true. |
| CORS02 | Custom filters reflect `Origin` only after exact allow-list match. |
| CORS03 | Consuming frontends are documented, or CORS is disabled for same-origin-only apps. |
| CORS04 | `allowedOriginPatterns` is absent or bounded to trusted suffixes (e.g. `https://*.company.com`). |
| CORS05 | `"null"` is never in `allowedOrigins`. |
| CORS06 | Endpoints require Spring Security authentication regardless of CORS. |
| CORS07 | Methods and headers are explicitly listed. |
| CORS08 | No dev/tunnel hostname appears on any CORS origin line in any reviewed profile. |
| CORS09 | No wildcard origin in any reviewed configuration. |
| CORS10 | Each wildcard pattern in config appears in Scope Notes CORS10 allow-list with rationale. |
| CORS11 | CORS bean lists named HTTP methods including OPTIONS when CORS is active. |
| CORS12 | `http.cors(cors -> cors.configurationSource(...))` is present in `SecurityFilterChain`. |
| CORS13 | Credentials are not paired with wildcard request headers. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| CORS01–CORS13 | No `CorsConfiguration`, no `@CrossOrigin`, no custom CORS filter, and application relies on same-origin policy only. Document in Scope Notes. |

---

## Manual Review Criteria

Use MANUAL_REVIEW when origins are loaded from a database or remote config at runtime, or CORS is managed entirely by an API gateway/WAF not present in the repo.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| CORS01 | CORS | Critical | No wildcard with credentials |
| CORS02 | CORS | Critical | No arbitrary origin reflection |
| CORS03 | CORS | Medium | Explicit CORS justification |
| CORS04 | CORS | High | Safe subdomain patterns |
| CORS05 | CORS | High | No null origin |
| CORS06 | CORS | High | CORS is not authorization |
| CORS07 | CORS | High | Explicit methods and headers |
| CORS08 | CORS | Critical | No dev or tunnel CORS origins |
| CORS09 | CORS | Critical | No wildcard origin |
| CORS10 | CORS | High | CORS pattern not allow-listed |
| CORS11 | CORS | Low | Explicit allowed methods |
| CORS12 | CORS | Medium | CORS bean wired |
| CORS13 | CORS | High | No credentials with wildcard headers |
