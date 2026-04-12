---
description: Full-workspace security pass. Type /cmd-review-project-security to run OWASP-style review per security-reviewer skill and security-review rule; append findings to security-review/improvements-pending.md.
---

# /cmd-review-project-security — Review project security

Run a **full-workspace security pass** using the **L0 → L1 skill chain** (see `security-reviewer` → **Knowledge hierarchy**):

1. **[`security-reviewer`](../skills/security-reviewer/SKILL.md)** — always first (secrets, CI, Docker, cross-stack OWASP).  
2. **[`owasp-checklist`](../skills/owasp-checklist/SKILL.md)** — **automatically in the same run** when the workspace contains Java/Spring signals (`pom.xml`, `build.gradle*`, `*.java`, Spring `application*.yml|properties|yaml`); otherwise state that L1 was N/A.

Also apply the **`security-review.mdc`** rule (resolve **`.cursor/rules/security-review.mdc`**, or **`imported/**`** if rules were imported from GitHub/GitLab).

**Pantheon:** Gate-style tables may align with **`security-auditor`** when Zeus closes a security gate.

## What to do

1. **Scope** — If the user attached folders/files, limit the review to those; otherwise review the **entire open workspace** (code, config, Docker, CI, dependency manifests).
2. **Method** — Apply OWASP-style thinking (injection, broken access control, crypto, misconfig, vulnerable components, auth failures, logging, SSRF, etc.) and stack-specific checks (e.g. Spring Security, Thymeleaf/XSS, secrets in `application.properties`, CORS, actuator).
3. **Secrets** — Flag anything that looks like credentials, API keys, or private keys in **tracked** files; recommend env / secret manager / gitignored local config; verify `.gitignore` and suggest **`.cursorignore`** for local-only secret paths. In chat and in `improvements-pending.md`, **never** copy the secret value—only location and rotation steps.
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
