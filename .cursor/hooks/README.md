# `hooks/` — Cursor lifecycle scripts (PowerShell)

Scripts are invoked by [../hooks.json](../hooks.json). Most read **JSON from stdin** and print **JSON on stdout** (see Cursor hooks docs). Exit codes matter for wrappers like `run-before-hook.ps1`.

| Script | Typical event | Role (short) |
| --- | --- | --- |
| `session-init.ps1` | sessionStart | Inject `tasks/` memory into `additional_context`. |
| `task-close.ps1` | stop | Append session marker to `tasks/todo.md`. |
| `subagent-trace.ps1` | subagentStart | Log which subagent was spawned to `tasks/subagent-trace.log`. |
| `gate-check.ps1` | preToolUse | Remind agents of quality gates before Write/Shell. |
| `cursor-decision-allow.ps1` | preToolUse / subagentStart | Default allow JSON. |
| `quality-check.ps1` | afterFileEdit | Java heuristics + secret-pattern block. |
| `security-guard.ps1` | beforeShellExecution | Block dangerous shell patterns. |
| `run-before-hook.ps1` + inner `*.ps1` | beforeShellExecution | Kill switch, deploy rate limit, pre-merge tests. |
| `mcp-audit.ps1` | beforeMCPExecution | Log MCP; block prod writes. |
| `cursor-allow.ps1` | beforeShell / beforeMCP / beforeReadFile | Pass-through allow. |
| `cursor-continue.ps1` | beforeSubmitPrompt | `{ "continue": true }`. |
| `run-after-hook.ps1` + `rollback-on-test-failure.ps1` | afterShellExecution | Log rollback reminder after deploy-class commands. |
| `cmd-initiate.ps1` | *(manual / command)* | Full Pantheon file tree validation. |
| `emergency-kill.ps1` | *(manual)* | Create/remove repo-root `.kill-switch`. |
| `install-dependency-check.ps1` | *(manual/setup)* | Reserve `.cursor/tools` for OWASP Dependency-Check. |

Ephemeral / local: `.pantheon-deploy-log.txt` (deploy counter), may appear after rate-limit hook runs.
