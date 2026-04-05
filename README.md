# cursor-rules

Shared [Cursor](https://cursor.com) project rules (`.cursor/rules/*.mdc`). Copy or symlink `.cursor` into any project, or add this repo as a submodule.

## Create the GitHub repository and push

1. On GitHub: **New repository** → name it (e.g. `cursor-rules`) → create **without** README (this folder already has one).
2. In PowerShell:

```powershell
cd D:\Website\cursor-rules
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
git branch -M main
git push -u origin main
```

Optional: install [GitHub CLI](https://cli.github.com/) and run `gh repo create YOUR_USER/cursor-rules --public --source=. --remote=origin --push` from this directory.
