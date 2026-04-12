# `tasks/` — Zeus memory layer

Long-lived markdown Zeus and hooks maintain across sessions (see `memory.mdc` in [.cursor/rules/](../.cursor/rules/)).

| File | Role |
| --- | --- |
| `todo.md` | Active task checklists, session markers (`<!-- session-end -->`). |
| `lessons.md` | Prevention rules after mistakes or gate failures. |
| `decisions.md` | Architectural / tooling ADR-style decisions. |

Optional logs (may be created by hooks, often gitignored elsewhere): e.g. `mcp-audit.log`, `deploy-rollback.log` at repo root or under `tasks/` depending on hook configuration.
