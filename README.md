# Cursor tooling (monorepo)

One Git repository for everything you sync or copy from GitHub related to [Cursor](https://cursor.com): rules, commands, skills, MCP config notes, hooks, etc. You do **not** need a separate repo per entity—use folders under `Cursor/` for clear separation.

## Layout

| Folder | Typical use |
|--------|-------------|
| `Cursor/cursor-rules/` | `.mdc` rule files → copy into a project’s `.cursor/rules/` |
| `Cursor/cursor-commands/` | Custom commands / snippets you version |
| `Cursor/cursor-skills/` | Shared `SKILL.md` trees or exports |
| `Cursor/cursor-mcps/` | MCP server configs, env templates (no secrets) |
| `Cursor/cursor-hooks/` | Hook scripts, CI checks, safety scripts |

## Using rules in a project

Copy (or symlink) the contents of `Cursor/cursor-rules/` into your app’s `.cursor/rules/`, or submodule this repo and point tooling at the subpath.

## Why the folder is still `cursor-rules` on disk

The **local path** `D:\Website\cursor-rules` was created first as a rules-only scaffold. The **repository content** is now the wider monorepo above. On GitHub you can name the remote anything you prefer, for example `cursor-kit`, `cursor-workspace`, or `cursor-tooling`.

## Push to GitHub

1. Create a new empty repository (any name).
2. From this directory:

```powershell
cd D:\Website\cursor-rules
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
git push -u origin main
```

Optional: rename the local folder to match (`Rename-Item` to e.g. `cursor-kit`) after adding `remote`; Git does not care about the parent folder name.
