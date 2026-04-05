# Learning log (for later review or "apply learnings")

- **2026-04-04** | IDScanner: consider security backlog — env-based secrets, rotate Basic Auth + encryption key, re-enable CSRF or use token API auth, rate limits, dependency scan CI, protect delete-all, encrypt or restrict output/ PII.
- **2026-04-05** | When user asks to import rules from GitHub into a new folder under D:\Website, require the GitHub repo URL (and optional branch or subpath like `.cursor/rules`) before running `git clone` or sparse checkout.
- **2026-04-05** | If user has no GitHub repo yet: scaffold `D:\Website\cursor-rules` with `.cursor/rules`, seed from `Cursor Rules\old` if present, `git init` + `main`, add `safe.directory` if Git reports dubious ownership on that drive; document push via empty GitHub repo + `git remote add` / optional `gh repo create`.
- **2026-04-05** | Prefer one monorepo for Cursor assets under repo-root `.cursor/` (`rules`, `skills`, `commands`, `mcp`, `hooks`) over N repos; local Windows folder name can differ from GitHub repo name.
- **2026-04-05** | Renaming `D:\Website\cursor-rules` on Windows can fail with "in use" if Cursor/terminals hold the path; document close-then-`Rename-Item` and add new `safe.directory` after rename.
- **2026-04-05** | `cursor-kit` uses canonical `.cursor/rules` at repo root so clone-and-open picks up rules; avoid parallel `Cursor/cursor-rules` unless mirroring for non-Cursor consumers.
- **2026-04-05** | Cursor loads project rules from the **opened workspace** path `.cursor/rules/*.mdc` (plus legacy `.cursorrules`, `AGENTS.md` per product); a GitHub "rules library" repo must copy/symlink/submodule into each app's `.cursor/rules` unless the library repo root itself uses `.cursor/rules` and is the folder you open.
- **2026-04-05** | Windows: New-Item directory creation failed with -LiteralPath (not a valid parameter in this host); use -Path instead when scripting moves for cursor-kit.
- **2026-04-05** | Consider documenting standard .cursor subdirs (commands, skills, mcp, hooks) vs legacy Cursor/cursor-* in project kit docs.
- **2026-04-05** | For repos outside the active workspace (e.g. `D:\Website\cursor-kit`), shell subagent can run `Move-Item`/`git commit` when in-sandbox shell does not persist to disk.
- **2026-04-05** | When comparing `cursor-kit` to a project, list IDScanner `.cursor` agents/skills/logs and user-global `~/.cursor/skills` as "configured elsewhere" if absent from the kit.
