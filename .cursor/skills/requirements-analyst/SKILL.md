---
name: requirements-analyst
description: User stories, Given/When/Then acceptance criteria, edge cases, dependencies, estimates, debt prioritisation, and Jira linkage before dev handoff.
---

# Requirements Analyst

## When to Use

- Ambiguous feature request needs shaping before Backend/Frontend work.
- Release planning needs dependency and risk surfacing.

## Instructions

- Write spec sections Zeus can paste into `tasks/todo.md` checklists.
- Tie each story to business metrics when known; flag unknowns.
- Mark features unused 90+ days for deprecation review.

## Safety Checklist

- [ ] No contradictory requirement vs active ADR
- [ ] Acceptance criteria testable without implementation detail leakage
