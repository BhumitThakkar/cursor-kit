---
name: session_reviewer
version: 1.1
disable-model-invocation: true
---

# Session Management Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar. A safe dev profile does not excuse an unsafe prod profile.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/session_reviewer.md` |
| Skill directory | `.cursor/skills/session_reviewer/` |
| Cursor invoke name | `session_reviewer` |
| Report path | `AI/session_reviewer/session_reviewer_report.md` |
| Report reviewer line | `session_reviewer v1.1 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications with session-based or cookie-based authentication.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency |
| Session/Auth | `spring-session`, `HttpServletRequest.getSession()`, `jjwt`, `nimbus-jose-jwt`, `spring-boot-starter-oauth2-resource-server` |
| Servlet MVC or REST | `spring-boot-starter-web`, `@Controller`, `@RestController`, `SecurityFilterChain`, or MVC mappings |
| Session/cookie surface | Servlet session usage, `Set-Cookie` headers, Spring Security session management, login/logout endpoints |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| Spring WebFlux primary stack only | Spring WebFlux |
| CLI/batch-only application with no session/cookie surface | Batch-only |
| Static website only | Static site |
| Pure stateless API with no servlet session and no cookies | Stateless API (note: verify no session is created at all) |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for session_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application with session-based or cookie-based authentication.

You need a different, specialized security reviewer to review this application. This agent audits session management and cookie security for Spring Boot servlet applications only.
```

No scored findings for out-of-scope projects.

---

## 2. File Discovery

Scan in this order.

### Build and Config

- `pom.xml`, `build.gradle`, `build.gradle.kts`
- `application.properties`, `application.yml`, and all profile variants (`application-dev.*`, `application-prod.*`, etc.)
- `server.servlet.session.*` properties
- Embedded container configuration (Tomcat, Jetty, Undertow)

### Spring Security Configuration

- `SecurityFilterChain` bean definitions
- `sessionManagement()` configuration
- `sessionFixation()` strategy
- `sessionCreationPolicy()`
- Logout handler configuration
- CSRF cookie repository configuration

### Cookie Configuration

- `server.servlet.session.cookie.*` properties
- Programmatic `Cookie` or `ResponseCookie` construction
- `CookieSerializer` or `DefaultCookieSerializer` beans
- Servlet filter cookie manipulation
- Reverse proxy / `ForwardedHeaderFilter` configuration

### Login/Logout Endpoints

- Form login configuration
- OAuth2/OIDC login configuration
- Custom authentication endpoints
- Logout endpoint and handler chain
- Session invalidation calls

### URL Rewriting

- `server.servlet.session.tracking-modes` property
- `DisableUrlRewritingFilter` or equivalent
- Link generation and redirect construction

### JWT and Stateless Tokens

- JWT parsers (`Jwts.parser()`, `JwtDecoder`)
- Token generation logic
- Logout controllers for stateless architectures
- Secret key loading and configuration

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find session creation | `rg -n "getSession\(true\)\|@SessionAttributes" src` |
| Find cookie config | `rg -n "session\.cookie\.secure\|session\.cookie\.http-only" src` |
| Find timeout config | `rg -n "session\.timeout\|setMaxInactiveInterval" src` |
| Find logout | `rg -n "session\.invalidate\(\)\|logout" src` |
| Find URL rewriting | `rg -n "encodeURL\|tracking-modes" src` |
| Find JWT parsing | `rg -n "Jwts\.parser\|JwtDecoder\|parseClaimsJws" src` |
| Find JWT keys | `rg -n "setSigningKey\|secret\|HS256" src` |
| Find blocklists | `rg -n "Redis.*Token\|revokeToken\|blocklist" src` |
| Find session management code | `rg -n "sessionManagement\|sessionFixation\|changeSessionId\|sessionCreationPolicy\|maximumSessions" src` |
| Find cookie construction | `rg -n "Cookie\|ResponseCookie\|CookieSerializer\|DefaultCookieSerializer\|addCookie\|setCookie\|Set-Cookie" src` |
| Find cookie flags | `rg -n "setSecure\|setHttpOnly\|setSameSite\|setPath\|setDomain\|setMaxAge\|cookie\.secure\|cookie\.http-only\|cookie\.same-site" src .` |
| Find login endpoints | `rg -n "formLogin\|loginPage\|loginProcessingUrl\|successHandler\|authenticationManager\|authenticate" src` |
| Find cookie echo | `rg -n "@CookieValue\|getCookies\(\)" src templates` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| SES01 | Application does not use servlet sessions (pure stateless JWT/token with no server session) |
| SES02 | Application does not use servlet sessions |
| SES03 | Application does not have login or authentication flow |
| SES04 | Application does not use servlet sessions |
| SES05 | Application does not set any cookies |
| SES06 | Application does not set any cookies |
| SES07 | Application serves only from root context with no narrower scope practical; document why |
| SES08 | Application runs on single host with no subdomains; cookie Domain is omitted (host-only by default) |
| SES09 | No cookie uses SameSite=None |
| SES10 | Application does not use servlet sessions (pure stateless) |
| SES11 | Application has no logout endpoint and no authenticated session |
| SES12 | Application does not use servlet sessions (pure stateless) |

