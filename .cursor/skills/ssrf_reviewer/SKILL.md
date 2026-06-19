---
name: ssrf_reviewer
version: 1.0
disable-model-invocation: true
---

# SSRF & Outbound Request Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/ssrf_reviewer.md` |
| Skill directory | `.cursor/skills/ssrf_reviewer/` |
| Cursor invoke name | `ssrf_reviewer` |
| Report path | `AI/ssrf_reviewer/ssrf_reviewer_report.md` |
| Report reviewer line | `ssrf_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications that make outbound network requests based on user influence.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |
| Outbound I/O | `RestTemplate`, `WebClient`, `HttpClient`, `URL.openConnection`, webhooks |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| No outbound I/O | Application with no network clients |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for ssrf_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet application making dynamic outbound requests.
```

---

## 2. File Discovery

Scan in this order.

### Controllers and Services

- Services implementing webhook dispatchers
- Endpoints fetching avatars, PDFs, or proxying requests
- Services consuming URLs from database records modified by users

### HTTP Clients

- Configurations for `RestTemplate`, `WebClient`
- Uses of `java.net.URL`, `java.net.HttpURLConnection`
- Uses of Apache `HttpClient` or OkHttp

### Validation Logic

- Classes handling URI parsing and URL validation
- Custom DNS resolvers or SSRF protection wrappers

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find outbound clients | `rg -n "RestTemplate\|WebClient\|HttpClient\|openConnection" src` |
| Find user URLs | `rg -n "url=\|webhook\|callback\|fetch" src` |
| Find scheme validation | `rg -n "getScheme\|startsWith\(\"http" src` |
| Find IP validation | `rg -n "127\.0\.0\.1\|169\.254\|InetAddress" src` |
| Find redirect config | `rg -n "setInstanceFollowRedirects\|followRedirects" src` |
| Find header forwarding | `rg -n "getHeaders\(\)\.forEach\|putAll\(.*headers\)" src` |
| Find timeouts | `rg -n "Timeout" src` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| SRF01-SRF06 | Application makes zero outbound requests, or all outbound requests use strictly hardcoded URLs from properties files that users cannot influence. |

---

## 5. CHECK-ID Scoring Procedure

### SRF01 - URL Allow-list
Fail when a controller accepts a URL string parameter and passes it directly to an HTTP client without validating it against a strict whitelist of domains or mapping it from an internal ID.

### SRF02 - Block Internal IP Ranges
Fail when the application accepts dynamic URLs but does not perform DNS resolution to verify the resulting IP is public, leaving `localhost`, `169.254.169.254`, and `10.x.x.x` exposed.

### SRF03 - Safe Redirect Handling
Fail when the HTTP client auto-follows redirects (the default in many clients) without a mechanism to re-validate the target IP, allowing an attacker to bypass domain allow-lists by redirecting to `127.0.0.1`.

### SRF04 - Block Non-HTTP Schemes
Fail when the application does not strictly assert that the URL scheme is `http` or `https`, making it possible to pass `file:///etc/passwd` to a URL fetcher.

### SRF05 - Outbound Limits and Timeouts
Fail when dynamic fetches lack connection/read timeouts or read unbounded streams directly into memory.

### SRF06 - Prevent Header Forwarding
Fail when a proxy endpoint iterates over incoming `HttpServletRequest` headers and blindly adds them to the outbound request, potentially leaking the `Authorization` bearer token to an attacker's server.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:
- Egress is locked down by Kubernetes NetworkPolicies or Istio egress gateways which are not defined in the source repo.

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
| SRF01 | Indirect reference | Accept an enum or ID (e.g., `?provider=GITHUB`) and map it to a hardcoded base URL | Attackers cannot specify arbitrary destinations | Raw URL parameters | Submit `?url=evil.com`; confirm 400 Bad Request |
| SRF02 | IP Denylist | Resolve DNS, check against `10.0.0.0/8`, `127.0.0.0/8`, `169.254.0.0/16`, then connect | Internal network and cloud metadata are shielded | Fetching private IPs | Submit `http://169.254.169.254/`; confirm 403 Forbidden |
| SRF03 | Disable auto-redirect | Disable auto-redirects; handle 3xx manually by parsing `Location` and re-running the SSRF IP checks | DNS rebinding and redirect bypasses fail | Blindly following redirects | Fetch URL that redirects to `127.0.0.1`; confirm rejection |
| SRF04 | Scheme assert | Parse `URI`, call `getScheme()`, and ensure it equals `http` or `https` | Local filesystem and legacy protocols are unreachable | `file://` or `gopher://` schemes | Submit `file:///etc/passwd`; confirm 400 Bad Request |
| SRF05 | Timeouts & Bounds | Configure client timeouts; read streams with a byte counter that throws if exceeded | Tarpits and massive files cannot exhaust resources | Unbounded streams | Fetch a 10GB endpoint; confirm safe abort |
| SRF06 | Header allow-list | Explicitly copy only safe headers (e.g., `Accept`, `Content-Type`); drop `Authorization` | Sensitive credentials are not leaked to external sites | Blind header forwarding | Send proxy request with fake Auth token; confirm token is not forwarded |

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
- Confirm missing internal IP checks (SRF02) is Critical.
- Confirm non-HTTP schemes (SRF04) is Critical.
