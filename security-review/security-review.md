# Security review bundle

Git-tracked entry point for **security-conscious development** in any project. Cursor loads the machine-readable rule from `.cursor/rules/`; detailed guidance lives in the **security-reviewer** skill.

## Where things live

| Artifact | Path |
|----------|------|
| Cursor rule (`.mdc`) | `.cursor/rules/security-review.mdc` (canonical; see **Rule location** below) |
| Skill (checklists, OWASP-aligned guidance) | `.cursor/skills/security-reviewer/SKILL.md` |
| Agent stub | `.cursor/agents/security-reviewer.md` |
| Pending backlog (from `/cmd-review-project-security`) | `security-review/improvements-pending.md` |
| Example `.cursorignore` (copy to project root) | `security-review/cursorignore.example` |
| Cursor lifecycle hooks (beta) | `.cursor/hooks.json`; scripts in `.cursor/hooks/` |

## Rule location: canonical vs GitHub/GitLab import

This bundle’s **commands, agent stub, and skill** refer to paths **relative to the opened workspace**. They assume a **canonical** layout:

- **Recommended:** `security-review.mdc` lives at **`.cursor/rules/security-review.mdc`**.

**Cursor “Import rules from GitHub/GitLab”** often copies files under:

- **`.cursor/rules/imported/<source-name>/…`**

That path **varies** (`<source-name>` is not stable across repos). This bundle **does not** hardcode those segments in the shipped files so the same repo stays portable.

**Pick one approach (no ongoing path churn in skills/commands):**

1. **Canonical install (best for stable references)**  
   Copy or merge the **bundle’s** `.cursor/` tree into your app (copy, submodule, or sparse checkout) so `security-review.mdc` ends up at **`.cursor/rules/security-review.mdc`**.  
   **Do not** rely on “Import rules” for this file if you want every cross-reference to match without edits.

2. **Import + single bridge (minimal maintenance)**  
   After import, **either:**  
   - Copy or symlink the imported `security-review.mdc` to **`.cursor/rules/security-review.mdc`**, **or**  
   - Keep a single project-local note (e.g. in your app’s `AGENTS.md`) listing the **actual** path under `imported/…` for humans and agents.  
   The slash command text is written so the model still looks under **`.cursor/rules/`** broadly (including `imported/**`).

3. **Import only, no canonical copy**  
   Works if Cursor loads nested `.mdc` files; the **agent stub** points you to `security-review/security-review.md` for path nuances. Prefer (1) or (2) if anything fails to resolve.

**Avoid duplicate `alwaysApply`:** Do not keep **two** copies of the same `security-review.mdc` (e.g. both `imported/...` and `.cursor/rules/security-review.mdc`) unless one is a symlink—otherwise the rule may apply twice.

## How you trigger it

| Trigger | When it runs |
|---------|----------------|
| **Rule** (`security-review.mdc`, `alwaysApply: true`) | While this folder is the **opened workspace**, Cursor includes the rule in context. |
| **Slash command** | In **Chat**, type **`/`** and choose **`cmd-review-project-security`**. You get a **chat report** plus updates to **`security-review/improvements-pending.md`**. |
| **Natural language** | E.g. “security review this change”—the **security-reviewer** skill helps routing. |

Copy **`.cursor/commands/`** into your app if you want the same `/` command there.

## Adopting in another project

1. Copy or submodule the **bundle’s** **`.cursor/rules/`**, **`.cursor/skills/security-reviewer/`**, **`.cursor/commands/`**, and optional **`.cursor/agents/security-reviewer.md`**, plus the **`security-review/`** folder and any **`AGENTS.md`** notes you use.
2. Open the **project** workspace in Cursor so `.cursor/rules` and `.cursor/commands` apply.
3. Refresh the skill when standards shift (OWASP updates, framework advisories).

## Not secret storage

Do **not** put API keys, tokens, or production credentials here—only patterns and process.

## Limits (credentials & AI)

- The **rule + skill** ask the model to **flag** unsafe credential handling and to **avoid repeating** secrets in chat or `improvements-pending.md`.
- They **do not** stop Git from tracking a file, and they **do not** guarantee the model never sees a file: use **`.cursorignore`**, gitignored local overrides, and **no secrets in tracked files**.
- For typical **Spring Boot** apps, move real passwords out of committed `application.properties` into env or gitignored `application-local.properties`, add secret scanning, and rotate anything ever committed.
