---
name: clickjacking_headers_reviewer
version: 2.1
disable-model-invocation: true
---

# Clickjacking & Headers Security Reviewer - Scan Skill v2.1 STRICT

| Report line | `clickjacking_headers_reviewer v2.1 STRICT` |
| Fleet position line | `#12 — Phase 4 (Browser & transport)` |

**HDR06** owns Cache-Control on authenticated HTML. For errors, static leaks, logs → **`disclosure_reviewer` v2.0**.

**v2.1 change:** `style-src` is scored like `script-src` (HDR15–HDR16). `'unsafe-inline'` in `style-src` alone is **FAIL**, even when `script-src` is strict. Aligns with OWASP ZAP alert 10055.

---

## 1. Stack Gate

Spring Boot servlet MVC or REST serving HTML or requiring explicit security headers in `SecurityFilterChain`.

---

## 2. Discovery

`SecurityFilterChain` `headers()` blocks, custom filters, templates with meta CSP, JS frame busting, **inline `style=` attributes**, CSP `style-src` directives.

---

## 3. Probes

| Goal | Probe |
|---|---|
| Headers | `rg -n "headers\(\)\|contentSecurityPolicy\|frameOptions\|httpStrictTransportSecurity" src` |
| defaultsDisabled | `rg -n "defaultsDisabled\(\)" src` |
| unsafe script CSP | `rg -n "script-src[^;]*unsafe-inline\|script-src[^;]*unsafe-eval\|unsafe-inline[^;]*script-src\|unsafe-eval[^;]*script-src" src` |
| unsafe style CSP | `rg -n "style-src[^;]*unsafe-inline\|style-src[^;]*unsafe-eval\|unsafe-inline[^;]*style-src\|unsafe-eval[^;]*style-src" src` |
| inline style attrs | `rg -n "\\bstyle=" src/main/resources/templates src/main/resources/static` |
| meta CSP | `rg -n "<meta http-equiv=\"Content-Security-Policy\"" templates` |

**HDR15/HDR16 rule:** If `style-src` contains `'unsafe-inline'` **or** any reviewed template/JS HTML sink contains `style=`, fail the corresponding CHECK-ID. Do not treat `style-src` unsafe directives as acceptable tradeoffs when `script-src` is strict.

---

## 4. CHECK-ID Procedures

**HDR01:** Fail without explicit `frameOptions` deny/sameOrigin **or** CSP `frame-ancestors` in enforcing header.

**HDR07:** Fail if HSTS absent, `maxAge=0`, or disabled.

**HDR08:** Fail if no CSP in reviewed chain.

**HDR09:** Fail on `defaultsDisabled()` without re-enabling HDR01/HDR07/HDR08/HDR10 equivalents.

**HDR10–HDR13:** Explicit nosniff, strict script-src, no wildcard script-src, Referrer-Policy.

**HDR14:** Info only when `X-XSS-Protection: 0` explicitly set.

**HDR15:** Fail if `unsafe-inline` or `unsafe-eval` appears in `style-src` of any enforcing UI CSP string or header builder.

**HDR16:** Fail if `style=` appears in `src/main/resources/templates/**/*.html` or in JS that builds HTML inserted into the DOM (e.g. `innerHTML`, template literals served to UI pages), unless the project documents a nonce/hash CSP for styles in Scope Notes **and** every inline style uses that mechanism (otherwise MANUAL_REVIEW only when evidence is incomplete).

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
| HDR08 | CSP present | contentSecurityPolicy on security headers | Restrictive default/script-src/style-src | No CSP in chain | Content-Security-Policy header on HTML |
| HDR09 | Guarded defaultsDisabled | Re-enable each header after defaultsDisabled | No silent loss | defaultsDisabled alone | Frame, nosniff, HSTS, CSP all configured |
| HDR10 | nosniff explicit | contentTypeOptions with noSniff | MIME sniffing disabled | Missing nosniff | X-Content-Type-Options: nosniff |
| HDR11 | Strict script-src | CSP without unsafe-inline/eval in script-src | No inline/eval scripts | unsafe-inline in script-src | script-src has neither unsafe directive |
| HDR12 | No wildcard script-src | Named sources in script-src | No * script sources | script-src * | script-src lists named sources only |
| HDR13 | Referrer policy | referrerPolicy in headers | Referrer leakage limited | Missing Referrer-Policy | Referrer-Policy header present |
| HDR14 | No legacy XSS header | Omit deprecated X-XSS-Protection | Do not disable to zero | X-XSS-Protection: 0 | Header absent or not zero |
| HDR15 | Strict style-src | Remove unsafe-inline/eval from style-src; use external CSS | Style injection surface reduced | unsafe-inline in style-src | style-src has neither unsafe directive; ZAP 10055 clear |
| HDR16 | CSS classes not style= | Move template/JS inline styles to stylesheet classes | CSP can omit style unsafe-inline | Inline style attributes | rg style= on templates/static is empty or nonce/hash documented |

---


## Report Requirements

Every scored finding must include: File, Evidence, Policy Rule, Possible Attack Scenario, `#### Picture in your head`, and five Resolution rows.

**Picture in your head (mandatory):** Concrete mental model / analogy / before-after story a non-expert can picture. Prefer ending with **In even simpler terms...** or **Here's a practical example:**. Place after Evidence / Policy Rule / Possible Attack Scenario and before Resolution rows. See `SCORING_REVIEWER_AGENT_MECHANISM.md`.

Manual Review CHECK-ID explanations also require `#### Picture in your head`.
## 6. Scoring

Base 100 · Critical −20 · High −10 · Medium −5 · Low −2 · Info 0

---

## 7. DAST cross-check (optional, not a separate CHECK-ID)

When a ZAP HTML/JSON report exists under `AI/agents/security_reviewers/security_testing_reviewer/` or CI artefacts, cite alert **10055** (CSP style-src unsafe-inline) under HDR15 Evidence if it matches static findings.

