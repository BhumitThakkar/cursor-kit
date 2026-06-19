---
name: authorization_reviewer
version: 2.0
disable-model-invocation: true
---

# Authorization Security Reviewer - Scan Skill v2.0 STRICT

| Report line | `authorization_reviewer v2.0 STRICT` |
| Report path | `AI/authorization_reviewer/authorization_reviewer_report.md` |

---

## 1. Supported Technology Stack

Spring Boot servlet MVC or REST with `SecurityFilterChain` and secured resources.

Out of scope → mandatory wording; no CHECK-IDs scored.

---

## 2. File Discovery

### Security configuration (strict allow-path primary surface)

- `**/SecurityConfig.java`, `**/*Application.java` with `SecurityFilterChain`
- `authorizeHttpRequests` / `authorizeRequests` blocks
- `@EnableWebSecurity`, `@EnableMethodSecurity`

### Controllers (for AUTH02 inventory)

- All `@Controller` / `@RestController` mappings — cross-check every path has a security rule

### Method security & object auth

- `@PreAuthorize`, `@Secured`, `@RolesAllowed`
- Services/repos with `@PathVariable` IDs and ownership checks
- DTOs with client-supplied `userId`, `tenantId`, `ownerId`

Do not deep-read business logic unless tracing AUTH06/AUTH08.

---

## 3. Strict allow-path scan (AUTH02–AUTH04, AUTH03)

Apply **POLICY.md strict allow-path structure** to every `SecurityFilterChain`. All must pass:

1. **Catch-all** is `.anyRequest().denyAll()` — not `permitAll()`, not `authenticated()`, not absent
2. **No wildcard** in any matcher path (`*` or `**`)
3. **`permitAll()`** only on explicitly named public paths
4. **`hasRole` / `hasAnyRole`** only on explicitly named role paths (role names are app-specific — do not fail for `DEVOTEE` vs `ADMIN`)
5. **`authenticated()`** only on explicitly named paths — never on `anyRequest()`

### Acceptable pattern (structure reference)

Public paths with `permitAll()`, role paths with `hasAnyRole`, optional login-only paths with `authenticated()` on named URLs, then `.anyRequest().denyAll()`.

---

## 4. Required Search Probes

| Goal | Probe |
|---|---|
| Security config | `rg -n "@EnableWebSecurity\|SecurityFilterChain" src` |
| Authorize block | `rg -n "authorizeHttpRequests\|requestMatchers" src` |
| Catch-all | `rg -n "anyRequest\(\)\.(permitAll\|authenticated\|denyAll)" src` |
| Wildcards | `rg -n "requestMatchers.*\"\*\"\|requestMatchers.*\"\*\*\"" src` |
| Method security | `rg -n "@PreAuthorize\|@EnableMethodSecurity" src` |
| Fail-open | `rg -n "catch.*Exception.*doFilter\|chain\.doFilter" src` |
| Client IDs | `rg -n "setUserId\|setTenantId\|setOwnerId" src` |

---

## 5. CHECK-ID Scoring Procedure

### AUTH01 — Intentional SecurityFilterChain

Fail when no explicit `SecurityFilterChain` bean exists.

### AUTH02 — Explicit Path Allow-lists

Fail when controller endpoints lack matching explicit security rules, or PUBLIC / ROLE / AUTHENTICATED layers are incomplete. Inventory paths in Scope Notes.

### AUTH03 — Secure Catch-all denyAll

Fail on `.anyRequest().permitAll()`, `.anyRequest().authenticated()`, or missing `anyRequest()` rule. **Only** `.anyRequest().denyAll()` passes.

### AUTH04 — No Wildcards

Fail on `*` or `**` in any security matcher path.

### AUTH05 — Authentication Wired

Fail when no `.formLogin()`, `.oauth2Login()`, `.httpBasic()`, or equivalent is configured.

### AUTH06 — Object-level Authorization

Fail when resource access uses URL roles only without ownership check (IDOR/BOLA).

### AUTH07 — Admin Least Privilege

Fail when elevated roles use broad wildcard admin paths without documented super-admin need.

### AUTH08 — Server-side Identity

Fail when acting user/tenant comes from request body or hidden fields.

### AUTH09 — Method Security Enabled

Fail when security annotations exist but `@EnableMethodSecurity` is missing.

### AUTH10 — No Fail-open Exceptions

Fail when auth filter catch blocks log and call `chain.doFilter()` or otherwise allow the request through on security exceptions.

---

## 6. Report Requirements

Possible Attack Scenario: 1–2 sentences. Five Resolution rows; Verify = action + pass signal.

---

## 7. Secure Resolution Catalog

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| AUTH01 | Explicit config | `@EnableWebSecurity` + `SecurityFilterChain` bean | Intentional security posture | Auto-config defaults only | Explicit filter chain bean in config |
| AUTH02 | Strict allow-path layers | Map PUBLIC, ROLE, AUTHENTICATED paths explicitly | Every endpoint has conscious access rule | Unmapped endpoints | Endpoint inventory matches matchers |
| AUTH03 | denyAll catch-all | End chain with `.anyRequest().denyAll()` | Unknown paths blocked | permitAll or authenticated catch-all | Request to unlisted path returns 403 |
| AUTH04 | Exact path strings | Named paths without wildcards | No path-tree bypass | `**` or `*` in matchers | Matchers contain no asterisk wildcards |
| AUTH05 | Explicit auth | Declare form login, OAuth2, or Basic in chain | Authentication method is defined | Missing auth mechanism | Auth entry point configured |
| AUTH06 | Ownership check | Service-layer or `@PreAuthorize` ownership | Users access only own objects | URL-only role checks | User A cannot access User B resource ID |
| AUTH07 | Least privilege roles | Named admin endpoints per role | Admins lack blanket access | `/admin/**` for limited roles | Limited role gets 403 on unrelated admin URL |
| AUTH08 | Principal trust | ID from `AuthenticationPrincipal` | Client cannot spoof actor | Client-supplied acting user ID | Spoofed userId in body rejected |
| AUTH09 | Enable method security | `@EnableMethodSecurity` on configuration class | Annotations enforced at runtime | Annotations without enabler | `@PreAuthorize` denies unauthorized caller |
| AUTH10 | Fail closed | Re-throw or return 401/403 on filter exceptions | Errors never grant access | catch-and-continue in auth filter | Simulated auth failure returns 401/403 |

---

## 8. Scoring

Base 100 · Critical −20 · High −10 · Medium −5 · Low −2 · Floor 0

---

## 9. Self-Validation

- `anyRequest().authenticated()` or `permitAll()` is always AUTH03 Fail.
- Wildcard matcher is always AUTH04 Fail.
- AUTH10 scored when custom auth filters exist.
- Every FAIL has five Resolution rows.
