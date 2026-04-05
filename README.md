# cursor-kit

Shared Cursor configuration: **agents**, **skills**, optional **rules**, and placeholders for commands, MCP, and hooks. Sourced from the IDScanner project layout (`AGENTS.md`, `agents/`, `skills/`, logs) unless noted.

## Layout

| Path | Contents |
|------|----------|
| `.cursor/AGENTS.md` | Agent priority and workflow |
| `.cursor/agents/*.md` | Agent stubs (link to skills) |
| `.cursor/skills/*/` | `SKILL.md` per skill (IDScanner Spring Boot stack) |
| `.cursor/rules/` | Cursor rules (`*.mdc`); includes **`security-review.mdc`** (always-on security discipline) |
| `security-review/security-review.md` | Human-readable index for the security review bundle |
| `security-review/improvements-pending.md` | Checkbox backlog updated by **`/cmd-review-project-security`** |
| `.cursor/commands/` | Slash commands — e.g. **`cmd-review-project-security`** → type `/` in Chat |
| `.cursor/mcp/` | MCP notes / examples — **no secrets** (`.gitkeep`) |
| `.cursor/hooks/` | Hook scripts (`.gitkeep`) |
| `.cursor/scope-check-log.md` | Traceability log (template / copy from IDScanner) |
| `.cursor/learning-log.md` | Improvement backlog notes |

## Rules

Bundled: **`security-review.mdc`** (see `security-review/security-review.md`). Add more `*.mdc` files under `.cursor/rules/` per [Cursor rules docs](https://cursor.com/docs/context/rules). Older personal rule sets (e.g. `cursor_rules`, `ui_design`) can be copied from your own backup if needed.

## Push to GitHub

```powershell
cd D:\Website\cursor-kit
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
git branch -M main
git push -u origin main
```
