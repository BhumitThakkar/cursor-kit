---
description: >-
  Diff-scoped security pass. Type /cmd-security-scan to run OWASP-style review on changed or
  attached files only; chat output required; optional append to security-review/improvements-pending.md.
---

# /cmd-security-scan — Security review on current diff

Run a **narrow-scope security pass** on the **current change set** (not the whole repo by default):

- **Default scope:** Files the user attached, named in the prompt, or implied as “this PR / this diff” — if unclear, ask **one** question: *staged only*, *unstaged*, *paths X,Y*, or *full workspace* (then prefer `/cmd-review-project-security` instead).
- **Skill chain:** Same **L0 → L1** order as full review:
  1. **[`security-reviewer`](../skills/security-reviewer/SKILL.md)** first.
  2. **[`owasp-checklist`](../skills/owasp-checklist/SKILL.md)** when Java/Spring artifacts exist among scoped files.

Apply **`security-review.mdc`** for discipline on reviewed paths.

**Contrast:** [`cmd-review-project-security`](cmd-review-project-security.md) reviews the **entire workspace** and **always** appends to the backlog file. This command focuses on **diff-sized** surface area.

## What to do

1. **Discover scope** — Prefer `git diff --name-only`, `git diff --cached --name-only`, or user-supplied paths. Exclude generated noise (`target/`, `build/`, `node_modules/`) unless the user asks.
2. **Review** — Same categories as full pass (secrets, injection, authz, misconfig, XSS/Thymeleaf, dependencies touched, etc.) but **only** for files in scope.
3. **Secrets** — Never paste values; locations + rotation only.
4. **Chat output** (required): **Summary**, **Findings** table (`Severity | Area | Location | Issue | Recommendation`), **Quick wins**, **Assumptions**.
5. **Backlog file** (optional — ask or infer from user tone; default **yes** if they said “log it” or “track it”):
   - Path: **`security-review/improvements-pending.md`**.
   - Insert a new block **immediately after** the `<!--` anchor line (newest at top), same shape as `/cmd-review-project-security`, but the **`## Review — YYYY-MM-DD`** subtitle **must** include **`(diff)`** or the exact path list, e.g. `## Review — 2026-04-11 (diff: src/...)` so full-workspace reviews stay distinguishable.

If scope is empty (no diff, no paths), say so and suggest running with attachments or `/cmd-review-project-security` for a full pass.
