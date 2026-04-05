---
name: hook-manager
description: Create, update, list, and wire safety hooks (pre-merge, deploy limit, rollback, kill switch). Use when adding or changing automation hooks.
---

# HookManager Skill

## When to Use

- User asks to "add a hook", "create pre-merge script", "wire hooks to CI", "list hooks", or "update deploy rate limit".
- Need to add or change a safety or automation script and its wiring.

## Instructions

1. **Create a hook**
   - Place under `.cursor/hooks/` (e.g. `my-check.ps1` or `.sh`).
   - Document: purpose, args, env vars, exit codes (0 = pass).
   - Add entry to `.cursor/hooks/README.md` with when to run and how to wire.

2. **Update a hook**
   - Edit script or README. Do not remove or bypass safety (rate limit, scan, tests) unless user explicitly requests and it is documented.

3. **List hooks**
   - List scripts in `.cursor/hooks/`; output name, purpose, and wiring (manual / pre-push / CI step).

4. **Wire into CI**
   - Add workflow step (e.g. GitHub Actions) that runs the hook script; fail the job on non-zero exit.
   - Or provide example for `.git/hooks/pre-push` and document in README.

## Safety Checklist

- [ ] No silent bypass of safety checks without explicit request
- [ ] Exit codes documented; CI/job fails on non-zero
- [ ] Wiring documented in README or workflow
