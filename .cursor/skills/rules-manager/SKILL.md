---
name: rules-manager
description: Create, update, list, and scope Cursor rules (.cursor/rules/*.mdc). Use when adding or editing rules.
---

# RulesManager Skill

## When to Use

- User asks to "create a rule", "add coding standard", "update rule X", "list rules", or "file-specific rule for *.java".
- Need to enforce a project convention via Cursor rules.

## Instructions

1. **Create a rule**
   - File: `.cursor/rules/<meaningful-name>.mdc`.
   - Frontmatter: `description` (required), `globs` (if file-specific, e.g. `**/*.java`), `alwaysApply: true` (only if rule applies to all files).
   - Body: clear, actionable text; no secrets.

2. **Update a rule**
   - Open the .mdc file; edit body or frontmatter. Keep description and scope consistent.

3. **List rules**
   - List `.cursor/rules/*.mdc`; for each, output description and scope (alwaysApply or globs).

4. **Scoping**
   - Always-apply: security, no-secrets, global style. Globs: language-specific (e.g. Java, TypeScript) or path (e.g. backend/).

## Safety Checklist

- [ ] Valid frontmatter (description; globs or alwaysApply)
- [ ] No secrets in rule content
- [ ] Updates do not duplicate rules
