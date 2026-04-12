# demo

Workspace for the **Pantheon** Cursor setup: orchestration rules, specialist agents, skills, hooks, and project memory.

| Path | Purpose |
| --- | --- |
| [.cursor/](.cursor/) | All Cursor-specific config (rules, agents, hooks, skills, commands). |
| [tasks/](tasks/) | Zeus memory layer: active work, lessons, architectural decisions. |
| [security-review/](security-review/) | Security slash-command backlog (`improvements-pending.md`); see `/cmd-review-project-security`. |

Start a session with **`/cmd-initiate`** (runs `.cursor/hooks/cmd-initiate.ps1`) to verify the tree and wake the orchestrator. See [.cursor/README.md](.cursor/README.md) for a map of what lives under `.cursor/`.
