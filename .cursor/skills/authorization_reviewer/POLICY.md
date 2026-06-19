# Authorization Security Policy v2.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Frontend-only UI hiding is always a finding.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/authorization_reviewer.md` |
| Cursor invoke name | `authorization_reviewer` |
| Report path | `AI/authorization_reviewer/authorization_reviewer_report.md` |
| Report reviewer line | `authorization_reviewer v2.0 STRICT` |

---

## Verdict Vocabulary

**PASS**, **FAIL**, **MANUAL_REVIEW**, **N/A** only. `UNCLEAR` is forbidden.

---

## Resolution Requirement

Every finding: five Resolution rows (Pattern, Mechanism, Security property, Prohibited, Verify). Only Evidence may quote source.

---

## Strict allow-path structure (org standard)

Applies to every `SecurityFilterChain` / `authorizeHttpRequests` block.

| Layer | Rule |
|-------|------|
| **PUBLIC_PATHS** | `permitAll()` on explicit full paths only — no `*` or `**` |
| **ROLE_PATHS** | `hasRole` / `hasAnyRole` on explicit paths; role names are app-specific |
| **AUTHENTICATED_PATHS** (optional) | `authenticated()` on explicit paths only — never as catch-all |
| **DEFAULT** | `.anyRequest().denyAll()` |

### Unacceptable (always Fail)

| Pattern | Why |
|---------|-----|
| `.anyRequest().permitAll()` | Unlisted paths are public |
| `.anyRequest().authenticated()` | Any logged-in user may access unlisted paths |
| Matcher path contains `*` or `**` | Not an explicit allow-list |
| No explicit deny catch-all | Unlisted paths not blocked |

Role names (`ADMIN`, `VOLUNTEER`, `DEVOTEE`, etc.) vary per app. **Structure** does not.

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| AUTH01 | Intentional SecurityFilterChain | No intentional `SecurityFilterChain` bean; relies on Spring Boot auto-configured defaults |
| AUTH03 | Secure catch-all denyAll | Catch-all is not `.anyRequest().denyAll()` — includes `permitAll()`, `authenticated()`, or missing catch-all |
| AUTH06 | Object-level authorization | URL role checks only; no verification of resource ownership (IDOR/BOLA) |
| AUTH08 | Server-side owner/tenant derivation | Acting user/tenant taken from client payload instead of authenticated principal |
| AUTH09 | Method security enabled | `@PreAuthorize` / `@Secured` / `@RolesAllowed` present but `@EnableMethodSecurity` (or legacy global enabler) absent |
| AUTH10 | No fail-open exception handling | Auth/authz filter swallows exceptions and continues the chain or grants access |

### High

| ID | Citation | Condition |
|---|---|---|
| AUTH02 | Explicit path allow-lists | Paths not mapped to public / role / authenticated levels per strict allow-path structure |
| AUTH04 | No wildcards in security matchers | `requestMatchers` / `antMatchers` use `*` or `**` |
| AUTH05 | Authentication mechanism wired | No explicit authentication mechanism in security configuration |
| AUTH07 | Admin roles least privilege | Elevated roles on broad wildcard paths (e.g. `/admin/**`) without documented full-admin need |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| AUTH01 | Explicit `@EnableWebSecurity` + `SecurityFilterChain` (or documented equivalent) |
| AUTH02 | Every reviewed endpoint has a matching explicit security rule; PUBLIC / ROLE / AUTHENTICATED layers documented in Scope Notes |
| AUTH03 | Chain ends with `.anyRequest().denyAll()` |
| AUTH04 | All matcher paths are exact strings; zero `*` or `**` in path patterns |
| AUTH05 | `.formLogin()`, `.oauth2Login()`, `.httpBasic()`, or equivalent is declared |
| AUTH06 | Service or method layer verifies object ownership for user/tenant resources |
| AUTH07 | Admin/support roles mapped to named endpoints, not blanket wildcards |
| AUTH08 | User/tenant ID from `SecurityContextHolder` or `@AuthenticationPrincipal` |
| AUTH09 | `@EnableMethodSecurity` present when method annotations are used |
| AUTH10 | Security filter exceptions reject the request; no fail-open `chain.doFilter()` on auth errors |

---

## N/A Criteria

| ID | N/A when |
|---|---|
| AUTH01–AUTH05 | Purely public static site with no `SecurityFilterChain` and no secured resources — document proof |
| AUTH06 | No user-specific or tenant-specific resources |
| AUTH07 | No elevated roles |
| AUTH08 | No ownership or multi-tenancy |
| AUTH09 | No method-security annotations in codebase |
| AUTH10 | No custom auth filter exception handlers in reviewed code |

---

## Manual Review Criteria

Dynamic routes, API gateway auth, or ownership in external services — **MANUAL_REVIEW** with exact missing evidence.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| AUTH01 | Access control | Critical | Intentional SecurityFilterChain |
| AUTH02 | Access control | High | Explicit path allow-lists |
| AUTH03 | Access control | Critical | Secure catch-all denyAll |
| AUTH04 | Access control | High | No wildcards in security matchers |
| AUTH05 | Access control | High | Authentication mechanism wired |
| AUTH06 | Access control | Critical | Object-level authorization |
| AUTH07 | Access control | High | Admin roles least privilege |
| AUTH08 | Access control | Critical | Server-side owner/tenant derivation |
| AUTH09 | Access control | Critical | Method security enabled |
| AUTH10 | Exception handling | Critical | No fail-open exception handling |
