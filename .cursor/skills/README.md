# `skills/` — Agent skill playbooks

Each subfolder is one **skill**: a `SKILL.md` with YAML frontmatter (`name`, `description`) plus sections such as **When to Use**, **Instructions**, and **Safety Checklist**. Agents load the relevant skill before doing detailed work.

| Folder | Focus |
| --- | --- |
| `spring-boot-patterns` | Java / Spring Boot implementation patterns. |
| `validate-spring-dto` | Read-only Jakarta Validation coverage on REST DTOs / request bodies (report + PASS/FAIL). |
| `test-coverage-check` | JaCoCo / Gradle reports and Gate 3 scenario mapping for new code. |
| `adr-generator` | Scaffold `docs/adr/NNNN-title.md` and link to `tasks/decisions.md`. |
| `lessons-summarizer` | Cluster themes in `tasks/lessons.md`; append digest only with explicit consent. |
| `thymeleaf-patterns` | Thymeleaf, forms, a11y, i18n, CSP. |
| `security-reviewer` | **L0** security root: workspace pass, secrets, CI, Docker; **always before** L1. |
| `owasp-checklist` | **L1** Spring/Java OWASP depth; **auto with** `security-reviewer` when `.java` / `pom.xml` / Spring config in scope. |
| `mermaid-diagrams` | Mermaid diagrams for architecture docs (incl. use case diagrams). |
| `requirements-analyst` | Stories, acceptance criteria, dependencies. |
| `api-contract` | OpenAPI, errors, pagination, contracts. |
| `database` | PostgreSQL, Liquibase, indexing, pools. |
| `debugging` | Logs, traces, safe fixes, confidence. |
| `documentation` | API docs, runbooks, changelogs. |
| `self-improvement` | Metrics, learning log, controlled rollout. |
| `skills-manager` / `rules-manager` / `hook-manager` / `commands-manager` / `subagents-manager` | Meta-operations on skills, rules, hooks, commands, roster. |

Each subfolder also contains a short **README.md** pointing at its `SKILL.md`.
