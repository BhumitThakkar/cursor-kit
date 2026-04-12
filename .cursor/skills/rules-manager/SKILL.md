---
name: rules-manager
description: Manage .cursor/rules/*.mdc frontmatter, globs, alwaysApply, and deduplicated policy text.
---

# Rules Manager

## When to Use

- Policy updates, new always-on constraints, or rule scoping fixes.

## Instructions

- Keep `alwaysApply: true` rare — global orchestration and quality gates only.
- Use `globs` to limit noisy rules to relevant file types.

## Safety Checklist

- [ ] No secrets or real credentials in examples
- [ ] No overlapping rule files for the same concern
