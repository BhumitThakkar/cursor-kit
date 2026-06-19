# Fleet invocation order

**Stack:** Spring Boot servlet + Thymeleaf + AJAX + Maven (+ Docker when deployed)  
**Rule:** Invoke in **phase order** below. Within a phase, order is **left → right**. Skip a row only when its **Gate** is not met (document N/A in that agent's report).

---

## Master table

| Phase | Order | Invoke | Version | Report path | Gate |
|------:|------:|--------|---------|-------------|------|
| **1 — Input & injection** | 1 | `input_validation_reviewer` | v1.0 | `AI/input_validation_reviewer/input_validation_reviewer_report.md` | Always for apps with external input |
| | 2 | `injection_reviewer` | v1.0 | `AI/injection_reviewer/injection_reviewer_report.md` | After phase 1 |
| **2 — Identity & credentials** | 3 | `password_credentials_reviewer` | v1.0 | `AI/password_credentials_reviewer/password_credentials_reviewer_report.md` | Auth or password flows exist |
| | 4 | `cryptography_reviewer` | v1.0 | `AI/cryptography_reviewer/cryptography_reviewer_report.md` | Crypto, TLS, tokens, or hashing in scope |
| | 5 | `step_up_auth_reviewer` | v1.0 | `AI/step_up_auth_reviewer/step_up_auth_reviewer_report.md` | High-impact or destructive flows |
| | 6 | `session_reviewer` | v1.1 | `AI/session_reviewer/session_reviewer_report.md` | Session cookies or server-side sessions |
| **3 — Access control** | 7 | `authorization_reviewer` | v2.0 | `AI/authorization_reviewer/authorization_reviewer_report.md` | `SecurityFilterChain` or method security |
| | 8 | `identifier_enumeration_reviewer` | v1.0 | `AI/identifier_enumeration_reviewer/identifier_enumeration_reviewer_report.md` | IDs in URLs, APIs, or responses |
| **4 — Browser & transport (Thymeleaf/AJAX)** | 9 | `cors_reviewer` | v2.0 | `AI/cors_reviewer/cors_reviewer_report.md` | CORS config or cross-origin API |
| | 10 | `csrf_reviewer` | v2.0 | `AI/csrf_reviewer/csrf_reviewer_report.md` | Session-cookie mutations or forms |
| | 11 | `xss_encoding_reviewer` | v2.0 | `AI/xss_encoding_reviewer/xss_encoding_reviewer_report.md` | Templates, HTML output, or DOM sinks |
| | 12 | `clickjacking_headers_reviewer` | v2.0 | `AI/clickjacking_headers_reviewer/clickjacking_headers_reviewer_report.md` | HTML responses or security headers |
| | 13 | `open_redirect_reviewer` | v1.0 | `AI/open_redirect_reviewer/open_redirect_reviewer_report.md` | Redirect parameters or OAuth callbacks |
| **5 — Abuse surfaces** | 14 | `file_upload_inclusion_reviewer` | v1.0 | `AI/file_upload_inclusion_reviewer/file_upload_inclusion_reviewer_report.md` | Uploads, downloads, or path parameters |
| | 15 | `mass_assignment_reviewer` | v1.0 | `AI/mass_assignment_reviewer/mass_assignment_reviewer_report.md` | Data binding / DTOs / forms |
| | 16 | `ssrf_reviewer` | v1.0 | `AI/ssrf_reviewer/ssrf_reviewer_report.md` | Outbound HTTP, webhooks, URL fetch |
| | 17 | `unsafe_parsing_deserialization_reviewer` | v1.0 | `AI/unsafe_parsing_deserialization_reviewer/unsafe_parsing_deserialization_reviewer_report.md` | Parsers, XML/JSON/YAML, archives |
| **6 — Disclosure** | 18 | `actuator_reviewer` | v1.0 | `AI/actuator_reviewer/actuator_reviewer_report.md` | Actuator on classpath |
| | 19 | `disclosure_reviewer` | v2.0 | `AI/disclosure_reviewer/disclosure_reviewer_report.md` | After actuator; errors/static/logs |
| **7 — Build, container, frontend supply** | 20 | `vulnerability_reviewer` | v2.0 | `AI/vulnerability_reviewer/vulnerability_reviewer_report.md` | Maven + Spring Boot (`pom.xml`) |
| | 21 | `container_secrets_reviewer` | v1.1 | `AI/container_secrets_reviewer/container_secrets_reviewer_report.md` | Dockerfile, `.gitignore`, or properties secrets |
| | 22 | `supply_chain_reviewer` | v2.0 | `AI/supply_chain_reviewer/supply_chain_reviewer_report.md` | Thymeleaf/HTML with external scripts |
| **8 — Platform & assurance** | 23 | `middleware_tls_dos_reviewer` | v1.0 | `AI/middleware_tls_dos_reviewer/middleware_tls_dos_reviewer_report.md` | Reverse proxy, TLS, rate limits |
| | 24 | `security_testing_reviewer` | v1.0 | `AI/security_testing_reviewer/security_testing_reviewer_report.md` | Release pipeline |
| | 25 | `security_logging_monitoring_reviewer` | v1.0 | `AI/security_logging_monitoring_reviewer/security_logging_monitoring_reviewer_report.md` | Security-relevant logging |

---

## Bundles

### Thymeleaf + AJAX (phase 4)

`cors_reviewer` → `csrf_reviewer` → `xss_encoding_reviewer` → `clickjacking_headers_reviewer` → `open_redirect_reviewer`

### Disclosure (phase 6)

`actuator_reviewer` → `clickjacking_headers_reviewer` (if auth HTML) → `disclosure_reviewer`

### Maven + Docker (phase 7)

`vulnerability_reviewer` → `container_secrets_reviewer` → `supply_chain_reviewer` (if HTML/CDN)

---

## Minimum pre-production set

| App shape | Phases to run |
|-----------|----------------|
| REST API only (no Thymeleaf) | 1–3, 5–8; skip phase 4 and `supply_chain_reviewer` |
| Thymeleaf + session auth | 1–8 full table |
| Library / no deploy | Stack gate per agent only |
