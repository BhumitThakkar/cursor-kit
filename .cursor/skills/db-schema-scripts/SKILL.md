---
name: db-schema-scripts
description: Generates the SQL setup-schema and teardown-schema scripts from an approved physical design document. Use whenever the user wants DDL, a create script, a drop script, or schema SQL files, and as the second step of the DBA-Agent workflow. Requires an approved docs/db/physical-design.md; never runs the SQL.
---

# Schema scripts

Output files: `docs/db/setup-schema.sql` and `docs/db/teardown-schema.sql`. Precondition: `docs/db/physical-design.md` exists with `status: approved`. Use only the engine, types, names, and constraints recorded there.

## Required inputs (ask via `ask-missing-info` if any is missing)

1. Schema or namespace name. Recommended default: the engine's default schema.
2. Reference data: which lookup tables need initial rows, and the rows. Skip if there are no lookup tables.

Everything else comes from the design file.

## setup-schema.sql

- Header comment: purpose, engine and version, "generated from docs/db/physical-design.md", and "validate on a throwaway database before use".
- Create tables in dependency order: parents before children. For circular FKs, create the tables first, then add the FKs with `ALTER TABLE`, and note it in a comment.
- Name every constraint and index explicitly: `pk_<table>`, `fk_<table>_<referenced>`, `uk_<table>_<column>`, `ck_<table>_<column>`, `ix_<table>_<column>`.
- Plain `CREATE` statements with no `IF NOT EXISTS`, so a re-run fails loudly instead of hiding drift.
- No `DROP` statements. No data except reference rows, placed in a marked section at the end.

## teardown-schema.sql

- Header comment: **"DEV/TEST ONLY. Destroys all data. Never run against production."**
- Drop tables in reverse dependency order, children first. Use `DROP TABLE IF EXISTS` so a partial setup can still be cleaned up.
- Drop the schema last, only if setup created it.
- Drop exactly the objects setup created and nothing else. No `TRUNCATE` or `DELETE` variants.

## Self-check before returning

You cannot run SQL, so cross-check by counting. Report three lines in `FOR THE USER`:

```
Design: <n> tables, <n> FKs, <n> indexes
Setup:  <n> tables, <n> FKs, <n> indexes
Teardown: <n> tables dropped
```

The numbers must match. Never say the scripts were tested.

## Done when

- [ ] Engine syntax matches the version in the design header
- [ ] Creation order respects FK dependencies, and teardown is its exact reverse
- [ ] Every constraint and index is named
- [ ] Counts match between design, setup, and teardown
- [ ] Teardown carries the dev/test-only warning
- [ ] Files saved, then approval is requested, with a reminder to validate on a throwaway database (return contract in `dba-agent`)
