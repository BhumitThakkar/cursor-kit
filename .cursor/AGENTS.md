# Multi-Agent Framework – Index

This document indexes all **agents**, **skills**, **tools**, and **safety mechanisms** for the Cursor multi-agent setup. Use it to choose the right agent or to wire orchestrator workflows.

## Priority order

1. **Primary goal:** The system (agents, skills, framework) must **improve over time, not degrade.** Every prompt is an opportunity to strengthen the roster, fill gaps, and improve skills.
2. **Secondary goal:** Serve the user’s prompt well — using the right agents, clear handoffs, and quality output.

**Metaphor:** A well micro-managed enterprise. Every type of employee (agent) is present. They share information when needed and are eager to help each other grow the quality of the enterprise. If a role is missing, we add it. If a role is underpowered for the task, we improve it. Then we do the work.

Agents are roles (same model, different context and instructions). System improvement comes from consistent process, skill quality, and metrics — not from distinct model capabilities.

## Workflow on each prompt

Before answering:

1. **Decide which subagent(s) are needed** for this type of request (scope: AGENTS.md + each skill’s When to Use). Use the **Definition of “needed”** below.
2. **If a needed agent is absent** → Add them: create `.cursor/agents/<name>.md` and `.cursor/skills/<name>/SKILL.md`; update AGENTS.md (use SubAgentsManager + SkillsManager).
3. **If a needed agent exists but the skill is weak** for this task (e.g. missing steps, vague “When to Use”) → Improve that skill or agent file.
4. **Then** do the scope check, use the relevant agent(s)/skill(s), and answer the prompt.

So: first ensure the roster is complete and strong; then use it.

### Definition of “needed” agent

An agent is **needed** for this request if the request involves: building or changing code (any layer), UI, API, database, tests, security, deploy, documentation, or managing the framework (rules, skills, hooks, agents). If the request involves any of these, at least one agent is needed; do not answer as Main only without having considered the Quick reference and each relevant skill’s When to Use.

## When to use subagents

**Decision rule:** For each request, check whether it falls within any agent’s scope. If yes → use that agent/skill (read it, act in role, list in usage block). If no → handle as Main only.

1. **Scope is defined by:** (a) the **Primary use** column in the Quick reference table below, and (b) each skill’s **When to Use** in `.cursor/skills/<agent-name>/SKILL.md`.
2. **Match:** If the user’s request is about or involves that topic (e.g. “add a form” → Frontend; “design the API” → API Contract + maybe Architect; “why did the build fail?” → Debugging), the request is **in scope** for that agent → use the subagent.
3. **No match:** If the request is a general question, meta-discussion, or something that doesn’t fit any agent’s “Primary use” or “When to Use” → no subagent; Main only is correct.
4. **When in doubt:** Prefer using a matching agent/skill rather than skipping it.

## Quick reference

