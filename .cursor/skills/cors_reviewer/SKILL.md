---
name: cors_reviewer
version: 2.0
disable-model-invocation: true
---

# CORS Configuration Security Reviewer - Scan Skill v2.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/cors_reviewer.md` |
| Skill directory | `.cursor/skills/cors_reviewer/` |
| Cursor invoke name | `cors_reviewer` |
| Report path | `AI/cors_reviewer/cors_reviewer_report.md` |
| Report reviewer line | `cors_reviewer v2.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications that define CORS rules.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |
| CORS surface | `CorsConfiguration`, `WebMvcConfigurer.addCorsMappings`, `@CrossOrigin`, custom CORS filters |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when the project is not Spring Boot servlet MVC or REST.

```text
Project "{PROJECT_NAME}" is out of scope for cors_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application.

You need a different, specialized security reviewer to review this application. This agent audits CORS configurations for Spring Boot servlet applications only.
```

---

## 2. File Discovery

Scan in this order.

### Global Configuration

- `WebMvcConfigurer` implementations overriding `addCorsMappings`
- `SecurityFilterChain` beans defining `http.cors()`
- `CorsConfigurationSource` or `UrlBasedCorsConfigurationSource` beans

### Controller Configuration

- `@CrossOrigin` on classes or methods

### Custom Filters

- Filters setting `Access-Control-Allow-Origin`

### Properties

- All `application*.properties` / `application*.yml` profile variants containing CORS origin keys

---

## 3. Allow-lists (before CORS10)

Default: **empty**. Document in Scope Notes:

```text
CORS10 allow-list: (empty = no wildcard subdomain patterns permitted)
```

Same-origin relative API calls and explicit full origins without `*` always pass CORS10.

---

## 4. Required Search Probes

| Goal | Probe |
|---|---|
| Global CORS | `rg -n "addCorsMappings\|CorsConfiguration\|http\.cors\(\)" src` |
| Local CORS | `rg -n "@CrossOrigin" src` |
| Reflection | `rg -n "Access-Control-Allow-Origin\|getHeader\(\"Origin\"\)" src` |
| Credentials | `rg -n "allowCredentials\|setAllowCredentials" src` |
| Wildcards | `rg -n "allowedOrigins\(\"\*\"\)\|allowedOriginPatterns\(\"\\*\"\)" src` |
| Patterns | `rg -n "allowedOriginPatterns" src` |
| Dev origins | `rg -n "localhost\|127\.0\.0\.1\|ngrok" src` |

---

## 5. Scope N/A Rules

| Check | N/A allowed only when |
|---|---|
| CORS01–CORS13 | Zero CORS configuration in the reviewed codebase and same-origin-only access. |

---

## 6. CHECK-ID Scoring Procedure

### CORS01 - No Wildcard with Credentials

Fail when `setAllowCredentials(true)` is paired with wildcard origins.

### CORS02 - No Arbitrary Origin Reflection

Fail when a filter sets `Access-Control-Allow-Origin` from the raw `Origin` header without allow-list validation.

### CORS03 - Explicit CORS Justification

Fail when global CORS exists without documentation of consuming clients.

### CORS04 - Safe Subdomain Patterns

Fail when patterns are as broad as `https://*.com`.

### CORS05 - No Null Origin

Fail when `"null"` is an allowed origin.

### CORS06 - CORS Is Not Authorization

Fail when sensitive endpoints lack authentication and rely on CORS as the only gate.

### CORS07 - Explicit Methods and Headers

Fail when `setAllowedMethods("*")` or `setAllowedHeaders("*")` is used for credentialed APIs.

### CORS08 - No Dev or Tunnel CORS Origins

**Zero compromise:** same rule in every profile. Dev/local/test are not exempt.

**In scope** — CORS origin configuration only:

- Properties/YAML: `cors.allowed-origins`, `spring.web.cors.*` origin keys
- Java: `allowedOrigins(`, `addAllowedOrigin(`, `allowedOriginPatterns(`, `@CrossOrigin(origins`

**Out of scope (Pass):** JDBC/Redis URLs, comments, log messages without CORS binding.

**Procedure:**

1. Grep dev/tunnel patterns only inside in-scope CORS contexts.
2. **Fail** if a dev/tunnel pattern is a CORS allowed origin in any reviewed config.
3. Evidence must quote the CORS allow-list line.

