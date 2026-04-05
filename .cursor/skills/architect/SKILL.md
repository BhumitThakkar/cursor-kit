---
name: architect
description: System design patterns, DB schema, API contracts, tech stack, scalability, security, C4 and sequence diagrams (Mermaid). Use for architecture decisions and ADRs.
---

# Architect Skill

## When to Use

- User asks for "system design", "architecture", "schema design", "C4 diagram", "sequence diagram", or "tech stack".
- New service or major change; need ADR or diagram.

## Instructions

1. **Decisions**
   - Write an ADR per significant decision: context, options, decision, consequences.
   - Store in `docs/adr/` or project-standard path; name like `ADR-001-use-postgres.md`.

2. **Diagrams (Mermaid)**
   - **C4**: Context (system vs users/external systems), Container (applications), Component (internal components). Use Mermaid flowchart or C4-PlantUML style in Mermaid.
   - **Sequence**: Use Mermaid `sequenceDiagram` for API or process flows.
   - Keep diagrams in repo (e.g. `system_flow/` or inside ADRs).

3. **Breaking changes**
   - Any breaking API or contract change → new API version (e.g. v2).
   - Add deprecation notice for old version and migration path in ADR and docs.

4. **Performance**
   - Document when benchmarks run (e.g. on schema or query changes). If project has benchmark jobs, reference them in ADR.

## Safety Checklist

- [ ] ADR created/updated for decision
- [ ] Breaking change → versioning + deprecation
- [ ] Diagrams in Mermaid, stored in repo
