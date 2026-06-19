---
name: clickjacking_headers_reviewer
version: 2.0
disable-model-invocation: true
---

# Clickjacking & Headers Security Reviewer - Scan Skill v2.0 STRICT

| Report line | `clickjacking_headers_reviewer v2.0 STRICT` |

**HDR06** owns Cache-Control on authenticated HTML. For errors, static leaks, logs → **`disclosure_reviewer` v2.0**.

---

## 1. Stack Gate

Spring Boot servlet MVC or REST serving HTML or requiring explicit security headers in `SecurityFilterChain`.

---

## 2. Discovery

`SecurityFilterChain` `headers()` blocks, custom filters, templates with meta CSP, JS frame busting.

---

## 3. Probes

| Goal | Probe |
|---|---|
| Headers | `rg -n "headers\(\)\|contentSecurityPolicy\|frameOptions\|httpStrictTransportSecurity" src` |
| defaultsDisabled | `rg -n "defaultsDisabled\(\)" src` |
| unsafe CSP | `rg -n "unsafe-inline\|unsafe-eval" src` |
| meta CSP | `rg -n "<meta http-equiv=\"Content-Security-Policy\"" templates` |

---

## 4. CHECK-ID Procedures

**HDR01:** Fail without explicit `frameOptions` deny/sameOrigin **or** CSP `frame-ancestors` in enforcing header.

**HDR07:** Fail if HSTS absent, `maxAge=0`, or disabled.

**HDR08:** Fail if no CSP in reviewed chain.

**HDR09:** Fail on `defaultsDisabled()` without re-enabling HDR01/HDR07/HDR08/HDR10 equivalents.

**HDR10–HDR13:** Explicit nosniff, strict script-src, no wildcard script-src, Referrer-Policy.

**HDR14:** Info only when `X-XSS-Protection: 0` explicitly set.

---

## 5. Resolution Catalog

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| HDR01 | Frame denial | frameOptions deny/sameOrigin or CSP frame-ancestors | Page not frameable | Missing frame protection | X-Frame-Options or frame-ancestors present |
| HDR02 | Header only | Move frame policy to HTTP header | Browser enforces policy | Meta tag frame-ancestors | No meta CSP for framing |
| HDR03 | Enforce mode | Policy in enforcing CSP header | Blocks framing | Report-Only framing | Enforcing CSP present |
| HDR04 | Header defense | CSP + frameOptions; JS only as depth | Bypass-resistant | JS-only frame busting | Browser blocks iframe without JS |
| HDR05 | Enable headers | Remove headers.disable or configure explicitly | Baseline protections active | headers.disable() | nosniff and HSTS present |
| HDR06 | No-cache auth | cacheControl for sensitive pages | History does not retain data | Disabled cache control | Back button does not show sensitive page |
| HDR07 | HSTS enabled | httpStrictTransportSecurity long max-age + includeSubDomains | HTTPS enforced | HSTS absent or max-age zero | Strict-Transport-Security with max-age > 0 |
| HDR08 | CSP present | contentSecurityPolicy on security headers | Restrictive default/script-src | No CSP in chain | Content-Security-Policy header on HTML |
| HDR09 | Guarded defaultsDisabled | Re-enable each header after defaultsDisabled | No silent loss | defaultsDisabled alone | Frame, nosniff, HSTS, CSP all configured |
| HDR10 | nosniff explicit | contentTypeOptions with noSniff | MIME sniffing disabled | Missing nosniff | X-Content-Type-Options: nosniff |
| HDR11 | Strict script-src | CSP without unsafe-inline/eval | No inline/eval scripts | unsafe-inline in script-src | script-src has neither unsafe directive |
| HDR12 | No wildcard script-src | Named sources in script-src | No * script sources | script-src * | script-src lists named sources only |
| HDR13 | Referrer policy | referrerPolicy in headers | Referrer leakage limited | Missing Referrer-Policy | Referrer-Policy header present |
| HDR14 | No legacy XSS header | Omit deprecated X-XSS-Protection | Do not disable to zero | X-XSS-Protection: 0 | Header absent or not zero |

---

## 6. Scoring

Base 100 · Critical −20 · High −10 · Medium −5 · Low −2 · Info 0