### CORS09 - No Wildcard Origin

Fail on `allowedOrigins("*")`, `allowedOriginPatterns("*")`, or `addAllowedOrigin("*")` regardless of credentials.

### CORS10 - CORS Pattern Not Allow-Listed

Fail when `allowedOriginPatterns` contains `*` and the pattern is not exactly listed in Scope Notes CORS10 allow-list. Empty allow-list fails all wildcard patterns.

### CORS11 - Explicit Allowed Methods

Fail when a CORS bean exists but `addAllowedMethod()` was never called.

### CORS12 - CORS Bean Wired

Fail when a CORS bean exists but `http.cors(cors -> cors.configurationSource(...))` is missing from `SecurityFilterChain`.

### CORS13 - No Credentials with Wildcard Headers

Fail when `allowCredentials(true)` is combined with `allowedHeaders("*")`.

---

## 7. Report Requirements

Every scored finding: File, Evidence, Policy Rule, Possible Attack Scenario, five Resolution rows.

**Possible Attack Scenario:** One or two sentences on possible impact if unfixed — not fix advice.

Only Evidence may quote source code. Verify rows require **action + pass signal** (forbidden: bare "Grep codebase" or "Review config").

---

## 8. Secure Resolution Catalog

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| CORS01 | Explicit origins | Strict `List<String>` of allowed domains when credentials enabled | Cookies cannot be stolen by arbitrary domains | Wildcard `*` with credentials | Preflight from unlisted origin receives no `Access-Control-Allow-Origin` |
| CORS02 | Validate before reflect | Match `Origin` against `Set<String>` before setting response header | No blind origin reflection | Unvalidated origin reflection | Request with `Origin: evil.com` lacks matching ACAO |
| CORS03 | Document scope | Comment which frontends consume the API | Intent is maintainable | Undocumented global CORS | Comments exist near `addCorsMappings` |
| CORS04 | Bounded patterns | Use `https://*.mycompany.com` style patterns only | Attackers cannot register bypass domains | `https://*.com` style patterns | Request from attacker subdomain is rejected |
| CORS05 | Reject null | Remove `"null"` from origin lists | File-origin bypass blocked | Accepting `Origin: null` | Request with `Origin: null` is rejected |
| CORS06 | Enforce authz | `@PreAuthorize` or `SecurityFilterChain` on sensitive APIs | Endpoints require valid sessions/tokens | Trusting CORS for authz | Cross-origin request without token returns 401/403 |
| CORS07 | Explicit methods | Named verb and header lists | Unexpected verbs blocked at preflight | Wildcard methods/headers | OPTIONS with `TRACE` is rejected |
| CORS08 | Production peer URLs only | CORS origins from deployment config — no dev hosts in any profile | Dev tools cannot access deployed APIs | localhost/ngrok in any CORS origin list | Search all reviewed CORS origin config; zero dev/tunnel hits |
| CORS09 | Named origins only | `CorsConfigurationSource` with full URL list | Never wildcard origin | `*` in allowed origins | Config shows explicit URLs only; no asterisk wildcard |
| CORS10 | Documented patterns | Wildcard patterns only if listed in Scope Notes with rationale | Subdomain wildcards are minimal and approved | Undocumented `*.domain` | Each wildcard in config appears in CORS10 allow-list |
| CORS11 | OPTIONS included | Explicit `setAllowedMethods` including OPTIONS | Preflight works | CORS bean without methods | OPTIONS preflight returns `Access-Control-Allow-Methods` |
| CORS12 | Wire in chain | `http.cors(...)` in `SecurityFilterChain` | CORS applies to requests | Orphan CORS bean | Response includes ACAO; chain contains `http.cors` |
| CORS13 | Named headers | Explicit header list when credentials enabled | No wildcard headers with credentials | `allowedHeaders("*")` with credentials | Bean lists header names; no header wildcard with credentials |

---

## 9. Scoring Formula

Base Score: 100 · Critical: −20 · High: −10 · Medium: −5 · Low: −2 · Info: 0 · Floor: 0

---

## 10. Final Self-Validation

- Stack gate documented.
- CORS10 allow-list recorded before scoring CORS10.
- CORS08 Fail requires Evidence on a CORS origin line (any profile).
- Every FAIL has five Resolution rows with action + pass signal in Verify.
