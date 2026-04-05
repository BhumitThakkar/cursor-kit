# Review project security

Run a **full-workspace security pass** using the same bar as `.cursor/skills/security-reviewer/SKILL.md` and `.cursor/rules/security-review.mdc`.

## What to do

1. **Scope** — If the user attached folders/files, limit the review to those; otherwise review the **entire open workspace** (code, config, Docker, CI, dependency manifests).
2. **Method** — Apply OWASP-style thinking (injection, broken access control, crypto, misconfig, vulnerable components, auth failures, logging, SSRF, etc.) and stack-specific checks (e.g. Spring Security, Thymeleaf/XSS, secrets in `application.properties`, CORS, actuator).
3. **Secrets** — Flag anything that looks like credentials, API keys, or private keys in repo; recommend env/secret manager rotation.
4. **Dependencies** — Note if lockfiles or SBOM are missing; recommend SCA in CI; call out obviously outdated high-risk deps if visible from manifests.
5. **Chat output** (use this structure):
   - **Summary** — 2–4 sentences on overall posture.
   - **Findings** — Table: `Severity | Area | Location | Issue | Recommendation`.
   - **Quick wins** — Bullet list, ordered by impact/effort.
   - **Assumptions** — What you could not verify without running the app or scanners.

6. **Write a backlog file** (required every run):
   - Path: **`security-review/improvements-pending.md`** at the **workspace root**.
   - If `security-review/` does not exist, create it.
   - **Insert** a new block **immediately after** the HTML comment line (the line starting with `<!--`), so **newest reviews stay at the top** of the history. Preserve the `#` heading and that comment; do not delete older `## Review — …` sections unless the user asked to reset the log.
   - Use this shape for each new block (replace the date and bullets with real content):

**`## Review — YYYY-MM-DD`** (subtitle: optional one-line scope, e.g. full workspace or paths)

**`### Summary`** — short paragraph.

**`### Pending improvements (check off when done)`** — only checkboxes, each like `- [ ] **High** — …` (use **High** / **Medium** / **Low**).

**`### Already OK / noted`** — optional bullets for things verified clean.

   - Do **not** paste secret values; reference location and rotation steps only.

Be concrete in both chat and file: cite file paths and, when helpful, symbols or config keys. Do not invent CVE IDs; say “verify with dependency scanner” when unsure.
