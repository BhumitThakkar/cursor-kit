---
name: xss_encoding_reviewer
version: 2.0
disable-model-invocation: true
---

# XSS & Output Encoding Security Reviewer - Scan Skill v2.0 STRICT

## 0. Naming

| Report line | `xss_encoding_reviewer v2.0 STRICT` |
| Report path | `AI/xss_encoding_reviewer/xss_encoding_reviewer_report.md` |

---

## 1. Stack Gate

Spring Boot servlet MVC or REST returning HTML (Thymeleaf) and/or JSON consumed by browser JS.

Out of scope → mandatory wording naming `{TECHNOLOGY}`; no CHECK-IDs scored.

---

## 2. File Discovery

Java controllers, `@ControllerAdvice`, templates, `static/**/*.js`, inline `<script>`, sanitizers, `application*.yml` charset, Jackson config.

### 2.1 XSS02 rich-text allow-list

See **POLICY.md** block. Default `th:text` only.

### 2.2 Trace confidence (XSS15, XSS26)

| Level | Rule |
|---|---|
| HIGH | Procedure complete; chain in Evidence |
| LOW | Do not Fail; log in Scope Notes |

#### XSS15 — URL to DOM sink (same file)

1. Grep `location.hash`, `location.search`, `document.URL`, `URLSearchParams`.
2. Follow one level to XSS04/XSS10/XSS11 sinks in **same file**.
3. Fail XSS15 only when HIGH confidence chain documented.

#### XSS26 — Model to th:utext

1. Grep `model.addAttribute`, `model.put`, `addFlashAttribute`.
2. Grep `th:utext="${`, `th:utext="*{`.
3. Fail XSS26 when **same attribute name** in Java and template at HIGH confidence.
4. Cross-reference XSS02 on template line.

---

## 3. Search Probes

| Goal | Probe |
|---|---|
| th:utext | `rg -n "th:utext" templates` |
| innerHTML | `rg -n "\.innerHTML\s*=" static templates` |
| outerHTML | `rg -n "\.outerHTML\s*=" static` |
| insertAdjacentHTML | `rg -n "insertAdjacentHTML" static` |
| document.write | `rg -n "document\.write" static` |
| eval | `rg -n "eval\(|new Function\(" static` |
| string timers | `rg -n 'setTimeout\("|setInterval\("' static` |
| jQuery HTML | `rg -n "\.html\(|\.append\(" static` |
| ResponseBody HTML | `rg -n "@ResponseBody\|TEXT_HTML\|getWriter\(\)\.write" src` |
| th:href/src | `rg -n "th:href=\"\\$|th:src=\"\\$" templates` |

---

## 4. CHECK-ID Procedures (summary)

**XSS02:** Fail dynamic `th:utext` without rich-text allow-list + save sanitization.

**XSS04–XSS16:** Fail on any match with untrusted/API data (fixed severity per POLICY).

**XSS17–XSS22:** Thymeleaf binding rules per mega X02–X08.

**XSS23–XSS25:** Controller must return view names / templates, not HTML strings or raw writes.

**XSS15/XSS26:** Trace procedures §2.2 only.

---

## 5. Report Requirements

**Possible Attack Scenario:** 1–2 sentences; no code fences.

**Resolution:** Pattern, Mechanism, Security property, Prohibited, Verify (action + pass signal).

Forbidden in Resolution: code fences, pasteable statements, Evidence copy as fix.

---

## 6. Secure Resolution Catalog

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| XSS01 | Context encoding | Framework encoders per output context | Encoding matches context | Manual HTML/URL concat | Special-char payload safely encoded |
| XSS02 | Auto-escaped output | Default `th:text`; rich text only with POLICY allow-list + save sanitization | User content escaped or allow-listed subset | Raw `th:utext` | Script probe escaped or stripped |
| XSS03 | JSON Content-Type | `APPLICATION_JSON` on API responses | Browser won't parse JSON as HTML | JSON as text/html | Header is application/json |
| XSS04 | textContent binding | `textContent` / `createTextNode` | No HTML parser on data | innerHTML assignment | Script payload shows as text only |
| XSS05 | Allow-list sanitizer | OWASP Java HTML Sanitizer at save boundary | Only safe tags render | Unsanitized rich text | Event-handler attribute stripped |
| XSS06 | UTF-8 enforcement | `spring.http.encoding.force=true` | Encoding bypasses fail | Non-UTF-8 acceptance | Double-encoded probe rejected |
| XSS07 | Safe reflection | `th:text` or encoder on error/search echo | Errors cannot execute script | Raw reflection | `<` encoded in error output |
| XSS08 | Safe script data | `th:inline="javascript"` escaped syntax | Safe JS serialization | Raw `${}` in script | Inline uses escaped syntax |
| XSS09 | Jackson escaping | `CharacterEscapes` on ObjectMapper | JSON cannot break HTML context | Unescaped `<` in JSON strings | API returns `\u003c` for `<` |
| XSS10 | Same as XSS04 | textContent pattern | No outerHTML parsing | outerHTML assignment | Payload renders as text |
| XSS11 | createElement | DOM builder APIs | No insertAdjacentHTML | insertAdjacentHTML | Payload renders as text |
| XSS12 | Server render | Thymeleaf views only | No document.write | document.write | Zero document.write in app JS |
| XSS13 | No dynamic code | Named functions from source files | No runtime string compile | eval, new Function | Zero eval in app JS |
| XSS14 | Function timers | Function reference to setTimeout | No string timers | setTimeout("...") | Zero string-arg timers |
| XSS15 | Server-side URL parse | Display via textContent only | URL never hits HTML sink | hash → innerHTML | §2.2 chain or LOW logged |
| XSS16 | Vanilla DOM | textContent instead of jQuery HTML parsers | jQuery won't parse HTML strings | .html(userData) | User paths use text only |
| XSS17 | MVC URL expressions | `th:href` with `@{...}` or validated URLs | No javascript: href | Dynamic unvalidated href | javascript: probe blocked |
| XSS18 | Same-origin assets | `th:src` with `@{/...}` | Scripts from app origin | Dynamic script URL from user | Script host matches app |
| XSS19 | External listeners | Handlers in JS files | No dynamic th:on* | th:onclick with dynamic values | Zero dynamic th:on bindings |
| XSS20 | Server-serialized JSON | Controller DTO via safe inlining | No string-built JSON in script | User JSON in script literal | DTO via escaped inlining |
| XSS21 | th:action | Spring MVC URL on forms | CSRF + context path correct | Static action= on session forms | POST reaches guarded URL |
| XSS22 | Static fragments | Literal fragment names | Fragment not user-controlled | Dynamic fragment selector | Literal names only |
| XSS23 | View + template | Return view name; Thymeleaf renders | No HTML in controller | @ResponseBody HTML | Controller returns view name only |
| XSS24 | Template-only markup | HTML only in templates with th:text | No Java HTML concat | String HTML in controller | Zero HTML concat in controllers |
| XSS25 | Encoded output | Template or encoder for writes | No raw user write | getWriter().write(userInput) | Writer paths use encoder |
| XSS26 | Escaped sink only | Model fields bound to th:text or validated | No model → th:utext name match | Same name Java + th:utext | §2.2 match or LOW logged |

---

## 7. Scoring

Base 100 · Critical −20 · High −10 · Medium −5 · Low −2 · Floor 0

---

## 8. Self-Validation

- XSS02 allow-list in Scope Notes when th:utext claimed.
- XSS15/XSS26 Fail only at HIGH confidence.
- Every FAIL has Verify with pass signal.
