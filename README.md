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

## Why the Windows folder might still be `cursor-rules`

The directory was created under that name when the repo only held rules. After the monorepo layout change, the **recommended** local name is `cursor-kit` (or `cursor-workspace`) so it matches the broader scope. Renaming was not forced earlier to avoid breaking your open editors, shortcuts, or `git` `safe.directory` entries without you noticing.

### Rename to `cursor-kit` (when nothing has the folder open)

If Windows says the folder is **in use**, close Cursor/VS Code (and any terminals `cd`’d into it), then:

```powershell
Rename-Item -Path "D:\Website\cursor-rules" -NewName "cursor-kit"
git config --global --add safe.directory "D:/Website/cursor-kit"
```

Then use `D:\Website\cursor-kit` in the commands below.

## Push to GitHub

1. Create a new empty repository (any name).
2. From this directory:

```powershell
cd D:\Website\cursor-rules
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
git push -u origin main
```

After you rename the folder, replace the `cd` path with `D:\Website\cursor-kit`.
