# Security review bundle (Pantheon)

Workspace entry point for **security-conscious development**. Cursor loads the rule from `.cursor/rules/security-review.mdc` (scoped by globs); detailed guidance lives in the **security-reviewer** skill. Formal gate-style reviews may still go through **security-auditor**.

## Where things live

| Artifact | Path |
| --- | --- |
| Cursor rule (`.mdc`) | `.cursor/rules/security-review.mdc` |
| Skills (ordered) | **L0** `.cursor/skills/security-reviewer/SKILL.md` → **L1** `.cursor/skills/owasp-checklist/SKILL.md` when Java/Spring is present (see L0 **Knowledge hierarchy**) |
| Agent | `.cursor/agents/security-reviewer.md` |
| Slash command (full workspace) | `.cursor/commands/cmd-review-project-security.md` |
| Slash command (diff / scoped) | `.cursor/commands/cmd-security-scan.md` |
| Pending backlog | `security-review/improvements-pending.md` |
| Example `.cursorignore` | `security-review/cursorignore.example` |

## How you trigger it

| Trigger | When it runs |
| --- | --- |
| **Rule** (`security-review.mdc`, `alwaysApply: false` + globs) | Included when working on matching code/config files. |
| **Slash command** | **`/cmd-review-project-security`** — full workspace + backlog. **`/cmd-security-scan`** — diff or scoped paths; chat required, backlog optional with `(diff)` in the title. |

## Rule location: canonical vs import

Same guidance as cursor-kit: prefer **`.cursor/rules/security-review.mdc`**. If you use GitHub/GitLab rule import, you may have **`.cursor/rules/imported/<source>/…`** — mirror or symlink to canonical path to keep cross-references stable.

## Not secret storage

Do **not** put API keys, tokens, or production credentials in these markdown files—only process and findings metadata.
