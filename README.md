# Shared Cursor configuration

This repository holds a **portable** Cursor setup: **agents**, **skills**, **hooks**, optional **rules**, commands, and MCP notes. The `.cursor/` tree can **vendor** a maintainer’s global `%USERPROFILE%\.cursor\` roster (skills, agents, hooks, `system_flow`, `AGENTS.md`) for portability.

**Cursor “User rules” in Settings** are not stored under `%USERPROFILE%\.cursor\rules\` (and are not part of that vendor sync). Project rules live in **`.cursor/rules/*.mdc`**. Bundled examples include general discipline rules plus **`security-review.mdc`**; optional extras include the **security-reviewer** agent/skill and the **`cmd-review-project-security`** slash command.

## Layout

| Path | Contents |
|------|----------|
| `.cursor/AGENTS.md` | Agent priority and workflow |
| `.cursor/agents/*.md` | Agent stubs (link to skills) |
| `.cursor/skills/*/` | `SKILL.md` per skill (library may be synced from global; may add **`security-reviewer`**) |
| `.cursor/rules/` | Cursor rules (`*.mdc`): e.g. **`cursor_rules`**, **`development_standards`**, **`important`**, **`ui_design`**, **`security-review`** |
| `security-review/security-review.md` | Security bundle index (**canonical vs GitHub-imported rule paths**) |
| `security-review/improvements-pending.md` | Checkbox backlog updated by **`/cmd-review-project-security`** |
| `security-review/cursorignore.example` | Template → **`.cursorignore`** at project root |
| `.cursor/commands/` | Slash commands (e.g. **`cmd-review-project-security`**) |
| `.cursor/mcp/` | MCP notes / examples — **no secrets** (`.gitkeep`) |
| **`.cursor/hooks.json`** | Cursor lifecycle hooks (beta); may be synced from global |
| `.cursor/hooks/` | Hook scripts; see `hooks/README.md` / `README.txt` |
| `.cursor/scope-check-log.md` | Traceability log (template) |
| `.cursor/learning-log.md` | Improvement backlog notes |

## Rules

See `security-review/security-review.md` for how **`security-review.mdc`** interacts with **GitHub/GitLab rule import** vs **canonical** `.cursor/rules/security-review.mdc`. Add more `*.mdc` per [Cursor rules docs](https://cursor.com/docs/context/rules).

## Cursor hooks

- **File:** `.cursor/hooks.json` (project-level). After a **global→bundle sync**, align with your global hooks; merge if the project already defines hooks.
- **Scripts:** `.cursor/hooks/` — paths like `./hooks/...` work when this folder ships with the repo.
- Feature is **beta**; validate after Cursor updates.

## Global profile vs this bundle (parity)

This bundle can **vendor** `%USERPROFILE%\.cursor\` so you can bootstrap a machine or project. Typical refreshed trees: **`skills/`**, **`agents/`**, **`hooks/`**, **`hooks.json`**, **`system_flow/`**, **`AGENTS.md`**.

**Use it:** Copy or symlink this repo’s **`.cursor/`** into a project root (merge with local rules/commands), or merge into **global** `%USERPROFILE%\.cursor\`.

| Item | Typical global (`%USERPROFILE%\.cursor\`) | In this repository |
|------|-------------------------------------------|---------------------|
| **`AGENTS.md`** | Priority / workflow | Synced from global + optional **## Optional extensions (security bundle)** |
| **`skills/`** | Full library | Synced; may retain **`security-reviewer`** if absent globally |
| **`agents/`** | Agent stubs | Synced; **`security-reviewer.md`** may be bundle-only |
| **`hooks.json` + `hooks/`** | Lifecycle hooks | Synced from global when refreshed |
| **`system_flow/`** | Diagrams / notes | Synced when present |
| **Commands / rules** | Varies | Ships **`cmd-review-project-security`**, **`security-review.mdc`**, and other bundled rules |

Cursor **merges** global `%USERPROFILE%\.cursor\` with the project’s `.cursor\`.

## Push to a remote

```powershell
cd <path-to-this-repo-clone>
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
git branch -M main
git push -u origin main
```
