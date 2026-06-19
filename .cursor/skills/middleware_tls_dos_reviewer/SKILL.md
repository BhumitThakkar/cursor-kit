---
name: middleware_tls_dos_reviewer
version: 1.0
disable-model-invocation: true
---

# Middleware, TLS & DoS Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/middleware_tls_dos_reviewer.md` |
| Skill directory | `.cursor/skills/middleware_tls_dos_reviewer/` |
| Cursor invoke name | `middleware_tls_dos_reviewer` |
| Report path | `AI/middleware_tls_dos_reviewer/middleware_tls_dos_reviewer_report.md` |
| Report reviewer line | `middleware_tls_dos_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications requiring network transport, proxy awareness, or request-size governance.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |
| Network surface | Controllers, outbound HTTP clients, multipart configuration |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| Batch/CLI only | Batch application |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for middleware_tls_dos_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application.
```

---

## 2. File Discovery

Scan in this order.

### Application Properties

- `application.properties`, `application.yml` (all profiles)
- Forward-headers strategy (`server.forward-headers-strategy`)
- Session cookie configuration (`server.servlet.session.cookie.secure`)
- Body size limits (`server.tomcat.max-http-form-post-size`, `spring.servlet.multipart.*`)

### Security Configuration

- `SecurityFilterChain` channel security (`requiresChannel`)
- HSTS configuration (cross-ref with HDR05 if present)

### HTTP Clients

- `RestTemplate` and `RestTemplateBuilder` beans
- `WebClient` and `WebClient.Builder` beans
- `HttpClient` (Apache, OkHttp, JDK) configurations
- `Feign` client configurations

### Build / Container

- `pom.xml` Spring Boot parent version
- `Dockerfile` base image version

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find forward headers | `rg -n "forward-headers-strategy" src` |
| Find secure cookies | `rg -n "cookie\.secure\|\.cookie\(" src` |
| Find body limits | `rg -n "max-http-form-post-size\|max-file-size\|max-request-size" src` |
| Find RestTemplate | `rg -n "RestTemplate\|RestTemplateBuilder" src` |
| Find WebClient | `rg -n "WebClient\|WebClient\.Builder" src` |
| Find timeouts | `rg -n "connectTimeout\|readTimeout\|responseTimeout\|setConnectTimeout\|setReadTimeout" src` |
| Find channel sec | `rg -n "requiresChannel\|requiresSecure" src` |
| Find mixed content | `rg -n "http://" src` (within URL builders / redirect logic) |
| Find Boot version | `rg -n "spring-boot-starter-parent" pom.xml` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| MTD02 | Application does not run behind a reverse proxy (documented). |
| MTD03 | Already covered by `clickjacking_headers_reviewer` HDR05 in this project. |
| MTD05 | Application is stateless (no sessions or cookies). |
| MTD06 | Application accepts no request bodies. |
| MTD07 | Application makes no outbound HTTP calls. |

---

## 5. CHECK-ID Scoring Procedure

### MTD01 - HTTPS End-to-End
Fail when the application does not enforce HTTPS for authenticated endpoints, or generates `http://` redirect URLs when behind a TLS-terminating proxy.

### MTD02 - Forward-Headers-Strategy Configured
Fail when the application runs behind a reverse proxy (Docker/Kubernetes deployment) but does not set `server.forward-headers-strategy=framework`, causing `HttpServletRequest.getScheme()` to return `http` instead of `https`.

### MTD03 - HSTS Enforcement
Fail when neither the Spring Security headers configuration nor the documented edge infrastructure sets `Strict-Transport-Security`.

### MTD04 - Patching Cadence
Fail when the Spring Boot parent version is more than 2 minor releases behind the current stable release.

### MTD05 - Secure Proxy Behaviour
Fail when session cookies lack the `Secure` flag (`server.servlet.session.cookie.secure` is absent/false), or the application constructs URLs using `http://` after TLS termination at the proxy.

### MTD06 - Request Body Size Limits
Fail when `server.tomcat.max-http-form-post-size`, `spring.servlet.multipart.max-file-size`, or `spring.servlet.multipart.max-request-size` are unconfigured, relying on permissive defaults that allow large payloads.

### MTD07 - Outbound Client Timeouts
Fail when `RestTemplate`, `WebClient`, or HTTP client beans are created without explicit `connectTimeout` and `readTimeout` (or `responseTimeout`) values.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:
- TLS termination is managed by an external Nginx, HAProxy, or cloud load balancer whose configuration is not in the repository.
- Patching cadence is managed by a platform team and cannot be verified statically.

---

## 7. Report Requirements

Every scored finding must include: File, Evidence, Policy Rule, Possible Attack Scenario, and five Resolution rows.

### 7.1 Verify Row Rules

Every Verify row must include: Action + pass signal.

---

## 8. Secure Resolution Catalog

Use one row set per finding.

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| MTD01 | Channel security | Configure `http.requiresChannel().anyRequest().requiresSecure()` or document TLS at edge | Passwords and session cookies are never transmitted in clear text | HTTP for authenticated paths | Attempt HTTP access; confirm redirect to HTTPS |
| MTD02 | Forward headers | Set `server.forward-headers-strategy=framework` in properties | Scheme, remote IP, and host are correctly derived from proxy headers | Missing forward-headers strategy | Call endpoint behind proxy; confirm `request.getScheme()` returns `https` |
| MTD03 | HSTS header | Configure `headers.httpStrictTransportSecurity()` or document edge HSTS | Browsers never downgrade to HTTP after first visit | No HSTS header | Inspect response headers; confirm `Strict-Transport-Security` present |
| MTD04 | Version upgrade | Update Spring Boot parent POM to the latest stable release | Known vulnerabilities from stale dependencies are resolved | Outdated parent version | Run `mvn versions:display-property-updates`; confirm Boot is current |
| MTD05 | Secure cookies | Set `server.servlet.session.cookie.secure=true` and audit URL generation | Session cookies are not sent over HTTP; no mixed-content links | Insecure cookies behind proxy | Inspect `Set-Cookie` header; confirm `Secure` flag present |
| MTD06 | Body limits | Configure `max-http-form-post-size`, `max-file-size`, and `max-request-size` | Oversized payloads are rejected with 413 before memory exhaustion | Unconfigured body limits | POST a 100 MB payload; confirm 413 Payload Too Large |
| MTD07 | Client timeouts | Configure `RestTemplateBuilder.setConnectTimeout()` and `setReadTimeout()` | Dead upstreams cannot exhaust the thread pool | HTTP clients without timeouts | Simulate dead upstream; confirm request fails within timeout period |

---

## 9. Scoring Formula

Base Score: 100
Critical: -20, High: -10, Medium: -5, Low: -2, Info: 0
Floor: 0

---

## 10. Final Self-Validation

Before finalizing a report:
- Confirm stack gate result.
- Confirm every failed CHECK-ID has 5 resolution rows.
- Confirm missing outbound timeouts (MTD07) is Critical.
- Confirm HTTPS not enforced (MTD01) is Critical.
