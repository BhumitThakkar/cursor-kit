---
name: db-physical-design
description: Turns an approved ER diagram into an engine-specific physical database design document covering column types, constraints, naming, indexes, and justified denormalization. Use whenever the user wants a database design, physical schema, column types, index plan, or denormalization decisions, and as the first step of the DBA-Agent workflow. Asks for the target database and for volume and query information before designing.
---

# Physical design

Output file: `docs/db/physical-design.md`. Read `docs/uml/er-diagram.md` first (it must be `status: approved`), plus the use case and activity files for query hints.

## Header (frontmatter)

```
---
title: Physical design
type: physical-design
engine: <name and version>
status: draft | approved
---
```

## Required inputs (ask via `ask-missing-info` if any is missing)

1. **Target engine and version.** Skip if already in the header or found in project files.
2. Expected data volume for the main entities, and the hot queries or read/write mix. This drives indexes and any denormalization.
3. Naming convention. Recommended default: `snake_case`, singular table names (it matches Spring Boot's default naming strategy).
4. Primary key style: identity/sequence, UUID, or the natural keys from the ER diagram.
5. Soft delete, audit columns (created/updated by and at), and retention needs.

Do not invent business rules. If something is unknown, ask or record it under Open questions.

## Sections of the design file

1. **Decisions.** Engine, naming convention, PK style, timestamp convention (UTC), audit columns.
2. **Traceability.** Table: ER entity, table name, notes.
3. **Type mapping.** Table: logical type, engine type, rule. Use the engine's documented types for the recorded version. If unsure of a type for that version, say so under Open questions.
4. **Table specs.** Per table: columns (name, type, nullability, default), PK, FKs with their `ON DELETE` rule, unique constraints, CHECK constraints (including enum values from the ER diagram).
5. **Index plan.** Each index with its reason: FK column, hot query, or uniqueness.
6. **Denormalization log.** Each entry with the query or volume that justifies it. Default: none.
7. **Normal-form re-check.** One line per table confirming it is still in 3NF after the physical choices, or the recorded exception.
8. **Flags for the security phase.** Columns holding personal, financial, or credential data. Flags only, no solutions.
9. **Assumptions** (A1, A2, ...) and **Open questions.**

## Rules

- Every ER entity becomes one table and every attribute one column. No extra tables or columns without a stated reason.
- Every FK has an explicit `ON DELETE` rule. Default `RESTRICT`. Use `CASCADE` only for composition and record why.
- Money uses an exact decimal type, never floating point. Choose explicit `varchar` lengths and record them as assumptions.
- Enums use a CHECK constraint or a lookup table, as decided in the ER diagram. Avoid engine-specific enum types.
- Index FK columns unless the engine already does. PostgreSQL and SQL Server do not index them automatically. MySQL InnoDB does.
- Denormalize only with a written reason tied to a query or volume.
- No partitioning, triggers, or stored procedures unless the user asked. Flag them instead.

## Done when

- [ ] Engine and version recorded in the header
- [ ] All required inputs answered or recorded as assumptions
- [ ] Every entity and attribute traced to a table and column
- [ ] Every FK has an `ON DELETE` rule and every index a reason
- [ ] Normal-form re-check done
- [ ] File saved with `status: draft`, then approval is requested (return contract in `dba-agent`)