Do not use N/A because evidence was hard to trace. Use MANUAL_REVIEW.

---

## 5. CHECK-ID Scoring Procedure

### SES01 - Session ID Entropy

Fail when session ID has fewer than 120 bits of entropy, uses a weak or predictable generator, or overrides the default servlet container session ID generator with a weaker implementation.

Pass requires evidence that the default servlet container session ID generator is used (which provides ≥ 120 bits) or a custom generator meets the entropy requirement.

### SES02 - Session ID in Cookie Only

Fail when session ID appears in URL (`;jsessionid`), query parameters, `Referer` headers, response bodies, or any non-cookie transport mechanism.

Pass requires evidence that `tracking-modes=cookie` is configured and no code generates URLs with embedded session IDs.

### SES03 - New Session on Login

Fail when session ID is not rotated after successful authentication. Pre-login session ID that persists into an authenticated session creates a fixation attack surface.

Pass requires evidence that `sessionFixation().changeSessionId()` or `migrateSession()` or `newSession()` is configured in Spring Security, or explicit `request.changeSessionId()` is called after authentication.

### SES04 - URL Rewriting Disabled

Fail when URL rewriting is not explicitly disabled and `;jsessionid` can appear in generated links, redirects, or error pages.

Pass requires evidence that `server.servlet.session.tracking-modes=cookie` is set, or `DisableUrlRewritingFilter` is registered, or `encodeURL`/`encodeRedirectURL` are not used.

### SES05 - Cookie Secure Flag

Fail when session cookie or any authentication-related cookie is sent without the `Secure` attribute in any profile that serves or will serve over HTTPS. A safe dev profile does not excuse an unsafe prod profile.

Pass requires `server.servlet.session.cookie.secure=true` or programmatic equivalent across all relevant profiles.

### SES06 - Cookie HttpOnly Flag

Fail when session cookie is sent without `HttpOnly` attribute. Exception: a CSRF token cookie using `CookieCsrfTokenRepository.withHttpOnlyFalse()` is acceptable only if documented and cross-referenced with SP-07.

Pass requires `server.servlet.session.cookie.http-only=true` or programmatic equivalent.

### SES07 - Cookie Path Scoped

Fail when session cookie `Path` is set to `/` and a narrower scope is practical given the application's URL structure (e.g., app is mounted under `/app/` but cookie path is `/`).

Pass requires evidence that cookie path matches or is narrower than the application's context path, or documentation that `/` is the narrowest practical scope.

### SES08 - Cookie Domain Scoped

Fail when session cookie uses a wildcard parent domain (e.g., `Domain=.example.com`) that exposes the cookie to sibling subdomains.

Pass requires that cookie `Domain` is omitted (host-only by default) or scoped to the specific application host.

### SES09 - SameSite=None Requires Secure and Documentation

Fail when any cookie uses `SameSite=None` without the `Secure` attribute, or when `SameSite=None` is used without documented justification for why cross-site cookie sending is required.

Pass when no cookie uses `SameSite=None`, or when `SameSite=None` is used with `Secure` and documented justification.

### SES10 - Timeout Invalidates Server Session

Fail when session timeout only clears the client cookie without invalidating the server-side session, or when no timeout is configured and sessions persist indefinitely.

Pass requires `server.servlet.session.timeout` or equivalent with a defined value, and evidence that server-side session data is invalidated (not just cookie expired).

### SES11 - Logout Invalidates Session
Fail when a logout endpoint clears the cookie but does not call `session.invalidate()` or invoke a configured `LogoutHandler` that destroys the server-side state.

### SES12 - Inactivity and Absolute Timeout Defined
Fail when no `spring.session.timeout` is set (relying on infinite or dangerously long defaults) and no absolute re-authentication policy exists.

### SES13 - JWT Signature Verification
Fail when the application parses JWTs using insecure methods (e.g., `Jwts.parser().parse()` instead of `parseClaimsJws()`), fails to verify the signature, or allows the `none` algorithm.

