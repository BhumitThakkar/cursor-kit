---
name: commands-manager
description: Define, register, and run project commands (scripts, Maven/Gradle, npm, shell). Use when adding or listing runnable commands.
---

# CommandsManager Skill

## When to Use

- User asks to "add a command", "how do I run X", "register a script", or "list project commands".
- Hooks or CI need a single place to discover build/test/scan commands.

## Instructions

1. **Define a command**
   - Name, description, exact invocation (e.g. `mvn test`, `.\scripts\lint.ps1`).
   - Document: working directory, required env vars (JAVA_HOME, REPO_ROOT), exit codes (0 = success).

2. **Register commands**
   - Keep a single source of truth: e.g. `docs/commands.md`, `Makefile`, or `package.json` scripts.
   - Include: build, test, lint, security scan, deploy (if any). So agents and humans use the same invocations.

3. **Create scripts**
   - If no built-in exists, add a script under `scripts/` or `.cursor/hooks/`.
   - Script must exit 0 on success, non-zero on failure; document side effects (read-only vs write).

4. **Discovery**
   - When asked "how to run X", read the command list and return the exact command and cwd/env.

## Safety Checklist

- [ ] No production/deploy commands run without explicit request
- [ ] Every command documents side effects and exit codes
- [ ] Scripts use consistent exit codes
