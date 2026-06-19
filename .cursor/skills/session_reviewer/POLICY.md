# Session Management Security Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. A safe dev profile does not excuse an unsafe prod profile.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/session_reviewer.md` |
| Cursor invoke name | `session_reviewer` |
| Report path | `AI/session_reviewer/session_reviewer_report.md` |
| Report reviewer line | `session_reviewer v1.1 STRICT` |

---

## Verdict Vocabulary

Allowed values only:

- PASS
- FAIL
- MANUAL_REVIEW
- N/A

`UNCLEAR` is forbidden. If evidence is insufficient, use MANUAL_REVIEW and state the exact missing evidence.

---

## Resolution Requirement

Every finding must include a Resolution with five rows:

1. Pattern
2. Mechanism
3. Security property
4. Prohibited
5. Verify

Only Evidence may quote project source. Resolution rows must be prose, not pasteable code.

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| SES03 | New session on login | Session ID is not rotated after successful authentication; pre-login session ID persists into authenticated session (fixation risk) |
| SES05 | Cookie Secure flag required | Session cookie is sent without `Secure` attribute in any profile that serves or will serve over HTTPS |
| SES11 | Logout invalidates session | Logout endpoint does not invalidate the server-side session; session remains usable after logout |
| SES13 | JWT signature verification | Application accepts JWTs but fails to cryptographically verify the signature, or explicitly permits the `none` algorithm |
| SES14 | JWT secret key strength | JWTs are signed or verified using weak, hardcoded, or easily guessable symmetric keys (e.g., < 256 bits for HS256) |
| SES16 | JWT explicit invalidation | Application uses stateless JWTs but lacks a token blocklist or revocation mechanism to handle logouts or compromised accounts |

### High

| ID | Citation | Condition |
|---|---|---|
| SES01 | Session ID entropy | Session ID has fewer than 120 bits of entropy or uses a weak/predictable generator instead of the servlet container default |
| SES02 | Session ID in cookie only | Session ID appears in URL (`;jsessionid`), query parameters, `Referer` headers, or non-cookie transport |
| SES04 | URL rewriting disabled | URL rewriting is not disabled; `;jsessionid` can appear in generated links or redirects |
| SES06 | Cookie HttpOnly flag required | Session cookie is sent without `HttpOnly` attribute (exception: documented CSRF cookie-repository pattern per SP-07) |
| SES08 | Cookie Domain scoped | Session cookie uses wildcard parent domain (e.g., `Domain=.example.com`) instead of host-only or narrowly scoped domain |
| SES10 | Timeout invalidates server session | Server session is not invalidated on timeout; session data persists server-side after inactivity or absolute timeout |
| SES12 | Inactivity and absolute timeout defined | No inactivity timeout or no absolute/reauthentication timeout is configured for sessions |
| SES15 | JWT claims validation | Application accepts JWTs without strictly validating the `exp` (expiration), `iss` (issuer), and `aud` (audience) claims |
| SES17 | Session cookie SameSite explicit | Session cookie lacks explicit SameSite (Strict or Lax) configuration |
| SES19 | Cookie value not echoed | `@CookieValue` or cookie value reflected in HTML/JSON output without validation |

### Medium

