---
description: >-
  Dependency hygiene pass. Type /cmd-dependency-audit to analyze manifests and suggest SCA steps;
  DevOps-oriented; no secret values in output.
---

# /cmd-dependency-audit — Dependency audit (DevOps)

Focus on **supply-chain visibility** for the workspace: manifests, lockfiles, known-risk patterns, and **recommended automation**. This is **not** a line-by-line OWASP code review (use `/cmd-review-project-security` or `/cmd-security-scan` for that).

## What to do

1. **Detect stack** — `pom.xml`, `build.gradle*`, `package.json` + lockfiles, `requirements.txt`, etc.
2. **Read-only inspection** — Note direct vs transitive where visible; flag missing lockfile or SBOM; call out deprecated coordinates only when evident from comments or obvious version skew (do not invent CVE IDs).
3. **Local commands (when safe to suggest)** — e.g. `mvn -q dependency:tree`, `.\gradlew.bat dependencies` — user runs if they want; do not assume network access from the agent.
4. **OWASP Dependency-Check** — If [`.cursor/hooks/install-dependency-check.ps1`](../hooks/install-dependency-check.ps1) or `.cursor/tools` documentation exists in the repo, reference it; otherwise recommend adding SCA in CI (GitHub Advanced Security, OWASP DC, Snyk, etc.) without vendor-specific secrets.
5. **Output** — **Summary**, **Findings** (table: `Severity | Area | Location | Issue | Recommendation`), **CI recommendations** (bullet list, names only for env vars), **Assumptions**.

**Hard rule:** Never print API keys, tokens, or `.npmrc` / `.m2/settings.xml` credentials; if found in tracked files, flag **CRITICAL** and recommend rotation + git history scrub (no values in chat).

**Pantheon:** Align with **DevOps** agent and `quality-gates.mdc` Gate 5 where relevant.
