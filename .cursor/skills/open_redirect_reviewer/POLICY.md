# Open Redirect Security Policy v1.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/open_redirect_reviewer.md` |
| Cursor invoke name | `open_redirect_reviewer` |
| Report path | `AI/open_redirect_reviewer/open_redirect_reviewer_report.md` |
| Report reviewer line | `open_redirect_reviewer v1.0 STRICT` |

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
| RED02 | No unvalidated redirect inputs | Application uses unvalidated user input (like `next`, `returnUrl`) directly in a `redirect:` prefix, `RedirectView`, or `sendRedirect()` call |
| RED04 | Exact OAuth redirect_uri | Application acts as an OAuth/OIDC client or provider but matches `redirect_uri` using prefixes or wildcards instead of exact registered URI matching |

### High

| ID | Citation | Condition |
|---|---|---|
| RED01 | Redirect allow-list | Application accepts dynamic redirect targets from user input but does not restrict them to a strict allow-list of relative paths or known hostnames |
| RED03 | Strict URL canonicalization | Application attempts to validate redirects but fails to canonicalize the URL first, allowing bypasses via `//evil.com`, `\evil.com`, encoded chars, userinfo (`http://trusted@evil.com`), or mixed-case schemes |
| RED05 | No CRLF in redirects | Application reflects unvalidated user input into the `Location` header, allowing CRLF (`\r\n`) injection to split the HTTP response |

---

## Pass Criteria

| ID | PASS requires |
|---|---|
| RED01 | Dynamic redirects are strictly mapped against a server-side allow-list. |
| RED02 | `redirect:` prefix or `RedirectView` uses hardcoded strings or values derived safely from a server-side lookup, never raw client input. |
| RED03 | Redirect validation logic explicitly canonicalizes URLs (using `java.net.URI` or `java.net.URL`), resolving encoded characters and rejecting schema tricks before applying the allow-list. |
| RED04 | OAuth2 configuration enforces strict, exact string matching for `redirect_uri`. |
| RED05 | Any input used in HTTP headers is validated/sanitized to strictly prohibit carriage return (`%0d`) and line feed (`%0a`) characters. |

---

## N/A Criteria

| ID | N/A allowed only when |
|---|---|
| RED01-RED03 | Application does not perform any HTTP redirects based on user input or state parameters. |
| RED04 | Application does not implement OAuth/OIDC flows. |
| RED05 | Application never writes dynamic user input into response headers. |

---

## Manual Review Criteria

Use MANUAL_REVIEW when static evidence cannot prove Pass or Fail, including:

- URL validation delegates to an external library or API whose strictness cannot be statically proven.
- `redirect_uri` validation occurs at an external Identity Provider (Auth0, Keycloak) where the configuration is not in the repository.

Manual review is not Pass.

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| RED01 | Redirects | High | Redirect allow-list |
| RED02 | Redirects | Critical | No unvalidated redirect inputs |
| RED03 | Redirects | High | Strict URL canonicalization |
| RED04 | Redirects | Critical | Exact OAuth redirect_uri |
| RED05 | Redirects | High | No CRLF in redirects |