### SES14 - JWT Secret Key Strength
Fail when symmetric JWT secrets (HS256) are hardcoded, shorter than 256 bits, or generated using a weak PRNG.

### SES15 - JWT Claims Validation
Fail when the JWT parser does not strictly validate the `exp` (expiration), `iss` (issuer), and `aud` (audience) claims against expected backend values.

### SES16 - JWT Explicit Invalidation
Fail when the application uses stateless JWTs for authentication but provides a logout endpoint that merely deletes the client-side cookie without invalidating the token on the server (e.g., via a Redis blocklist).

### SES17 - Session Cookie SameSite Explicit

Fail when session cookie configuration omits explicit SameSite (Strict or Lax). Exception: documented `SameSite=None` path covered by SES09.

### SES18 - Custom Cookie Flags Complete

Fail when application code creates custom cookies via `ResponseCookie`, `new Cookie(`, or filters without setting httpOnly, secure, and sameSite on each.

### SES19 - Cookie Value Not Echoed

Fail when `@CookieValue` or raw cookie values appear in templates, `@ResponseBody` responses, or HTML concatenation without validation.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:

- session ID entropy depends on container configuration not visible in repo (e.g., external Tomcat),
- cookie flags are set by a reverse proxy, load balancer, or CDN whose config is not in repo,
- TLS termination happens at infrastructure layer and Secure flag behavior depends on proxy header forwarding,
- session invalidation depends on a distributed session store (Redis, Hazelcast) whose eviction policy is not visible,
- timeout values are injected at deploy time via environment variables not present in repo,
- SameSite behavior depends on cross-origin deployment topology not documented,
- logout handler is provided by an external identity provider or SSO framework not in codebase,
- session concurrency control depends on cluster configuration.

Manual review is not Pass.

---

## 7. Report Requirements

Every scored finding must include:

| Field | Requirement |
|---|---|
| File | Project-relative file path and line number |
| Evidence | Exact source/config/test line or runtime proof |
| Policy Rule | `POLICY.md - {CHECK-ID} - {citation}` |
| Possible Attack Scenario | Realistic impact in one or two sentences |
| Resolution | Five rows from section 8 |

Evidence is the only field that may quote project source. Resolution rows are prose, not pasteable code.

### 7.1 Verify Row Rules

Every Verify row must include:

1. Action: what to test, inspect, or search.
2. Pass signal: observable result that proves the fix.

Forbidden Verify text:

- `Review cookies`
- `Grep codebase`
- `Add flags`
- `Check manually`

Replace with direct action and pass signal.

---

## 8. Secure Resolution Catalog

