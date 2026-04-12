---
name: security-reviewer
description: >-
  Parent security skill (workspace-wide): OWASP-oriented controls, secrets, deps,
  CI/Docker, auth, logging. Child skill: owasp-checklist (Spring/Java depth). Load
  this first whenever security-review rule or /cmd-review-project-security applies.
---

# Security reviewer

## Knowledge hierarchy (no conflicts — ordered layers)

| Layer | Skill | Role |
| --- | --- | --- |
| **L0 — Root** | **This file** (`security-reviewer`) | Scope, principles, secrets/Git/AI, deps, Docker/CI, cross-cutting OWASP list, output shape for `/cmd-review-project-security`. **Always load first** when any security pass runs. |
| **L1 — Spring/Java specialization** | [`owasp-checklist`](../owasp-checklist/SKILL.md) | Concrete Spring Boot / Thymeleaf patterns, A01–A10 tables, file-level checks. **Auto-load in the same session** when the task or workspace touches Java/Spring (see triggers below). |

**Resolution:** L1 never overrides L0 on secrets, supply chain, or “do not paste credentials”. L0 does not duplicate L1’s Spring code patterns — delegate detail to L1. If a finding fits both, cite **L0 category** in summary and **L1 checklist id** (e.g. A03) in detail.

### When to auto-load `owasp-checklist` after this skill

Treat as **automatic** (same turn / same review) if **any** of:

- Paths include `pom.xml`, `build.gradle`, `*.java`, or Spring `application*.properties` / `application*.yml` / `application*.yaml`
- Zeus or the user mentions Spring Boot, Thymeleaf, JPA, or `security-auditor`

If none apply (e.g. pure Node or static site), finish the pass with **L0 only** and note “Spring checklist N/A”.

## When to use

- User runs **`/cmd-review-project-security`** or asks for security review, hardening, OWASP, pen-test prep, or compliance-oriented checks.
- After meaningful changes to auth, data handling, HTTP surface, config, or dependencies.
- Before release or when onboarding a new service.

**Pantheon:** After L0, apply **L1 `owasp-checklist`** when triggers above match. For **gate-style** verdict tables, align with **`security-auditor`** output format when Zeus delegates.

## Principles

1. **Assume breach** — minimize blast radius (least privilege, segmentation, no lateral movement via shared creds).
2. **Secure defaults** — deny by default; explicit allow for sensitive operations.
3. **Verify, don’t trust** — validate input at trust boundaries; never trust the client for authorization.
4. **Observable** — security-relevant events are logged without leaking secrets or PII into logs.

## OWASP-aligned checklist (web / API)

- **Broken access control** — Enforce server-side authorization per resource; avoid IDOR; test role boundaries.
- **Cryptographic failures** — TLS for data in transit; strong algorithms; no custom crypto; protect keys (env/HSM/vault, not git).
- **Injection** — Parameterized queries; encode output for context (HTML/JS/SQL); avoid unsafe deserialization.
- **Insecure design** — Threat model critical flows (auth, payments, PII); rate limits on sensitive endpoints.
- **Security misconfiguration** — Harden defaults; disable debug in prod; safe CORS; security headers where applicable.
- **Vulnerable components** — Dependency and image scanning; pin versions; patch critical CVEs quickly.
- **Auth failures** — Strong session/token handling; MFA where appropriate; lockout / backoff on brute force.
- **Data integrity** — Signatures or integrity checks where assets are distributed; protect CI/CD.
- **Logging failures** — Log auth decisions and anomalies; no secrets in logs; retention aligned with policy (see `spring-boot-patterns` for Log4j2 hygiene).
- **SSRF** — Validate outbound URLs; block metadata endpoints; allowlists where possible.

## Spring Boot (common patterns)

- Prefer **Spring Security** for authn/authz; avoid rolling custom crypto.
- **CSRF** for cookie-based sessions on state-changing browser flows; understand when APIs are token-based and CSRF differs.
- **CORS** minimal and explicit; avoid `*` with credentials.
- **Actuator** and management endpoints not exposed publicly without auth.
- **File upload** — type/size limits, virus scan at boundary if required, safe storage paths.

## Frontend / browser

- **CSP** where feasible; avoid inline scripts where policy forbids.
- **XSS** — contextual escaping; avoid `dangerouslySetInnerHTML` / raw HTML from untrusted input.
- **Secrets** — never in client bundles or public repos.

## Dependencies & supply chain

- Lockfiles committed; CI job for **SCA** (e.g. OWASP Dependency-Check, Snyk, GitHub Dependabot).
- Container images: minimal base, non-root user, regular rebuilds.

## Secrets & configuration

- No secrets in source; use env, secret manager, or CI secrets.
- Rotate on exposure; short-lived credentials where possible.

## Credentials, Git, and AI / editor context (critical)

The security reviewer **does not** magically hide files from Git or from the AI. If a secret is in the workspace and indexed, **models can see it** when those paths are in context. Your job is to **detect**, **recommend migration**, and **never reproduce** secret values in outputs.

### Safe storage (target state)

- **Spring Boot:** `spring.datasource.password=${DB_PASSWORD}` (and similar) with values supplied only via environment, `SPRING_APPLICATION_JSON`, Docker/K8s secrets, or a **gitignored** `application-local.properties` / `application-{profile}.properties` that is never committed.
- **Never commit:** database passwords, Basic Auth passwords, API keys, JWT signing keys, private keys (`.pem`, `.key`), OAuth client secrets, Google service account JSON.
- **Templates:** Commit `application.properties.example` or `*.env.example` with **empty or placeholder** values and comments; real files stay local or in a vault.

### Git hygiene

- Extend **`.gitignore`**: `.env`, `.env.*`, `application-local.properties`, `*.pem`, `secrets/`, downloaded credential JSON.
- **Pre-commit / CI:** `gitleaks`, `trufflehog`, or GitHub **secret scanning** + push protection; fail builds on detected secrets.
- **History:** If secrets were ever committed, **rotate** credentials and use `git filter-repo` or platform tools to purge history—ignoring the file going forward is not enough.

### Reducing exposure to AI (Cursor and similar)

- **`.cursorignore`** (project root): list paths that must stay out of default indexing/context (e.g. `**/application-local.properties`, `.env`, `**/secrets/**`). This reduces accidental inclusion in chat/composer; it is **not** a substitute for removing secrets from disk or Git.
- **Do not** paste secrets into chat; if the user pastes one, tell them to **rotate** it.
- In **`security-review/improvements-pending.md`** and code review tables: write *“DB password in `application.properties` (rotate; move to env)”* — **never** the actual password.

### Review checklist (run on every security pass)

- [ ] No plaintext credentials in tracked `*.properties`, `*.yml`, `docker-compose*.yml`, shell scripts, or frontend env.
- [ ] `.gitignore` (and optionally `.cursorignore`) cover local secret files.
- [ ] CI or pre-commit secret scanning is present or explicitly recommended.
- [ ] If defaults exist (e.g. `admin` / dev-only Basic Auth), they are **not** acceptable for production without documented exception.

## Docker / deploy

- Non-root user in image; read-only root FS where possible; no default passwords.
- Health checks; limit capabilities; secrets via orchestrator secret store.

## Output style

When reviewing code, list **findings** with: severity (critical/high/medium/low), location, exploitability, and **concrete fix**. Call out **assumptions** when context is missing.

## Refreshing “current” knowledge

This file is static. Periodically align with:

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/) (for requirements depth)
- Vendor security advisories for your stack (Spring, browser, DB, cloud).
