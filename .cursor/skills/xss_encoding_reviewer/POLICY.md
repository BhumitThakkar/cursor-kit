# XSS & Output Encoding Security Policy v2.0 STRICT
# Spring Boot Servlet MVC and REST Applications

**Mode:** STRICT. Fixed severity per CHECK-ID. No profile-based severity reduction.

Every finding must cite one row from Appendix A:
`POLICY.md - {CHECK-ID} - {citation string}`

| Artifact | Path |
|---|---|
| Scan procedure | `SKILL.md` |
| Workflow + report | `.cursor/agents/xss_encoding_reviewer.md` |
| Cursor invoke name | `xss_encoding_reviewer` |
| Report path | `AI/xss_encoding_reviewer/xss_encoding_reviewer_report.md` |
| Report reviewer line | `xss_encoding_reviewer v2.0 STRICT` |

---

## Verdict Vocabulary

**PASS**, **FAIL**, **MANUAL_REVIEW**, **N/A** only.

---

## Resolution Requirement

Five Resolution rows per finding. Only Evidence may quote source. See **SKILL.md §9–10**.

---

## Rich-text allow-list (XSS02 exception)

Default: **`th:text`** for all dynamic fields. Record in Scope Notes **only** when `th:utext` is required:

```text
XSS02 rich-text allow-list:
  Allowed tags: p, br, strong, em, b, i, ul, ol, li, a
  Allowed link scheme: https only
  Forbidden: script, iframe, object, embed, svg, style, link, meta, form, input, button, img, video, audio, on* handlers, style attribute, javascript/data/vbscript URLs
  Sanitize: server-side allow-list strip at save/update before persistence
  Render: th:utext only after save-boundary sanitization
```

Pass `th:utext` on dynamic data only when all three: Scope Notes block (field + template), save-path sanitization cited, XSS26 trace satisfied if applicable.

---

## Data-flow trace (XSS20, XSS26)

Procedure: **SKILL.md §2.3**. Fail only at **HIGH** trace confidence.

---

## Scope N/A

| Condition | N/A checks |
|---|---|
| No `templates/**/*.html` | XSS02, XSS17–XSS22, XSS26 |
| No JS / inline scripts | XSS04, XSS10–XSS16, XSS20 |
| No `@ResponseBody` HTML | XSS23–XSS25 |

---

## Mandatory Policy Rules

### Critical

| ID | Citation | Condition |
|---|---|---|
| XSS02 | Safe Thymeleaf output | `th:utext` with dynamic data without § rich-text allow-list and save-boundary sanitization |
| XSS04 | No innerHTML assignment | `.innerHTML =` or `.innerHTML+=` with untrusted or API data |
| XSS07 | No raw reflection in errors/search | Raw user input in HTML error/search output without encoding |
| XSS08 | Safe inline script encoding | Raw JSON/user data in `<script>` without safe Thymeleaf JS inlining |

### High

| ID | Citation | Condition |
|---|---|---|
| XSS01 | Context-appropriate encoding | Manual concat into HTML/JS/URL without contextual encoding |
| XSS03 | Correct JSON content types | JSON endpoints missing `application/json` |
| XSS05 | Rich text sanitization | Rich HTML accepted without documented server-side allow-list sanitizer |
| XSS06 | UTF-8 and canonicalization | Missing UTF-8 force or encoding bypass risk |
| XSS09 | JSON property HTML escaping | Jackson strings not HTML-escaped for browser-consumed JSON |
| XSS10 | No outerHTML assignment | `.outerHTML =` with untrusted data |
| XSS11 | No insertAdjacentHTML | `.insertAdjacentHTML(` with untrusted data |
| XSS12 | No document.write | `document.write(` / `document.writeln(` |
| XSS13 | No eval or Function | `eval(`, `new Function(`, string `setImmediate` |
| XSS14 | No string setTimeout | `setTimeout("` / `setInterval("` string first argument |
| XSS15 | No URL to DOM sink | URL-derived value reaches HTML sink (HIGH same-file trace) |
| XSS16 | No jQuery HTML insertion | jQuery `.html()`, `.append(string)`, etc. parsing HTML |
| XSS17 | No dynamic th:href | Non-literal `th:href` without protocol allow-list |
| XSS18 | No dynamic th:src | Non-literal `th:src` on loadable elements without validation |
| XSS19 | No inline event handlers | Dynamic `th:on*` or inline handlers |
| XSS20 | No JSON in script blocks | Non-literal JSON injected into `<script>` |
| XSS23 | No HTML in ResponseBody | `@ResponseBody` / `ResponseEntity<String>` returning HTML |
| XSS24 | No HTML string concatenation | Server-side HTML string concat in controllers |
| XSS25 | No direct response write | `getWriter().write(...)` with dynamic unescaped content |
| XSS26 | No model to th:utext trace | Same attribute name in Java model and `th:utext` (HIGH trace) |

### Medium

| ID | Citation | Condition |
|---|---|---|
| XSS21 | Use th:action | POST form with plain `action=` instead of `th:action` |
| XSS22 | No dynamic fragment selector | Dynamic `th:replace` / `th:insert` fragment name |

---

## Appendix A - Master CHECK-ID Index

| ID | Domain | Sev | Citation string |
|---|---|---|---|
| XSS01 | Output Encoding | High | Context-appropriate encoding |
| XSS02 | Output Encoding | Critical | Safe Thymeleaf output |
| XSS03 | Output Encoding | High | Correct JSON content types |
| XSS04 | Output Encoding | Critical | No innerHTML assignment |
| XSS05 | Output Encoding | High | Rich text sanitization |
| XSS06 | Output Encoding | High | UTF-8 and canonicalization |
| XSS07 | Output Encoding | Critical | No raw reflection in errors/search |
| XSS08 | Output Encoding | Critical | Safe inline script encoding |
| XSS09 | Output Encoding | High | JSON property HTML escaping |
| XSS10 | DOM | High | No outerHTML assignment |
| XSS11 | DOM | High | No insertAdjacentHTML |
| XSS12 | DOM | High | No document.write |
| XSS13 | DOM | High | No eval or Function |
| XSS14 | DOM | High | No string setTimeout |
| XSS15 | DOM | High | No URL to DOM sink |
| XSS16 | DOM | High | No jQuery HTML insertion |
| XSS17 | Thymeleaf | High | No dynamic th:href |
| XSS18 | Thymeleaf | High | No dynamic th:src |
| XSS19 | Thymeleaf | High | No inline event handlers |
| XSS20 | Thymeleaf | High | No JSON in script blocks |
| XSS21 | Thymeleaf | Medium | Use th:action |
| XSS22 | Thymeleaf | Medium | No dynamic fragment selector |
| XSS23 | Response | High | No HTML in ResponseBody |
| XSS24 | Response | High | No HTML string concatenation |
| XSS25 | Response | High | No direct response write |
| XSS26 | Response | High | No model to th:utext trace |
