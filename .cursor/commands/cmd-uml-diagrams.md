---
description: >-
  Architecture visuals. Type /cmd-uml-diagrams to ensure uml-diagrams/ exists and to create or
  refresh ER, use case, flow, and sequence Mermaid diagrams from the current codebase (or user scope).
---

# /cmd-uml-diagrams — UML-oriented Mermaid diagrams

Generate or **refresh** four diagrams under **`uml-diagrams/`** at the **workspace root**. Treat this as **documentation derived from code** — diagrams must reflect entities, actors, and flows you can justify from the repo (or from an explicit user brief if they scoped a feature).

## Terminology (clarification)

| Colloquial / prompt | UML-aligned name | Output file |
| --- | --- | --- |
| “User diagram” | **Use case diagram** — actors, system boundary, goals (use cases) | `use-case-diagram.md` |
| ER diagram | **Entity–relationship** view of persistent data | `er-diagram.md` |
| Flow diagram | **Activity / process** view (Mermaid `flowchart`) | `flow-diagram.md` |
| Sequence diagram | **Interaction** view over time between participants | `sequence-diagram.md` |

If the user explicitly wanted a **user journey** or **persona** doc instead of UML use cases, produce **use cases first** (file above), then add a short **“User journeys”** subsection inside `flow-diagram.md` or ask one clarifying question before replacing use cases.

## Skills and agents

1. Read **[`mermaid-diagrams`](../skills/mermaid-diagrams/SKILL.md)** — syntax, `erDiagram`, `sequenceDiagram`, `flowchart`, `usecaseDiagram`, and fallbacks.
2. Prefer **Architect**-level accuracy: boundaries, real type names from code, real endpoints or services when known.

**Pantheon:** Zeus may classify this as **Standard** (one agent, one pass). No security gate unless the user also asked for a security review.

## What to do

1. **Ensure directory** — Create **`uml-diagrams/`** at the workspace root if it does not exist.
2. **Scope** — If the user named modules, packages, or tickets, limit analysis to that scope; otherwise infer from the dominant app (e.g. Spring Boot `src/main/java`, main templates, Liquibase/Flyway entities).
3. **Create or overwrite** these four files (always all four on each run so the set stays consistent):
   - **`uml-diagrams/er-diagram.md`**
   - **`uml-diagrams/use-case-diagram.md`**
   - **`uml-diagrams/flow-diagram.md`**
   - **`uml-diagrams/sequence-diagram.md`**

   Each file MUST:
   - Start with a short **YAML front matter** block: `title`, `updated` (ISO date), `scope` (one line).
   - Contain exactly **one** fenced code block with language **`mermaid`**, with valid diagram source for that file’s type.
   - End with an optional **“Evidence”** bullet list: paths/classes/config keys you used (no secrets).

4. **Content rules**
   - **ER:** Map JPA entities / DDL / DTO persistence to `erDiagram`; use relationships that exist in code; if schema unknown, state assumption in Evidence.
   - **Use case:** Name actors from roles in security config or UI; name use cases from controllers/pages/services, not vague “User uses system.”
   - **Flow:** One primary business flow (e.g. request lifecycle or main user journey) — `flowchart TD` or `LR` per skill.
   - **Sequence:** One critical path (e.g. HTTP → Security → Controller → Service → Repository → DB); participants must match real layers/packages where possible.

5. **`uml-diagrams/README.md`** — If missing, create it from the table in this command; if present, update the **“Last refreshed”** line only (do not delete custom notes).

6. **Chat output** — Short summary: what changed, which files, one known limitation (e.g. “no Flyway in repo, ER from JPA only”).

## Renderer note

`usecaseDiagram` requires a recent Mermaid version. If unsupported, use the skill’s **flowchart fallback** for actors and use cases inside a labelled subgraph — still store it in `use-case-diagram.md`.
