# cursor-kit

Shared Cursor configuration: **agents**, **skills**, optional **rules**, and placeholders for commands, MCP, and hooks. Sourced from the IDScanner project layout (`AGENTS.md`, `agents/`, `skills/`, logs) unless noted.

## Layout

| Path | Contents |
|------|----------|
| `.cursor/AGENTS.md` | Agent priority and workflow |
| `.cursor/agents/*.md` | Agent stubs (link to skills) |
| `.cursor/skills/*/` | `SKILL.md` per skill (IDScanner Spring Boot stack) |
| `.cursor/rules/` | Add your own `*.mdc` rules here (folder kept via `.gitkeep`; none bundled) |
| `.cursor/commands/` | Custom commands (`.gitkeep` placeholder) |
| `.cursor/mcp/` | MCP notes / examples — **no secrets** (`.gitkeep`) |
| `.cursor/hooks/` | Hook scripts (`.gitkeep`) |
| `.cursor/scope-check-log.md` | Traceability log (template / copy from IDScanner) |
| `.cursor/learning-log.md` | Improvement backlog notes |

## Rules

This repo **does not** ship the former `cursor_rules`, `important`, `ui_design`, or `development_standards` `.mdc` files. Add rule files under `.cursor/rules/` per [Cursor rules docs](https://cursor.com/docs/context/rules), or copy them from your own backup (e.g. `D:\Website\Cursor Rules\old\`).

## Push to GitHub

```powershell
cd D:\Website\cursor-kit
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
git branch -M main
git push -u origin main
```
