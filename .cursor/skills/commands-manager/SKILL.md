---
name: commands-manager
description: Register runnable project commands with documented side effects and exit codes.
---

# Commands Manager

## When to Use

- Adding `/`-style Cursor commands, Make targets, or contributor scripts.

## Instructions

- Centralise discovery in `docs/commands.md` or Makefile with one-line purpose per command.
- Do not add prod deploy commands without explicit user request tracked by Zeus.

## Safety Checklist

- [ ] Side effects and exit codes documented
- [ ] Windows vs Unix invocation differences noted if relevant
