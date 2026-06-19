# SSRF & Outbound Request Security Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction. Permitting `file://` or loopback/metadata IP access via user input is always a finding.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/ssrf_reviewer.md` |
| Cursor invoke name | `ssrf_reviewer` |
| Report path | `AI/ssrf_reviewer/ssrf_reviewer_report.md` |
| Report reviewer line | `ssrf_reviewer v1.0 STRICT` |

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
| SRF02 | Block internal IP ranges | Application resolves dynamic URLs but fails to block private (`10.0.0.0/8`, `192.168.0.0/16`, `172.16.0.0/12`), loopback (`127.0.0.0/8`), and cloud metadata (`169.254.169.254`) IP ranges after DNS resolution |
| SRF04 | Block non-HTTP schemes | Application accepts user-controlled URLs but does not strictly validate that the scheme is `http` or `https`, permitting `file:`, `gopher:`, `ftp:`, `jar:`, etc. |
| SRF06 | Prevent header forwarding | Application blindly forwards incoming headers (`Authorization`, `Cookie`) from the user to arbitrary outbound third-party URLs |

### High

| ID | Citation | Condition |
|---|---|---|
| SRF01 | URL allow-list | Application accepts fully user-controlled raw URLs for outbound fetching instead of mapping business identifiers to an explicit allow-list of safe schemes, hosts, and ports |
| SRF03 | Safe redirect handling | HTTP client is configured to follow redirects automatically without re-validating the final destination IP against the internal/metadata blocklist, risking DNS rebinding or redirect bypasses |
| SRF05 | Outbound limits and timeouts | Outbound client fetching dynamic URLs lacks strict connect/read timeouts or a bounded response-body size limit, enabling DoS via tarpit or massive file download |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| SRF01 | Outbound targets are derived from predefined maps/enums, or user-supplied URLs are strictly verified against an explicit host allow-list. |
| SRF02 | Custom DNS resolution intercepts the request, checks the resolved IP against a strict denylist (RFC 1918, RFC 3927, loopback), and blocks if matched. |
| SRF03 | Auto-redirects are disabled (redirects handled manually with IP re-validation), or the underlying client guarantees redirects cannot cross into private IP space. |
| SRF04 | The URL string is parsed (e.g., `java.net.URI`) and `getScheme()` is strictly verified as equal to `http` or `https`. |
| SRF05 | The HTTP client explicitly sets connect timeouts (≤10s), read timeouts, and bounds the stream reading to a safe max byte size. |
| SRF06 | Outbound requests construct a fresh set of safe headers and explicitly do not copy the user's `Authorization` or session cookies. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| SRF01-SRF06 | Application makes zero outbound network requests based on user input, parameters, database records modified by users, or headers. |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- Egress traffic filtering is allegedly handled by an external network firewall or proxy (e.g., Istio egress gateway) that cannot be verified in the source code.
- A custom DNS resolver is used for SSRF protection but its implementation logic is in a pre-compiled library.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| SRF01 | SSRF | High | URL allow-list |
| SRF02 | SSRF | Critical | Block internal IP ranges |
| SRF03 | SSRF | High | Safe redirect handling |
| SRF04 | SSRF | Critical | Block non-HTTP schemes |
| SRF05 | DoS | High | Outbound limits and timeouts |
| SRF06 | Disclosure | Critical | Prevent header forwarding |
