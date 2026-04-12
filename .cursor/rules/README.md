# `rules/` — Cursor rules (`.mdc`)

Markdown-with-frontmatter files Cursor applies according to **`alwaysApply`** and **`globs`**. These define **Pantheon** behaviour: orchestration, gates, memory, and tooling registry.

| File | Purpose |
| --- | --- |
| `zeus-pm.mdc` | Zeus orchestrator: classification, delegation, gates, safeguards. |
| `quality-gates.mdc` | Definition of “done” per output type (backend, frontend, QA, security, DevOps, builder). |
| `agent-roster.mdc` | Canonical list of agents and domains. |
| `memory.mdc` | Protocol for `tasks/todo.md`, `lessons.md`, `decisions.md`. |
| `tool-registry.mdc` | Single table of skills, hooks, commands, subagents, status. |
| `on-the-fly-protocol.mdc` | How to create and register missing tools. |
| `sovereign-dev-manifesto.mdc` | Workflow and engineering principles (Zeus-adopted companion). |
| `wheel-of-problem-solving.mdc` | Strategic problem decomposition — Wheel (Zeus-adopted companion). |

Do not put secrets in rules. Prefer updating an existing rule over duplicating policy.