Use one row set per finding.

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| SES01 | Default container session ID | Use servlet container default session ID generator (Tomcat `SecureRandom` with 128-bit output); do not override with weaker custom generator | Session ID has ≥ 120 bits of cryptographic randomness; not predictable or enumerable | Custom weak random generator, sequential IDs, short session tokens | Inspect session ID length and format; confirm container default or equivalent entropy |
| SES02 | Cookie-only transport | Configure `server.servlet.session.tracking-modes=cookie`; never embed session ID in URL, query parameter, or response body | Session ID is only transmitted via cookie header; no URL leakage via Referer or logs | Session ID in URL (`;jsessionid`), query parameters, or response bodies | Inspect generated links and redirects; confirm no `;jsessionid` appears; check Referer headers |
| SES03 | Session rotation on login | Configure `sessionFixation().changeSessionId()` in Spring Security; verify pre-login session ID is replaced | Pre-login session ID cannot be fixed into authenticated session; new session ID issued after login | Same session ID before and after login; no fixation protection | Login and compare session ID before and after; confirm ID changes; attempt fixation with pre-set cookie |
| SES04 | Disable URL rewriting | Set `server.servlet.session.tracking-modes=cookie`; remove `encodeURL`/`encodeRedirectURL` calls | `;jsessionid` never appears in any generated link, redirect, or error page | URL rewriting enabled; `;jsessionid` in links or redirects | Search all generated output for `;jsessionid`; confirm tracking-modes=cookie in config |
| SES05 | Secure cookie flag | Set `server.servlet.session.cookie.secure=true` across all profiles; validate at HTTPS edge if proxy terminates TLS | Session cookie is only sent over HTTPS connections; not exposed on HTTP | Session cookie without Secure flag in any profile | Inspect `Set-Cookie` response header; confirm `Secure` attribute present; test HTTP request does not receive cookie |
| SES06 | HttpOnly cookie flag | Set `server.servlet.session.cookie.http-only=true`; document any CSRF cookie exception with SP-07 reference | Session cookie is not accessible to JavaScript; XSS cannot steal session ID | Session cookie without HttpOnly (except documented CSRF cookie pattern) | Inspect `Set-Cookie` response header; confirm `HttpOnly` attribute present; attempt `document.cookie` access |
| SES07 | Narrow cookie path | Set cookie `Path` to application context path or narrower; avoid `/` when app is mounted under subpath | Session cookie is scoped to the application path; not sent to unrelated paths on same host | Cookie Path broader than necessary when narrower scope is practical | Inspect `Set-Cookie` Path attribute; confirm it matches application context path |
| SES08 | Host-only cookie domain | Omit `Domain` attribute for host-only cookie, or set to specific application host; never use wildcard parent domain | Session cookie is not shared with sibling subdomains | `Domain=.example.com` or wildcard parent domain exposing cookie to sibling sites | Inspect `Set-Cookie` Domain attribute; confirm omitted or specific host; not wildcard |
| SES09 | SameSite=None with Secure and docs | If cross-site cookie is required, set both `SameSite=None` and `Secure`; document the cross-site requirement | Cross-site cookies are only sent over HTTPS with documented justification | `SameSite=None` without `Secure`; undocumented cross-site cookie sending | Inspect `Set-Cookie` header; confirm `SameSite=None` has `Secure`; locate documentation justifying cross-site use |
| SES10 | Server-side timeout invalidation | Configure `server.servlet.session.timeout` with appropriate value; ensure container invalidates server session data on expiry | Expired sessions are destroyed server-side; stale session ID cannot resume authenticated access | Client-only cookie expiry without server session invalidation; indefinite session persistence | Wait beyond timeout; attempt authenticated action with old session ID; confirm rejection |
| SES11 | Destroy server session | Call `session.invalidate()` | Sessions remain valid | Only clearing client cookie | Capture session ID, logout, replay ID; confirm 401 |
| SES12 | Timeout config | Set `server.servlet.session.timeout` in `application.properties` | Abandoned sessions expire | Infinite sessions | Wait past timeout; confirm 401 |
| SES13 | Enforce Signature | Use `parseClaimsJws()` and explicitly set the allowed algorithms | Forged tokens are rejected | `alg=none` | Submit token with `alg=none` and stripped signature; confirm 401 |
| SES14 | Strong Secrets | Inject a 256+ bit secure random key via environment variables | Keys cannot be brute-forced | Hardcoded weak keys | Verify key length and source in code |
| SES15 | Validate Claims | Require `exp`, `iss`, `aud` in parser builder | Expired or misdirected tokens fail | Ignoring standard claims | Submit expired token; confirm 401 |
| SES16 | Token Blocklist | Store revoked JTI (Token ID) in Redis with TTL equal to token expiration | Logged out tokens cannot be reused | Pure stateless logout | Logout, then replay token; confirm 401 |
| SES17 | Explicit SameSite | Set `server.servlet.session.cookie.same-site=Strict` or `Lax` | CSRF mitigation on session cookie | Missing SameSite on session | Set-Cookie includes SameSite Strict or Lax |
| SES18 | Full flag set on custom cookies | `ResponseCookie` with httpOnly, secure, sameSite on each custom cookie | Custom cookies meet session standard | Partial flags on custom cookies | Each custom cookie builder sets all three flags |
| SES19 | No cookie echo | Use cookie as lookup key only; never reflect value in output | Cookie value not in HTML/JSON | Cookie value in template or response body | Cookie value absent from response body |

---

## 9. Scoring Formula

```text
Base Score: 100

Critical: -20
High:     -10
Medium:   -5
Low:      -2
Info:      0

Floor: 0

Grade:
90-100 = A
75-89  = B
60-74  = C
40-59  = D
0-39   = F
```

Manual review does not reduce the score, but it blocks a clean security conclusion.

---

## 10. Final Self-Validation

Before finalizing a report:

- Confirm stack gate result and evidence.
- Confirm every CHECK-ID is PASS, FAIL, MANUAL_REVIEW, or N/A.
- Confirm no `UNCLEAR` appears.
- Confirm every failed CHECK-ID has the required finding fields.
- Confirm every N/A includes proof.
- Confirm all profile-specific configs are reviewed (dev does not excuse prod).
- Confirm missing Secure or HttpOnly is always Fail for session cookies.
- Confirm session fixation without rotation is always Fail.
- Confirm Executive Summary totals match Findings and Manual Review.
- Confirm no code changes were made.
