---
name: adr-generator
description: >-
  Architect playbook to scaffold Architecture Decision Records under docs/adr/ with consistent
  headings aligned to tasks/decisions.md and mermaid-diagrams ADR convention.
---

# ADR generator (scaffold)

## When to Use

- Before or after a significant design choice (stack, boundary, data model, integration).
- When Zeus asks for an ADR to accompany an implementation epic.
- When linking diagrams from [`mermaid-diagrams`](../mermaid-diagrams/SKILL.md) to durable prose.

## Storage convention

- Primary path: **`docs/adr/`** (create if missing).
- File name: **`NNNN-short-title-kebab.md`** where `NNNN` is zero-padded sequence (next integer after highest existing file in that folder; if folder empty, start at `0001`).

## Template (copy into new file)

```markdown
# ADR NNNN: [Title]

## Status

Proposed | Accepted | Superseded by [link]

## Context

[What forces the decision?]

## Decision

[What we decided.]

## Consequences

[Positive and negative outcomes, constraints on future work.]

## Alternatives considered

- [Option A] — rejected because …
- [Option B] — rejected because …
```

## Cross-links

- Add a one-line summary to **`tasks/decisions.md`** (workspace root) per **`memory.mdc`** when the ADR is **Accepted** (human or Zeus confirms).

## Constraints

- Do not invent deployment secrets or production URLs.
- If the user only wanted a **mental** ADR, output the filled template in chat instead of writing a file — ask once if unclear.

## Status

Registered in `tool-registry.mdc`; promote usage to **`active`** after first ADR created with this template.
