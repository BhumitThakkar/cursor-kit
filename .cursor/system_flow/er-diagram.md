# ER Diagram – Agents, Skills, Tools, Safety

```mermaid
erDiagram
    AGENT ||--o{ SKILL : has
    AGENT ||--o{ TOOL : uses
    AGENT ||--o{ SAFETY_RULE : enforces
    ORCHESTRATOR ||--o{ AGENT : coordinates
    HOOK ||--o{ SAFETY_RULE : implements

    AGENT {
        string name PK
        string description
    }

    SKILL {
        string name PK
        string agent_name FK
        string instructions
    }

    TOOL {
        string name PK
        string agent_name FK
    }

    SAFETY_RULE {
        string id PK
        string agent_name FK
        string rule_text
        string hook_script
    }

    ORCHESTRATOR {
        string id PK
        string workflow
        int retry_max
        int deploy_limit_per_day
    }

    HOOK {
        string script_name PK
        string safety_mechanism
    }
```

## Entity summary

| Entity | Description |
|--------|-------------|
| **AGENT** | One per role (Orchestrator, Architect, Backend, etc.); has many skills, tools, safety rules. |
| **SKILL** | SKILL.md content; step-by-step instructions for an agent. |
| **TOOL** | Cursor, Mermaid, Jira, Postman, Docker, etc. |
| **SAFETY_RULE** | Non-negotiable rule (e.g. 3 retries, 10 deploys/day); may be enforced by a hook. |
| **ORCHESTRATOR** | Workflow definition; retry and deploy limits. |
| **HOOK** | Script (e.g. deploy-rate-limit.ps1) that implements a safety mechanism. |
