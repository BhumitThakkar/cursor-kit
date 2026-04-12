# `commands/` — Slash commands

Cursor **project commands** (triggered with `/` in chat). Each file describes when to run the command and what to execute.

| File | Summary |
| --- | --- |
| `cmd-initiate.md` | **Boot / health check** — run `cmd-initiate.ps1` from repo root to validate rules, agents, skills, hooks, and `tasks/` memory files. |
| `cmd-review-project-security.md` | **Security pass** — OWASP-style review of the workspace; appends structured backlog to `security-review/improvements-pending.md`. |
| `cmd-security-scan.md` | **Diff security** — OWASP-style review on changed or scoped files; optional backlog with `(diff)` subtitle. |
| `cmd-dependency-audit.md` | **Dependencies** — manifest / lockfile / SCA recommendations (DevOps). |
| `cmd-uml-diagrams.md` | **UML / Mermaid** — ensures `uml-diagrams/` and refreshes ER, use case, flow, and sequence diagrams from the codebase. |
| `Bhumitra.md` | **Zeus PM** — `/Bhumitra [task…]` loads `zeus-pm.mdc` + `zeus-pm.md` and runs classification, delegation, gates, and memory protocol for any task. |

### Security commands (when to use which)

| Command | Use when | Backlog file |
| --- | --- | --- |
| **`/cmd-review-project-security`** | Full-workspace (or broad path) OWASP-style pass; periodic / release audits | **Always** updates `security-review/improvements-pending.md` |
| **`/cmd-security-scan`** | PR / diff / explicitly scoped files only; same L0→L1 skill idea, less noise | **Optional**; if you log findings, use a `## Review — … (diff)` title so it is distinct from full reviews |

Both load **`security-reviewer`** then **`owasp-checklist`** when Java/Spring is in scope (see each command file).

Add new commands here as separate `.md` files; register any new automation in [tool-registry](../rules/tool-registry.mdc) when Zeus adopts it.
