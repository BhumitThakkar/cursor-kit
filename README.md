# cursor-kit

Single Git repository for Cursor-related assets, using the **same layout Cursor expects in a project** so cloning this repo and opening it in Cursor loads rules immediately—no copy-from-`Cursor/` workaround.

## Layout (canonical)

| Path | Use |
|------|-----|
| `.cursor/rules/*.mdc` | Project rules ([Cursor docs](https://cursor.com/docs/context/rules)) — YAML frontmatter (`description`, `globs` / `alwaysApply`) |
| `.cursor/skills/` | Agent skills, e.g. `<name>/SKILL.md` |
| `.cursor/commands/` | Custom command definitions you version |
| `.cursor/mcp/` | MCP notes, example configs, env templates (**no secrets**) |
| `.cursor/hooks/` | Hook scripts, CI safety scripts |

## Using this repo in an application project

**Option A — submodule:** Add this repo under your app (e.g. `.cursor-kit`) and symlink or script-copy `.cursor/rules` into the app root when you update.

**Option B — copy:** Copy `.cursor/rules` (and optionally other `.cursor/*` folders) into your app’s workspace root.

Opening **this** repository folder in Cursor applies rules here directly because `.cursor/rules` is at the repo root.

## Push to GitHub

1. Create an empty repository (any name, e.g. `cursor-kit`).
2. From this directory:

```powershell
cd D:\Website\cursor-kit
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
git branch -M main
git push -u origin main
```

If the local folder was ever named `cursor-rules`, rename it to match (`Rename-Item`) and add `git config --global --add safe.directory "D:/Website/cursor-kit"` if Git reports dubious ownership.