| ID | Citation | Condition |
|---|---|---|
| SES07 | Cookie Path scoped | Session cookie `Path` is set to `/` or broader than necessary when a narrower scope is practical |
| SES09 | SameSite=None requires Secure and documentation | Cookie uses `SameSite=None` without `Secure` attribute or without documented justification for cross-site sending |
| SES18 | Custom cookie flags complete | Custom `ResponseCookie` / `Cookie` missing httpOnly, secure, or sameSite |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| SES01 | Session ID uses servlet container default or cryptographically random generator with ≥ 120 bits entropy. Evidence shows configuration or default is sufficient. |
| SES02 | Session ID is transported only in cookies. No URL rewriting, no `;jsessionid` in links/redirects, no session ID in query parameters or headers. |
| SES03 | Spring Security `sessionFixation().changeSessionId()` or equivalent is configured; pre-login session ID is replaced after authentication. Evidence in security config. |
| SES04 | URL rewriting is disabled via `server.servlet.session.tracking-modes=cookie` or equivalent configuration. No `;jsessionid` appears in generated output. |
| SES05 | `server.servlet.session.cookie.secure=true` or programmatic equivalent is set in all profiles including production. |
| SES06 | `server.servlet.session.cookie.http-only=true` or programmatic equivalent is set. Exception allowed only for documented CSRF cookie-repository pattern with SP-07 cross-reference. |
| SES07 | Cookie `Path` is scoped as narrowly as practical for the application's URL structure. |
| SES08 | Cookie `Domain` is omitted (host-only) or scoped to the specific host. No wildcard parent domain. |
| SES09 | If `SameSite=None` is used, `Secure` is also set and the cross-site requirement is documented. If `SameSite=Lax` or `Strict`, this check passes automatically. |
| SES10 | Server session is invalidated (not just cookie cleared) when timeout occurs. `server.servlet.session.timeout` or equivalent is configured. |
| SES11 | Logout endpoint calls `session.invalidate()` or uses `SecurityContextLogoutHandler`. Post-logout session ID cannot perform authenticated actions. |
| SES12 | Both inactivity timeout and absolute/reauthentication timeout are defined with values appropriate to risk level. |
| SES13 | JWT validation explicitly requires and verifies a strong cryptographic algorithm (e.g., RS256, HS256). The `none` algorithm is explicitly rejected. |
| SES14 | JWT symmetric keys are cryptographically random, securely injected via environment/vault, and meet the algorithm's minimum length (e.g., ≥ 256 bits). |
| SES15 | JWT parser is configured to strictly require and validate the `exp`, `iss`, and `aud` claims against expected values. |
| SES16 | A token blocklist (e.g., in Redis) or short-lived token + refresh token architecture is implemented to allow explicit revocation of stateless JWTs. |
| SES17 | Session cookie sets explicit SameSite (Strict or Lax) in all reviewed profiles. |
| SES18 | Every custom cookie builder sets HttpOnly, Secure, and SameSite explicitly. |
| SES19 | Cookie values are lookup keys only; never echoed in response bodies. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| SES01 | Application does not use servlet sessions (pure stateless JWT/token with no server session). |
| SES02 | Application does not use servlet sessions. |
| SES03 | Application does not have login or authentication flow. |
| SES04 | Application does not use servlet sessions. |
| SES05 | Application does not set any cookies. |
| SES06 | Application does not set any cookies. |
| SES07 | Application serves only from root context with no narrower scope practical. Document why. |
| SES08 | Application runs on a single host with no subdomains. Cookie `Domain` is omitted (host-only by default). |
| SES09 | No cookie uses `SameSite=None`. |
| SES10 | Application does not use servlet sessions (pure stateless). |
| SES11 | Application has no logout endpoint and no authenticated session. |
| SES12 | Application does not use servlet sessions (pure stateless). |
| SES13 | Application does not use JWTs or stateless tokens for authentication. |
| SES14 | Application does not use JWTs, or uses exclusively asymmetric keys (RS256) where the private key is not in the codebase. |
| SES15 | Application does not use JWTs. |
| SES16 | Application uses purely stateful servlet sessions (where `SES11` applies). |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- session ID entropy depends on container configuration not visible in repo,
- cookie flags are set by a reverse proxy or load balancer whose config is not in repo,
- TLS termination happens at infrastructure layer and Secure flag behavior depends on proxy headers,
- session invalidation depends on a distributed session store (Redis, Hazelcast) whose eviction policy is not visible,
- timeout values are injected at deploy time via environment variables not present in repo,
- SameSite behavior depends on browser version or cross-origin deployment topology,
- logout handler is provided by an external identity provider or SSO framework not in codebase.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| SES01 | Session | High | Session ID entropy |
| SES02 | Session | High | Session ID in cookie only |
| SES03 | Session | Critical | New session on login |
| SES04 | Session | High | URL rewriting disabled |
| SES05 | Session | Critical | Cookie Secure flag required |
| SES06 | Session | High | Cookie HttpOnly flag required |
| SES07 | Session | Medium | Cookie Path scoped |
| SES08 | Session | High | Cookie Domain scoped |
| SES09 | Session | Medium | SameSite=None requires Secure and documentation |
| SES10 | Session | High | Timeout invalidates server session |
| SES11 | Session | Critical | Logout invalidates session |
| SES12 | Session | High | Inactivity and absolute timeout defined |
| SES13 | Session | Critical | JWT signature verification |
| SES14 | Session | Critical | JWT secret key strength |
| SES15 | Session | High | JWT claims validation |
| SES16 | Session | Critical | JWT explicit invalidation |
| SES17 | Cookies | High | Session cookie SameSite explicit |
| SES18 | Cookies | Medium | Custom cookie flags complete |
| SES19 | Cookies | High | Cookie value not echoed |
