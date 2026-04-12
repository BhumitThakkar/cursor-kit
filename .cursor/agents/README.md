# `agents/` — Subagent definitions

One **`.md` file per specialist** (YAML frontmatter: `name`, `description`, `model`, `readonly`, `is_background`). Cursor / Zeus uses these to choose delegation targets.

| Kind | Examples |
| --- | --- |
| Implementation | `backend-dev`, `frontend-dev`, `qa-engineer`, `devops-engineer` |
| Review / design | `architect`, `security-auditor`, `security-reviewer`, `code-reviewer` |
| Meta | `builder`, `zeus-pm`, `skills-manager`, `rules-manager`, `hook-manager`, `commands-manager`, `subagents-manager` |
| Extended roster | `requirements-analyst`, `api-contract`, `database`, `debugging`, `documentation`, `self-improvement` |

**`disabled.txt`** — optional list: one agent **stem** per line (e.g. `qa-engineer`) to temporarily disable without deleting files.

Pair each agent with matching guidance in [../skills/](../skills/) where a skill folder exists.
