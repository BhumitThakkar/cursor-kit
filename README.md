# cursor-kit

Shared Cursor configuration: **agents**, **skills**, **hooks**, optional **rules**, commands, and MCP notes. The `.cursor/` tree **vendors** the maintainer’s global `%USERPROFILE%\.cursor\` roster (skills, agents, hooks, `system_flow`, `AGENTS.md`) for portability; kit-only extras include **security-review** rules/commands and **security-reviewer** agent/skill when not present globally.

## Layout

| Path | Contents |
|------|----------|
| `.cursor/AGENTS.md` | Agent priority and workflow |
| `.cursor/agents/*.md` | Agent stubs (link to skills) |
| `.cursor/skills/*/` | `SKILL.md` per skill (full library synced from global; kit may add **`security-reviewer`**) |
| `.cursor/rules/` | Cursor rules (`*.mdc`); includes **`security-review.mdc`** (always-on security discipline) |
| `security-review/security-review.md` | Human-readable index for the security review bundle |
| `security-review/improvements-pending.md` | Checkbox backlog updated by **`/cmd-review-project-security`** |
| `security-review/cursorignore.example` | Template to copy as **`.cursorignore`** (keep secrets out of AI context) |
| `.cursor/commands/` | Slash commands — e.g. **`cmd-review-project-security`** → type `/` in Chat |
| `.cursor/mcp/` | MCP notes / examples — **no secrets** (`.gitkeep`) |
| **`.cursor/hooks.json`** | **Cursor lifecycle hooks** (beta): **synced from global** when you refresh the kit; see [Hooks docs](https://cursor.com/docs/hooks) |
| `.cursor/hooks/` | Scripts referenced by `hooks.json` (synced from global); see `hooks/README.md` / `README.txt` |
| `.cursor/scope-check-log.md` | Traceability log (template / copy from IDScanner) |
| `.cursor/learning-log.md` | Improvement backlog notes |

## Rules

Bundled: **`security-review.mdc`** (see `security-review/security-review.md`). Add more `*.mdc` files under `.cursor/rules/` per [Cursor rules docs](https://cursor.com/docs/context/rules). Older personal rule sets (e.g. `cursor_rules`, `ui_design`) can be copied from your own backup if needed.

## Cursor hooks

- **File:** `.cursor/hooks.json` (project-level). After a **global→kit sync**, this file matches the maintainer’s global hooks wiring; merge carefully if your project already defines hooks.
- **Scripts:** `.cursor/hooks/` holds PowerShell/shell helpers that `hooks.json` invokes (relative paths like `./hooks/...` are valid when this folder ships with the repo).
- Feature is **beta**; validate after Cursor updates.

## Global Cursor profile vs this kit (parity)

This kit **vendors** a portable copy of the user-global Cursor roster under `%USERPROFILE%\.cursor\` so you can move between machines or bootstrap a project without retyping setup. Refreshed trees include **`skills/`**, **`agents/`**, **`hooks/`**, **`hooks.json`**, **`system_flow/`**, and **`AGENTS.md`** (overwrite from global when re-syncing the kit).

**Using the kit:** Copy or symlink this repository's **`.cursor/`** into your project's repo root (merge with any project-specific `.cursor/rules`, `.cursor/commands`, etc.), or merge these folders into your **global** `%USERPROFILE%\.cursor\` profile if you prefer one machine-wide roster.

| Item | Typical global (`%USERPROFILE%\.cursor\`) | In **cursor-kit** (this repo) |
|------|-------------------------------------------|-------------------------------|
| **`AGENTS.md`** | Priority order and workflow | **Synced** from global (plus optional **## cursor-kit extensions** for kit-only extras). |
| **`skills/`** | Full skill library | **Synced** from global; kit may retain **`security-reviewer`** if absent from global. |
| **`agents/`** | Agent stubs | **Synced** from global; **`security-reviewer.md`** may remain kit-only. |
| **`hooks.json` + `hooks/`** | Lifecycle hooks and scripts | **Synced** from global (projects may still add or merge entries). |
| **`system_flow/`** | Diagram templates / notes | **Synced** from global when present. |
| **Commands / rules** | Varies | Kit still ships **`cmd-review-project-security`** and **`security-review.mdc`** (not replaced by global sync). |

When Cursor opens a project, it **merges** user-global `%USERPROFILE%\.cursor\` with the project's `.cursor\`. Pointing a project at this kit's `.cursor` gives you the vendored roster **and** Cursor still applies your global User Rules unless you override locally.

## Push to GitHub

```powershell
cd D:\Website\cursor-kit
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
git branch -M main
git push -u origin main
```
