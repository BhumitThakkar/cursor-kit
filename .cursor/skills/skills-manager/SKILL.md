---
name: skills-manager
description: Create, update, list, and maintain Cursor agent skills (SKILL.md). Use when adding or editing skills.
---

# SkillsManager Skill

## When to Use

- User asks to "create a skill", "add a new skill", "update skill X", "list skills", or "where are skills stored".
- Need to add or change instructions for an agent skill.

## Instructions

1. **Create a new skill**
   - Choose location: project `.cursor/skills/<skill-name>/` or personal `~/.cursor/skills/<skill-name>/`.
   - Create directory and `SKILL.md` with:
     - YAML frontmatter: `name`, `description` (required).
     - Sections: "When to Use", "Instructions", optional "Examples" or "Safety Checklist".
   - Do not create under `skills-cursor/`.

2. **Update an existing skill**
   - Open the skill's SKILL.md; preserve frontmatter and required sections.
   - Edit instructions or description; do not remove "When to Use" or "Instructions" unless replacing with equivalent.

3. **List skills**
   - List `.cursor/skills/` (project) and optionally `~/.cursor/skills/` (personal).
   - Output: name, description, path. Exclude `skills-cursor/` from edits.

4. **Scope**
   - Personal: available in all projects. Project: version-controlled with the repo.

## Safety Checklist

- [ ] No files created or modified under `skills-cursor/`
- [ ] Every SKILL.md has `name` and `description` in frontmatter
- [ ] Updates preserve required sections
