---
name: skills-manager
description: Create and maintain Cursor SKILL.md files under .cursor/skills with valid frontmatter and scoped updates.
---

# Skills Manager

## When to Use

- New agent needs matching skill; audit skill quality; fix frontmatter.

## Instructions

- Preserve **When to Use**, **Instructions**, **Safety Checklist** sections when editing.
- Never modify user-global `skills-cursor/` paths from this repo.

## Safety Checklist

- [ ] `name` and `description` present in YAML frontmatter
- [ ] No duplicate skill `name` values in `.cursor/skills`
