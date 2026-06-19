# Middleware, TLS & DoS Security Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Missing outbound timeouts and missing request-body limits are always findings.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/middleware_tls_dos_reviewer.md` |
| Cursor invoke name | `middleware_tls_dos_reviewer` |
| Report path | `AI/middleware_tls_dos_reviewer/middleware_tls_dos_reviewer_report.md` |
| Report reviewer line | `middleware_tls_dos_reviewer v1.0 STRICT` |

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
| MTD01 | HTTPS end-to-end | Application transmits passwords or session cookies over plain HTTP, or generates `http://` redirect URLs when behind a TLS-terminating proxy |
| MTD07 | Outbound client timeouts | `RestTemplate`, `WebClient`, or `HttpClient` beans are created without explicit connect and read timeouts, allowing a dead upstream to block threads indefinitely |

### High

| ID | Citation | Condition |
|---|---|---|
| MTD02 | Forward-headers-strategy configured | Application runs behind a reverse proxy but does not set `server.forward-headers-strategy=framework`, leading to incorrect remote-address, scheme, and redirect URLs |
| MTD03 | HSTS enforcement | Neither the application nor the documented edge layer sends a `Strict-Transport-Security` header on HTTPS responses |
| MTD05 | Secure proxy behaviour | Cookies lack the `Secure` flag or the application generates mixed-content (HTTP) URLs when TLS terminates at the proxy |
| MTD06 | Request body size limits | Request-body limits (`server.tomcat.max-http-form-post-size`, `spring.servlet.multipart.max-file-size`, `spring.servlet.multipart.max-request-size`) are not explicitly configured, relying on permissive framework defaults |

### Medium

| ID | Citation | Condition |
|---|---|---|
| MTD04 | Patching cadence | Spring Boot parent version is older than 2 minor releases behind the latest stable, or the JVM/container base image is visibly outdated without documented patching cadence |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| MTD01 | All authenticated endpoints require HTTPS; `http.requiresChannel().anyRequest().requiresSecure()` or equivalent is active, or TLS is documented at the edge with no mixed-content paths. |
| MTD02 | `server.forward-headers-strategy=framework` is set in properties, or the application is not behind a proxy (documented). |
| MTD03 | HSTS header is configured in Spring Security headers or documented as set by the reverse proxy/CDN. |
| MTD04 | Spring Boot parent is within 2 minor releases of the latest. |
| MTD05 | `server.servlet.session.cookie.secure=true` is configured, and no generated URLs use `http://` when accessed via HTTPS proxy. |
| MTD06 | `server.tomcat.max-http-form-post-size`, `spring.servlet.multipart.max-file-size`, and `spring.servlet.multipart.max-request-size` are all explicitly configured. |
| MTD07 | Every outbound HTTP client bean explicitly sets connect timeout (≤ 10s) and read timeout (≤ 30s or project-appropriate). |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| MTD02 | Application explicitly does not run behind any reverse proxy (standalone deployment documented). |
| MTD03 | Covered by `clickjacking_headers_reviewer` HDR05. If HDR05 already assessed HSTS for this project, mark N/A with cross-reference. |
| MTD05 | Application does not use sessions or cookies (pure stateless JWT API). |
| MTD06 | Application accepts no request bodies (GET-only API). |
| MTD07 | Application makes no outbound HTTP calls. |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- TLS termination occurs at an Nginx, AWS ALB, or Cloudflare edge whose configuration is not in the repo.
- HSTS is reportedly set by a CDN or load balancer, but the config cannot be verified here.
- Patching cadence is managed by an external team with a schedule not visible in the codebase.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| MTD01 | TLS | Critical | HTTPS end-to-end |
| MTD02 | Middleware | High | Forward-headers-strategy configured |
| MTD03 | TLS | High | HSTS enforcement |
| MTD04 | Patching | Medium | Patching cadence |
| MTD05 | TLS | High | Secure proxy behaviour |
| MTD06 | DoS | High | Request body size limits |
| MTD07 | DoS | Critical | Outbound client timeouts |
