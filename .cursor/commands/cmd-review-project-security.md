# Review project security

Run a **full-workspace security pass** using the same bar as `.cursor/skills/security-reviewer/SKILL.md` and `.cursor/rules/security-review.mdc`.

## What to do

1. **Scope** — If the user attached folders/files, limit the review to those; otherwise review the **entire open workspace** (code, config, Docker, CI, dependency manifests).
2. **Method** — Apply OWASP-style thinking (injection, broken access control, crypto, misconfig, vulnerable components, auth failures, logging, SSRF, etc.) and stack-specific checks (e.g. Spring Security, Thymeleaf/XSS, secrets in `application.properties`, CORS, actuator).
3. **Secrets** — Flag anything that looks like credentials, API keys, or private keys in repo; recommend env/secret manager rotation.
4. **Dependencies** — Note if lockfiles or SBOM are missing; recommend SCA in CI; call out obviously outdated high-risk deps if visible from manifests.
5. **Output** (use this structure):
   - **Summary** — 2–4 sentences on overall posture.
   - **Findings** — Table: `Severity | Area | Location | Issue | Recommendation`.
   - **Quick wins** — Bullet list, ordered by impact/effort.
   - **Assumptions** — What you could not verify without running the app or scanners.

Be concrete: cite file paths and, when helpful, symbols or config keys. Do not invent CVE IDs; say “verify with dependency scanner” when unsure.
