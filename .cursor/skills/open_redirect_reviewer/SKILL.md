---
name: open_redirect_reviewer
version: 1.0
disable-model-invocation: true
---

# Open Redirect Security Reviewer - Scan Skill v1.0 STRICT

**Mode:** STRICT. Fixed severity per CHECK-ID in `POLICY.md`. All environments use the same security bar.

## 0. Naming Convention

| Artifact | Canonical value |
|---|---|
| Agent file | `.cursor/agents/open_redirect_reviewer.md` |
| Skill directory | `.cursor/skills/open_redirect_reviewer/` |
| Cursor invoke name | `open_redirect_reviewer` |
| Report path | `AI/open_redirect_reviewer/open_redirect_reviewer_report.md` |
| Report reviewer line | `open_redirect_reviewer v1.0 STRICT` |

---

## 1. Supported Technology Stack

This reviewer applies to Spring Boot servlet MVC or REST applications handling HTTP redirects, OAuth/OIDC flows, or URL-based state parameters.

| Required signal | Evidence |
|---|---|
| Spring Boot | `spring-boot` dependency, application class, or Boot plugin |
| Redirect surface | `return "redirect:..."`, `RedirectView`, `sendRedirect()`, OAuth configurations |

### 1.1 Out of Scope

Stop scored audit and write out-of-scope report when:

| Signal | Report as technology |
|---|---|
| Not Spring Boot | Detected framework |
| Pure DB/Batch | CLI application |

Mandatory report wording:

```text
Project "{PROJECT_NAME}" is out of scope for open_redirect_reviewer because it uses {TECHNOLOGY}, which is not a Spring Boot servlet MVC or REST application that issues HTTP redirects or OAuth flows.
```

---

## 2. File Discovery

Scan in this order.

### Controllers & Views

- Methods returning `String` starting with `"redirect:"`
- Methods returning `RedirectView` or `ModelAndView`
- Direct use of `HttpServletResponse.sendRedirect()`
- Request parameters matching `next`, `returnTo`, `redirect_uri`, `continue`, `url`

### Security Configuration

- `AuthenticationSuccessHandler` implementations
- `defaultSuccessUrl()` usage in Spring Security
- OAuth2/OIDC client configurations

---

## 3. Required Search Probes

Use these probes as starting points. Add project-specific searches when needed.

| Goal | Probe |
|---|---|
| Find redirects | `rg -n "return \"redirect:\|new RedirectView\|sendRedirect\|setHeader\(\"Location\"" src` |
| Find redirect params | `rg -n "@RequestParam.*(next\|return\|redirect\|url)" src` |
| Find success handlers | `rg -n "defaultSuccessUrl\|AuthenticationSuccessHandler\|SavedRequestAwareAuthenticationSuccessHandler" src` |
| Find OAuth matching | `rg -n "redirect_uri\|redirect-uri-template" src` |
| Find URL parsing | `rg -n "new URI\(\|new URL\(\|URI\.create" src` |

Record probes and meaningful results in Scope Notes.

---

## 4. Scope N/A Rules

Use N/A only with proof.

| Check | N/A allowed only when |
|---|---|
| RED01-RED03 | Application does not perform any HTTP redirects based on user input. |
| RED04 | Application does not implement OAuth/OIDC flows. |
| RED05 | Application never writes dynamic user input into response headers. |

---

## 5. CHECK-ID Scoring Procedure

### RED01 - Redirect Allow-list
Fail when dynamic redirects are accepted without validation against a strict, documented allow-list of relative paths or known domains.

### RED02 - No Unvalidated Redirect Inputs
Fail when client input (like `next` parameter) is directly concatenated into a redirect command (`return "redirect:" + next;`).

### RED03 - Strict URL Canonicalization
Fail when custom redirect validation uses simple string `startsWith` or regexes that fail to canonicalize URLs (e.g., vulnerable to `//evil.com`, `http://trusted.com@evil.com`, or `\evil.com`).

### RED04 - Exact OAuth redirect_uri
Fail when OAuth `redirect_uri` configurations use prefixes, wildcards, or regex matching instead of exact registered URIs.

### RED05 - No CRLF in Redirects
Fail when redirect URLs or custom headers are constructed from user input without sanitizing CRLF (`\r\n`) characters.

---

## 6. Manual Review Triggers

Create MANUAL_REVIEW items when:
- Redirect URIs are managed in an external IAM/IdP configuration not present in the repository.

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
| RED01 | Target allow-list | Implement a helper that checks input against a `Set<String>` of allowed endpoints | The server only redirects to explicitly trusted destinations | Accepting arbitrary redirect targets | Attempt redirect to unlisted local path; confirm rejection |
| RED02 | Fixed destination lookup | Use input as a map key to look up safe targets, rather than the raw URL | Client input cannot directly control the HTTP Location | Unvalidated `redirect:` concatenation | Pass `https://evil.com` as next parameter; confirm application ignores it |
| RED03 | URL canonicalization | Parse input using `java.net.URI` to safely extract scheme and host before validation | Bypass tricks (userinfo, backslash, encoded) are defeated | Simple string matching on URLs | Submit `//evil.com` and `http://trusted@evil.com`; confirm rejection |
| RED04 | Exact URI matching | Configure OAuth providers to use strict exact string matching for redirect URIs | Attackers cannot steal auth codes via open redirect | Wildcards in `redirect_uri` config | Authenticate with OAuth using an unregistered URI suffix; confirm IdP rejects |
| RED05 | CRLF sanitization | Strip `\r` and `\n` characters before writing to headers, or use framework methods | HTTP response splitting is impossible | Raw input in header APIs | Submit payload containing `%0d%0aSet-Cookie`; confirm headers are not split |

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
- Confirm trusting unvalidated `next` param (RED02) is Critical.
