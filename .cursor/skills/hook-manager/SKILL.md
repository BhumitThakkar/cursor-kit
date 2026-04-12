---
name: hook-manager
description: Author and wire Cursor hook scripts with documented exit codes and JSON contracts.
---

# Hook Manager

## When to Use

- Adding safety automation for shell, MCP, or lifecycle events.

## Instructions

- Document stdin/stdout JSON shape in script header comments.
- Matchers for `beforeShellExecution` must be tested against representative commands.

## Safety Checklist

- [ ] Kill switch and deploy rate limit compose without bypass
- [ ] Timeouts set for worst-case (e.g. full test suite)
