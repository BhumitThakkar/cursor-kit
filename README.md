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
| `security-review/cursorignore.example` | Template to copy as **`.cursorignore`** (keep secrets out of AI context) |
| `.cursor/commands/` | Slash commands — e.g. **`cmd-review-project-security`** → type `/` in Chat |
| `.cursor/mcp/` | MCP notes / examples — **no secrets** (`.gitkeep`) |
| **`.cursor/hooks.json`** | **Cursor lifecycle hooks** (beta): starts empty `{}`; see [Hooks docs](https://cursor.com/docs/hooks) |
| `.cursor/hooks/` | Optional scripts your `hooks.json` commands call; see `hooks/README.txt` |
| `.cursor/scope-check-log.md` | Traceability log (template / copy from IDScanner) |
| `.cursor/learning-log.md` | Improvement backlog notes |

## Rules

Bundled: **`security-review.mdc`** (see `security-review/security-review.md`). Add more `*.mdc` files under `.cursor/rules/` per [Cursor rules docs](https://cursor.com/docs/context/rules). Older personal rule sets (e.g. `cursor_rules`, `ui_design`) can be copied from your own backup if needed.

## Cursor hooks

- **File:** `.cursor/hooks.json` (project-level). The kit ships **`hooks: {}`** so the file exists and you can add entries without hunting the schema.
- **Scripts:** `.cursor/hooks/` is for small shell/PowerShell helpers you reference from `hooks.json` (paths depend on Cursor version—check docs).
- Feature is **beta**; validate after Cursor updates.

## Global Cursor profile vs this kit (parity)

Cursor merges **user-global** config under `%USERPROFILE%\.cursor\` with **project** `.cursor\` in the opened repo. They are not required to be identical.

| Item | Typical global (`%USERPROFILE%\.cursor\`) | In **cursor-kit** (this repo) |
|------|-------------------------------------------|-------------------------------|
| **`hooks.json`** | Often **many** lifecycle entries + `hooks\*.ps1` (e.g. deploy guards, subagent allow, noop)—your profile had **~23 hook commands** across events. | **Empty** `hooks: {}` starter + `hooks/README.txt` only. **Not a copy** of your global hooks. |
| **Commands** | May be absent or in UI-only | **1** file: `cmd-review-project-security` |
| **Skills** | Often **many** (e.g. architect, testing, hook-manager, orchestrator, …) | **3**: frontend-developer, backend-developer, security-reviewer |
| **Agents / “sub-agents”** | Often **many** stubs matching those skills | **3** + **Security reviewer** in `AGENTS.md` |
| **Rules** | User Rules in Settings + optional global files | **1** bundled: `security-review.mdc` |

**If you want cursor-kit to mirror your global hooks:** copy your `%USERPROFILE%\.cursor\hooks.json` and the **`hooks\` scripts it references** into this repo’s `.cursor\` (same relative paths like `./hooks/...`), then commit. Until then, **global hooks still run** when you use Cursor; this repo’s empty `hooks.json` only adds project-level hooks if you fill it in.

**If you want parity for skills/agents:** copy chosen trees from `%USERPROFILE%\.cursor\skills\<name>\` and `agents\<name>.md` into cursor-kit (and extend `AGENTS.md`), or keep them global-only to avoid duplicating 15+ roles in git.

## Push to GitHub

```powershell
cd D:\Website\cursor-kit
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
git branch -M main
git push -u origin main
```
