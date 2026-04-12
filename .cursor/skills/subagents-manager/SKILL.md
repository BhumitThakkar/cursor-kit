---
name: subagents-manager
description: Maintain AGENTS.md roster and disabled.txt without deleting agent files without explicit approval.
---

# Subagents Manager

## When to Use

- After adding/removing `.cursor/agents/*.md` or toggling agents off temporarily.

## Instructions

- Keep `.cursor/AGENTS.md` priority table and descriptions in sync with files on disk.
- Use `.cursor/agents/disabled.txt` (one agent name per line) instead of deleting markdown.

## Safety Checklist

- [ ] No orphan agent filename in disabled list
- [ ] Zeus notified when an agent is disabled for quality reasons
