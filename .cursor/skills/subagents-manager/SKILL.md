---
name: subagents-manager
description: List, enable/disable, and configure sub-agents. Use when managing the agent roster or agent settings.
---

# SubAgentsManager Skill

## When to Use

- User asks to "list agents", "disable agent X", "enable agent Y", "add new agent", "agent configuration", or "update AGENTS.md".
- Need to change which agents are active or how they are configured.

## Instructions

1. **List agents**
   - Scan `.cursor/agents/*.md`; read name and description from frontmatter.
   - Optionally use existing `AGENTS.md`; output table (name, description, key safety).

2. **Enable/disable**
   - Use a simple mechanism: e.g. `.cursor/agents/disabled.txt` (one agent name per line) or similar. Orchestrator and tooling skip agents in this list.
   - Document in AGENTS.md how to enable/disable. Do not delete agent files unless user explicitly asks to remove an agent.

3. **Configuration**
   - Agent-level settings (retries, deploy limit, etc.) may live in the agent .md, skill, or a config file. Document the location; apply edits when user requests a change.

4. **Add agent**
   - Create `.cursor/agents/<name>.md` and `.cursor/skills/<name>/SKILL.md`; update AGENTS.md. Delegate skill content to SkillsManager pattern if needed.

5. **Remove/archive**
   - Prefer disabling over deleting. If user asks to remove, disable first and confirm before deleting files; update AGENTS.md.

## Safety Checklist

- [ ] No agent file deleted without explicit user request
- [ ] AGENTS.md reflects current roster and disable list
- [ ] Orchestrator can respect disabled list (documented)
