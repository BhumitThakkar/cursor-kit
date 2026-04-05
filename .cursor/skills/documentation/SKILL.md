---
name: documentation
description: OpenAPI/Swagger, API docs, examples, errors, auth, rate limit, changelog, runbooks, architecture. Use for keeping docs in sync.
---

# Documentation Skill

## When to Use

- User asks for "docs", "Swagger", "OpenAPI", "runbook", or "changelog".
- After API or operational change.

## Instructions

1. **API docs**
   - Generate from code (springdoc or similar); examples for every endpoint.
   - Document errors, auth, rate limits.

2. **Changelog and migration**
   - Changelog on release; breaking changes in migration guide with steps.

3. **Runbooks**
   - Deploy, rollback, incident; keep in sync with actual process.

4. **Diagrams**
   - Update architecture diagrams when design changes (with Architect).

5. **Drift**
   - Flag outdated docs (CI or checklist); fix or ticket.

## Safety Checklist

- [ ] API docs from code; examples for endpoints
- [ ] Breaking changes in migration guide
- [ ] Outdated docs flagged and addressed
