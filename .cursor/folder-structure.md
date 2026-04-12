.cursor/
│
├── rules/                                  # .mdc extension — Cursor standard
│   ├── sovereign-dev-manifesto.mdc         # How to behave        | alwaysApply: true
│   ├── wheel-of-problem-solving.mdc        # Strategic thinking     | alwaysApply: true
│   ├── zeus-pm.mdc                         # Orchestrator         | alwaysApply: true
│   ├── agent-roster.mdc                    # Agent definitions    | alwaysApply: true
│   ├── on-the-fly-protocol.mdc             # Self-repair engine   | alwaysApply: true
│   ├── memory.mdc                          # Persistence protocol | alwaysApply: true
│   ├── quality-gates.mdc                   # Done criteria        | alwaysApply: true
│   └── tool-registry.mdc                   # Tools/skills/hooks registry        | alwaysApply: false
│
├── agents/                                 # Cursor subagents — isolated context windows
│   ├── backend-dev.md                      # Senior Java/Spring Boot developer
│   ├── frontend-dev.md                     # Thymeleaf/HTML/CSS/JS developer  [to build]
│   ├── qa-engineer.md                      # JUnit 5 + Mockito + TestContainers [to build]
│   ├── security-auditor.md                 # OWASP reviewer                    [to build]
│   ├── code-reviewer.md                    # Elegance + SOLID enforcer          [to build]
│   ├── devops-engineer.md                  # Docker + Azure + CI/CD             [to build]
│   ├── architect.md                        # System design + ADR writer         [to build]
│   ├── builder.md                          # On-the-fly tool/agent creator
│   ├── zeus-pm.md                          # Zeus delegation brief
│   ├── requirements-analyst.md             # Stories / acceptance
│   ├── api-contract.md                     # OpenAPI / contracts
│   ├── database.md                       # PostgreSQL / Liquibase
│   ├── debugging.md                      # Root-cause analysis
│   ├── documentation.md                  # Docs / runbooks
│   ├── self-improvement.md               # Metrics / learning log
│   ├── skills-manager.md                 # SKILL.md lifecycle
│   ├── rules-manager.md                  # .mdc rules lifecycle
│   ├── hook-manager.md                   # Hook scripts lifecycle
│   ├── commands-manager.md               # Runnable commands
│   ├── subagents-manager.md              # AGENTS.md + disabled.txt
│   └── disabled.txt                      # Optional: one agent stem per line to disable
│
├── skills/                                 # Reusable knowledge — loaded dynamically
│   ├── spring-boot-patterns/
│   │   └── SKILL.md                        # Spring Boot coding standards (built)
│   ├── thymeleaf-patterns/
│   │   └── SKILL.md                        # Thymeleaf conventions              [to build]
│   ├── owasp-checklist/
│   │   └── SKILL.md                        # OWASP Top 10 security checks       [to build]
│   └── mermaid-diagrams/
│       └── SKILL.md                        # Mermaid diagram generation rules   [to build]
│
├── hooks/                                  # PowerShell — triggered by hooks.json
│   ├── session-init.ps1                    # sessionStart — memory context JSON
│   ├── task-close.ps1                      # stop — session marker in tasks/todo.md
│   ├── on-task-close.ps1                   # stop — completed → lesson stub in tasks/lessons.md
│   ├── quality-check.ps1                   # afterFileEdit — Java + secret heuristics
│   ├── security-guard.ps1                  # beforeShellExecution — dangerous cmd blocks
│   ├── mcp-audit.ps1                       # beforeMCPExecution — log + prod write block
│   ├── gate-check.ps1                      # preToolUse — gate reminders
│   ├── cmd-initiate.ps1                    # /cmd-initiate — full boot validator
│   ├── run-before-hook.ps1                 # Wrapper for policy scripts (allow/deny JSON)
│   ├── run-after-hook.ps1                  # Post-shell follow-up runner
│   ├── check-kill-switch.ps1               # Deny if .kill-switch exists
│   ├── deploy-rate-limit.ps1               # Max deploy-class actions per day
│   ├── emergency-kill.ps1                  # Toggle .kill-switch
│   ├── pre-merge-checks.ps1                # Tests before git push/merge
│   ├── rollback-on-test-failure.ps1        # Post-deploy rollback log hint
│   ├── cursor-allow.ps1 / cursor-noop.ps1 / cursor-continue.ps1 / cursor-decision-allow.ps1
│   └── install-dependency-check.ps1        # Reserves .cursor/tools for OWASP DC
│
├── hooks.json                              # Wires hooks to their shell scripts
└── mcp.json                                # MCP server connections

tasks/
├── todo.md
├── lessons.md
├── decisions.md
└── mcp-audit.log                           # auto-created by hook, add to .gitignore
