# Security review (cursor-kit)

Git-tracked entry point for **security-conscious development**. Cursor picks up the machine-readable rule from `.cursor/rules/`; depth lives in the **security-reviewer** skill.

## Where things live

| Artifact | Path |
|----------|------|
| Cursor rule (`.mdc`) | `.cursor/rules/security-review.mdc` |
| Skill (checklists, OWASP-aligned guidance) | `.cursor/skills/security-reviewer/SKILL.md` |
| Agent stub | `.cursor/agents/security-reviewer.md` |
| Pending backlog (from `/cmd-review-project-security`) | `security-review/improvements-pending.md` |

## How you trigger it

| Trigger | When it runs |
|---------|----------------|
| **Rule** (`.cursor/rules/security-review.mdc`, `alwaysApply: true`) | Whenever this folder is the **opened workspace**, Cursor includes the rule in context—no slash command needed for “always think security.” |
| **Slash command** | In **Chat**, type **`/`** and choose **`cmd-review-project-security`**. You get a **chat report** plus an updated **`security-review/improvements-pending.md`** (checkbox backlog, prepended per run). |
| **Natural language** | Ask e.g. “security review this PR” or “check auth on the API”—the **security-reviewer** skill description still helps routing. |

Copy **`.cursor/commands/`** into your app if you want the same `/` command there.

## Using this in a project

1. Copy or submodule **cursor-kit** into your app, **or** copy `.cursor/rules/`, `.cursor/skills/security-reviewer/`, and **`.cursor/commands/`** (plus optional agent + `AGENTS.md` rows).
2. Open the **project** workspace in Cursor so `.cursor/rules` and `.cursor/commands` apply to that repo.
3. Refresh the skill when major standards shift (OWASP Top 10 updates, framework advisories).

## Not secret storage

Do **not** put API keys, tokens, or production credentials in this repo—only patterns and process.
