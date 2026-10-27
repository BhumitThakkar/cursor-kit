# Fleet invocation order

**Stack:** Spring Boot servlet + Thymeleaf + AJAX + Maven (+ Docker when deployed)  
**Rule:** Invoke in **phase order** below. Within a phase, order is **left → right**. Skip a row only when its **Gate** is not met (document N/A in that agent's report).

**Report header (mandatory for every agent):** Immediately under the report title, include **`Reviewer`** (agent name + version + `STRICT`) and **`Fleet position`** (`#{Order} — Phase {N} ({phase name})` from the **Order** and **Phase** columns below). See [`SCORING_REVIEWER_AGENT_MECHANISM.md`](SCORING_REVIEWER_AGENT_MECHANISM.md) · Required report header. Solo runs: `Fleet position: N/A — solo run` + reason in Scope Notes.

**Finding storytelling (mandatory for every agent):** Every scored finding and Manual Review CHECK-ID explanation must include **`#### Picture in your head`** — a concrete mental model / analogy / before-after story (prefer ending with **In even simpler terms...** or **Here's a practical example:**). Keep existing Resolution rows (Pattern, Mechanism, Security property, Prohibited, Verify). See [`SCORING_REVIEWER_AGENT_MECHANISM.md`](SCORING_REVIEWER_AGENT_MECHANISM.md) · Picture in your head.

---

## Master table

| Phase | Order | Invoke | Version | Report path | Gate |
|------:|------:|--------|---------|-------------|------|
| **1 — Input & injection** | 1 | `input_validation_reviewer` | v1.0 | `AI/agents/security_reviewers/input_validation_reviewer/input_validation_reviewer_report.md` | Always for apps with external input |
| | 2 | `injection_reviewer` | v1.0 | `AI/agents/security_reviewers/injection_reviewer/injection_reviewer_report.md` | After phase 1 |
| **2 — Identity & credentials** | 3 | `password_credentials_reviewer` | v1.0 | `AI/agents/security_reviewers/password_credentials_reviewer/password_credentials_reviewer_report.md` | Auth or password flows exist |
| | 4 | `cryptography_reviewer` | v1.0 | `AI/agents/security_reviewers/cryptography_reviewer/cryptography_reviewer_report.md` | Crypto, TLS, tokens, or hashing in scope |
| | 5 | `step_up_auth_reviewer` | v1.0 | `AI/agents/security_reviewers/step_up_auth_reviewer/step_up_auth_reviewer_report.md` | High-impact or destructive flows |
| | 6 | `session_reviewer` | v1.1 | `AI/agents/security_reviewers/session_reviewer/session_reviewer_report.md` | Session cookies or server-side sessions |
| **3 — Access control** | 7 | `authorization_reviewer` | v2.0 | `AI/agents/security_reviewers/authorization_reviewer/authorization_reviewer_report.md` | `SecurityFilterChain` or method security |
| | 8 | `identifier_enumeration_reviewer` | v1.0 | `AI/agents/security_reviewers/identifier_enumeration_reviewer/identifier_enumeration_reviewer_report.md` | IDs in URLs, APIs, or responses |
| **4 — Browser & transport (Thymeleaf/AJAX)** | 9 | `cors_reviewer` | v2.0 | `AI/agents/security_reviewers/cors_reviewer/cors_reviewer_report.md` | CORS config or cross-origin API |
| | 10 | `csrf_reviewer` | v2.0 | `AI/agents/security_reviewers/csrf_reviewer/csrf_reviewer_report.md` | Session-cookie mutations or forms |
| | 11 | `xss_encoding_reviewer` | v2.0 | `AI/agents/security_reviewers/xss_encoding_reviewer/xss_encoding_reviewer_report.md` | Templates, HTML output, or DOM sinks |
| | 12 | `clickjacking_headers_reviewer` | v2.1 | `AI/agents/security_reviewers/clickjacking_headers_reviewer/clickjacking_headers_reviewer_report.md` | HTML responses or security headers |
| | 13 | `open_redirect_reviewer` | v1.0 | `AI/agents/security_reviewers/open_redirect_reviewer/open_redirect_reviewer_report.md` | Redirect parameters or OAuth callbacks |
| **5 — Abuse surfaces** | 14 | `file_upload_inclusion_reviewer` | v1.0 | `AI/agents/security_reviewers/file_upload_inclusion_reviewer/file_upload_inclusion_reviewer_report.md` | Uploads, downloads, or path parameters |
| | 15 | `mass_assignment_reviewer` | v1.0 | `AI/agents/security_reviewers/mass_assignment_reviewer/mass_assignment_reviewer_report.md` | Data binding / DTOs / forms |
| | 16 | `ssrf_reviewer` | v1.0 | `AI/agents/security_reviewers/ssrf_reviewer/ssrf_reviewer_report.md` | Outbound HTTP, webhooks, URL fetch |
| | 17 | `unsafe_parsing_deserialization_reviewer` | v1.0 | `AI/agents/security_reviewers/unsafe_parsing_deserialization_reviewer/unsafe_parsing_deserialization_reviewer_report.md` | Parsers, XML/JSON/YAML, archives |
| | 18 | `application_rate_limit_reviewer` | v2.0 | `AI/agents/security_reviewers/application_rate_limit_reviewer/application_rate_limit_reviewer_report.md` | HTTP ingress, multi-caller apps, bulk/async workloads, or Thymeleaf+AJAX mutations |
| **6 — Disclosure** | 19 | `actuator_reviewer` | v1.0 | `AI/agents/security_reviewers/actuator_reviewer/actuator_reviewer_report.md` | Actuator on classpath |
| | 20 | `disclosure_reviewer` | v2.0 | `AI/agents/security_reviewers/disclosure_reviewer/disclosure_reviewer_report.md` | After actuator; errors/static/logs |
| **7 — Build, container, frontend supply** | 21 | `container_secrets_reviewer` | v1.1 | `AI/agents/security_reviewers/container_secrets_reviewer/container_secrets_reviewer_report.md` | Dockerfile, `.gitignore`, or properties secrets |
| | 22 | `supply_chain_reviewer` | v2.0 | `AI/agents/security_reviewers/supply_chain_reviewer/supply_chain_reviewer_report.md` | Thymeleaf/HTML with external scripts |
| **8 — Platform & assurance** | 23 | `middleware_tls_dos_reviewer` | v1.0 | `AI/agents/security_reviewers/middleware_tls_dos_reviewer/middleware_tls_dos_reviewer_report.md` | Reverse proxy, TLS, body-size DoS |
| | 24 | `security_testing_reviewer` | v1.0 | `AI/agents/security_reviewers/security_testing_reviewer/security_testing_reviewer_report.md` | Release pipeline |
| | 25 | `security_logging_monitoring_reviewer` | v1.0 | `AI/agents/security_reviewers/security_logging_monitoring_reviewer/security_logging_monitoring_reviewer_report.md` | Security-relevant logging |
| **9 — Dependency CVE (last)** | 26 | `vulnerability_reviewer` | v2.1 | `AI/agents/security_reviewers/vulnerability_reviewer/vulnerability_reviewer_report.md` | Maven + Spring Boot (`pom.xml`) — **invoke last; never omit on full fleet** |

---

## Bundles

### Thymeleaf + AJAX (phase 4)

`cors_reviewer` → `csrf_reviewer` → `xss_encoding_reviewer` → `clickjacking_headers_reviewer` → `open_redirect_reviewer`

### Abuse + rate limits (phase 5 tail)

`unsafe_parsing_deserialization_reviewer` → `application_rate_limit_reviewer`

Run after identity (phase 2) and access control (phase 3) so per-principal and per-caller limits can be judged against auth model.

### Disclosure (phase 6)

`actuator_reviewer` → `clickjacking_headers_reviewer` (if auth HTML) → `disclosure_reviewer`

### Maven + Docker (phase 7)

`container_secrets_reviewer` → `supply_chain_reviewer` (if HTML/CDN)

### Dependency scan (phase 9 — always last)

`vulnerability_reviewer` — run after all other reviewers.

**Mandatory on every full fleet run** — do **not** omit unless the user **explicitly** excludes this agent in the brief.

**Phase 2 — all four tools required** (no skip unless user explicitly waives a named tool in the brief):

1. Gitleaks  
2. OWASP dependency-check (Maven profile)  
3. Trivy fs  
4. CycloneDX SBOM  

Any tool `skipped` without user waiver → **V14 Fail** in report.

---

## Minimum pre-production set

| App shape | Phases to run |
|-----------|----------------|
| REST API only (no Thymeleaf) | 1–3, 5–9; skip phase 4 and `supply_chain_reviewer`; include `application_rate_limit_reviewer` when `/api/**` or Basic auth exists |
| Thymeleaf + session auth | 1–9 **full table** (includes `vulnerability_reviewer` last) |
| Library / no deploy | Stack gate per agent only |

---

## Fleet size

**26 live agents** (vulnerability_reviewer moved to order **26**).