| Agent | Primary use | Tools | Key safety |
|-------|-------------|-------|------------|
| **Orchestrator** | Pipeline coordination, rollback, retry, throttle | Cursor | 3 retries → alert; auto-rollback on test failure; kill switch; 10 deploys/day max |
| **Architect** | System design, ADRs, C4/sequence diagrams | Mermaid | ADR for decisions; API versioning; deprecation notices |
| **Requirements Analyst** | User stories, acceptance criteria, Jira | Jira | Spec before dev; requirements linked to metrics; 90-day unused flag |
| **API Contract** | OpenAPI 3.0, DTOs, Postman, contract tests | Postman | Contract-first; breaking change detection; consumer tests |
| **Backend Developer** | Spring Boot, JPA, Security, Liquibase, async | Cursor | Rate limit, no SQL injection, CORS, N+1 check, /api/v1/, Optional |
| **Frontend Developer** | Thymeleaf, Bootstrap 5, forms, i18n | Thymeleaf, Bootstrap | XSS/CSRF; CSP; WCAG 2.1 AA; page load <3s |
| **Database** | PostgreSQL, Liquibase, indexing, backup | Supabase | Daily backup; migration rollback; pool limits; FKs enforced |
| **Code Review** | Static analysis, security, complexity, coverage | Custom/Cursor | Security 100% pass; no coverage drop; method ≤50 lines; perf regression blocks |
| **Testing** | JUnit 5, Mockito, Testcontainers, Pact, load | Mockito, JUnit 5, TestContainers | 85% coverage; critical path integration; failed tests block deploy |
| **Debugging** | Log correlation, root cause, safe-pattern fix | Custom/Cursor | Auto-fix only safe patterns; unknown → ticket; perf fixes benchmarked |
| **Security** | OWASP, dependency check, secrets, compliance | OWASP Dependency-Check | Zero critical vulns; secrets = block; compliance fail = rollback; quarterly audit |
| **DevOps** | Blue-green, Docker, health checks, backup, DR | Docker, Docker Compose | Blue-green; health 30s; auto-rollback on error spike; daily backup verify; monthly DR |
| **Documentation** | Swagger, runbooks, changelog, migration guide | Swagger UI | Docs from code; breaking changes in migration guide; outdated flagged |
| **Self-Improvement** | Agent metrics, learning, A/B test, feedback | Custom/Cursor | Monthly report; disable if <70% success; quarterly human review of patterns |
| **SkillsManager** | Create, update, list Cursor skills (SKILL.md) | Cursor | No edit of skills-cursor/; valid frontmatter; idempotent updates |
| **CommandsManager** | Define, register, run project commands (scripts, Maven, npm) | Cursor | Document side effects; exit codes; no blind prod execution |
| **RulesManager** | Create, update, list Cursor rules (.mdc) | Cursor | Valid frontmatter; no secrets in rules; idempotent updates |
| **HookManager** | Create, update, list, wire safety hooks (pre-merge, rate limit, kill switch) | Cursor | No silent bypass; document exit codes and wiring |
| **SubAgentsManager** | List, enable/disable, configure sub-agents; maintain AGENTS.md | Cursor | No delete without consent; index accuracy; Orchestrator-aware disable |

## Framework managers (meta-agents)

**SkillsManager**, **CommandsManager**, **RulesManager**, **HookManager**, and **SubAgentsManager** manage the framework itself (skills, commands, rules, hooks, and the agent roster). Use them when adding or changing how agents and automation are configured, not for application feature work.

## Agent files

- **Location**: `.cursor/agents/*.md`
- **Invocation**: In Cursor, reference by agent name (e.g. "Act as the Architect agent") or via Orchestrator workflow.

## Skills

- **Location**: `.cursor/skills/<agent-name>/SKILL.md`
- **Purpose**: Step-by-step instructions and checklists for each agent domain. Cursor uses these when the skill is relevant to the task.

## Hooks (safety scripts)

- **Location**: `.cursor/hooks/`
- **Purpose**: Scripts to enforce deploy rate limit, rollback on test failure, emergency kill, and other guardrails. Wire into CI or git hooks as needed.
- **Setup**: See `.cursor/hooks/README.md`.

## Orchestrator workflow (example)

1. **Requirements Analyst** → user stories + acceptance criteria → Jira.
2. **API Contract** → OpenAPI + Postman; contract tests.
3. **Architect** → ADR + C4/sequence if needed.
4. **Backend / Frontend / Database** → implementation.
5. **Testing** → unit + integration; coverage ≥85%.
6. **Code Review** → static analysis, security, coverage diff.
7. **Security** → dependency + secrets scan; pass required.
8. **DevOps** → blue-green deploy; health check 30s; rollback on error spike.

Orchestrator enforces: max 3 retries per step, auto-rollback on test failure, deploy rate limit (e.g. 10/day), and kill switch.

## Maintenance

- **Weekly (or when learning log grows):** Say "apply learnings" to batch-apply logged improvements from `.cursor/learning-log.md` (see Self-Improvement skill).
- **Monthly (or on demand):** Ask for the scope-check report (Self-Improvement skill: read `.cursor/scope-check-log.md`, report Main only vs agents used, trend, one suggested change).

## Adding to a project

- Copy or symlink `.cursor/agents/`, `.cursor/skills/`, and optionally `.cursor/hooks/` into your project’s `.cursor/` (or use global Cursor config under user home).
- In project root, ensure `system_flow/` exists for Activity, Use case, and ER diagrams (see your rule). This framework’s own diagrams are under `.cursor/system_flow/`.

## cursor-kit extensions

- Optional **Security reviewer** agent/skill (`.cursor/agents/security-reviewer.md` and `.cursor/skills/security-reviewer/`) when present — dedicated security review workflow beyond the global Security agent.
- Project rules under `.cursor/rules/security-review.mdc` and command `cmd-review-project-security.md` in this repo.
