# `.cursor/` — Pantheon framework

High-level map of this directory (Cursor loads rules and can invoke commands/hooks defined here).

| Item | Role |
| --- | --- |
| [rules/](rules/) | `.mdc` policies: Zeus, quality gates, roster, memory protocol, tool registry, etc. |
| [agents/](agents/) | Subagent briefs (`.md` with YAML frontmatter) — who to delegate to. |
| [skills/](skills/) | Reusable `SKILL.md` playbooks agents load for implementation detail. |
| [hooks/](hooks/) | PowerShell hook scripts + `hooks.json` wiring (session, shell, MCP, edit, …). |
| [commands/](commands/) | Slash commands (e.g. `/cmd-initiate`, `/cmd-review-project-security`). |
| `AGENTS.md` | Human-readable roster index and workflow summary. |
| `learning-log.md` | Batch queue for self-improvement / apply-learnings workflow. |
| `hooks.json` | Registers which script runs on which Cursor lifecycle events. |
| `folder-structure.md` | Longer ASCII tree of the same layout (reference). |

Subfolders each have their own **README.md** with a short file guide.
