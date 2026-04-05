---
name: security-reviewer
description: >-
  Security review and hardening for any stack: OWASP-oriented controls, secrets,
  dependencies, authn/authz, web/API safety, logging, and deployment. Use for
  security review, threat modeling light-touch, or before release.
---

# Security reviewer

## When to use

- User asks for security review, hardening, OWASP, pen-test prep, or compliance-oriented checks.
- After meaningful changes to auth, data handling, HTTP surface, config, or dependencies.
- Before release or when onboarding a new service.

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
- **Logging failures** — Log auth decisions and anomalies; no secrets in logs; retention aligned with policy.
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
