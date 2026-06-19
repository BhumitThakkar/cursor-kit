---
name: disclosure_reviewer
version: 2.0
disable-model-invocation: true
---

# Information Disclosure Security Reviewer - Scan Skill v2.0 STRICT

| Report line | `disclosure_reviewer v2.0 STRICT` |
| Report path | `AI/disclosure_reviewer/disclosure_reviewer_report.md` |

---

## 1. Supported Technology Stack

Spring Boot servlet MVC or REST with HTTP error handling, static resources, or application logging.

Out of scope → mandatory wording; no CHECK-IDs scored.

---

## 2. Companion reviewers (run before or with this audit)

| Signal in project | Run first | Scope Notes must cite |
|---|---|---|
| `spring-boot-starter-actuator` | `actuator_reviewer` | `AI/actuator_reviewer/actuator_reviewer_report.md` |
| Authenticated HTML (Thymeleaf, etc.) | `clickjacking_headers_reviewer` | `AI/clickjacking_headers_reviewer/clickjacking_headers_reviewer_report.md` |

Do not grep or score `management.endpoints.*`, `show-details`, or `cacheControl()` for this agent.

---

## 3. File Discovery

### Application properties

- All profiles: `server.error.*` only (not `management.*`)

### Exception handlers

- `@ControllerAdvice`, `@ExceptionHandler`, custom `ErrorController`

### Static resources

- `src/main/resources/static/`, `public/`, `resources/`
- `.map` files, `robots.txt`, committed `.env` under web paths

### Logging

- `logback-spring.xml`, `log4j2.xml`
- `log.info` / `log.debug` / `log.error` with `password`, `token`, `secret`, `authorization`

---

## 4. Required Search Probes

| Goal | Probe |
|---|---|
| Error config | `rg -n "server\.error\.include-stacktrace\|server\.error\.include-message" src` |
| Exception handlers | `rg -n "@ControllerAdvice\|@ExceptionHandler" src` |
| Stack in response | `rg -n "\.printStackTrace\(\)" src` |
| Secrets in logs | `rg -n "log\.(info\|debug\|error\|trace\|warn).*(password\|token\|secret)" src` |
| Source maps | `rg -n "\.map" src/main/resources` |
| Static secrets | `rg -n "\.env\|api[_-]?key" src/main/resources/static` |

---

## 5. Scope N/A Rules

| Check | N/A only when |
|---|---|
| DISC01–DISC02 | No HTTP request handling |
| DISC03 | No static/browser-served files |
| DISC04 | No application logging of auth/sensitive data |

---

## 6. CHECK-ID Scoring Procedure

### DISC01 — Generic Production Errors

Fail when handlers return `exception.getMessage()`, internal component names, or framework details to the client.

### DISC02 — No Stack Traces or SQL in Responses

Fail on `include-stacktrace=always` in prod, or manual stack/SQL append to response body.

### DISC03 — No Static Secret Leakage

Fail on `.map`, `.env`, API keys, or debug logs in deployable static paths or git index.

### DISC04 — No Sensitive Data in Logs

Fail when passwords, tokens, or PANs are logged in cleartext.

---

## 7. Report Requirements

Possible Attack Scenario: 1–2 sentences. Five Resolution rows; Verify = action + pass signal.

Scope Notes must list companion reviewer reports when actuator or auth HTML is present.

---

## 8. Secure Resolution Catalog

| ID | Pattern | Mechanism | Security property | Prohibited | Verify |
|---|---|---|---|---|---|
| DISC01 | Generic responses | `@ExceptionHandler` logs detail, returns fixed generic DTO | Internal logic hidden from users | `getMessage()` to client | Trigger 500; response is generic |
| DISC02 | Suppress stack traces | `server.error.include-stacktrace=never` in prod | No stack/SQL in body | `include-stacktrace=always` | Trigger 500; no stack in body |
| DISC03 | Remove static secrets | Exclude maps, logs, keys from static resources | Secrets not downloadable | `.map` in public static | Request `.map` URL; 404 |
| DISC04 | Redact logs | Mask or omit secrets before logging | Logs safe for operators | Logging passwords | Login flow logs omit password |

---

## 9. Scoring

Base 100 · Critical −20 · High −10 · Medium −5 · Low −2 · Floor 0

---

## 10. Self-Validation

- Four CHECK-IDs only (DISC01–DISC04).
- No findings citing actuator or Cache-Control — those belong to companion agents.
- Companion report paths in Scope Notes when applicable.
- Logging passwords is DISC04 Critical Fail.
