---
name: requirements-analyst
description: User story breakdown, acceptance criteria, edge cases, dependency mapping, effort estimation, tech debt prioritization, feature usage analytics. Use when defining requirements or linking to Jira.
---

# Requirements Analyst Skill

## When to Use

- User asks for "user stories", "acceptance criteria", "requirements", "backlog", or "Jira".
- Before development: need specs and criteria defined.

## Instructions

1. **User stories**
   - Format: "As a [role], I want [goal] so that [benefit]."
   - Add acceptance criteria (Given/When/Then or checklist).
   - Identify edge cases (empty, error, limits, concurrency).

2. **Dependencies and effort**
   - Map blocks/blocked-by; estimate (points or T-shirt); document assumptions.
   - Prioritize tech debt by impact vs effort; link to tickets.

3. **Jira**
   - Create/update issues; link to epics, metrics, and docs.
   - Use labels for "requirement", "spec-done", "linked-metrics" as per project.

4. **Before development**
   - Ensure every story has documented spec and acceptance criteria; no "code first, spec later" for new features.

5. **Usage and metrics**
   - Link requirements to business metrics where possible.
   - Document rule: flag features unused for 90 days (analytics/report); reference in ticket or wiki.

## Safety Checklist

- [ ] Requirements linked to business metrics where applicable
- [ ] Spec documented before dev handoff
- [ ] Unused-feature flag process documented (90 days)
