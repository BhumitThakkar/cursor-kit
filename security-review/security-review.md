# Security review (cursor-kit)

Git-tracked entry point for **security-conscious development**. Cursor picks up the machine-readable rule from `.cursor/rules/`; depth lives in the **security-reviewer** skill.

## Where things live

| Artifact | Path |
|----------|------|
| Cursor rule (`.mdc`) | `.cursor/rules/security-review.mdc` |
| Skill (checklists, OWASP-aligned guidance) | `.cursor/skills/security-reviewer/SKILL.md` |
| Agent stub | `.cursor/agents/security-reviewer.md` |

## Using this in a project

1. Copy or submodule **cursor-kit** into your app, **or** copy only `.cursor/rules/security-review.mdc` and `.cursor/skills/security-reviewer/` (and optionally the agent + `AGENTS.md` rows).
2. Open the **project** workspace in Cursor so `.cursor/rules` applies to that repo.
3. Refresh the skill when major standards shift (OWASP Top 10 updates, framework advisories).

## Not secret storage

Do **not** put API keys, tokens, or production credentials in this repo—only patterns and process.
