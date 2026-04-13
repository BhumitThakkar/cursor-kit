---
name: database
description: PostgreSQL schema, Liquibase with rollback, indexing, backups, RLS, pooling, and query tuning.
---

# Database

## When to Use

- Schema or migration design; performance investigation on SQL tier.

## Instructions

- Every changeSet includes `<rollback>` or documented irreversible ADR.
- Use EXPLAIN (ANALYZE, BUFFERS) on hot queries in non-prod clones.
- Document pool sizes and PgBouncer mode if used.

## Safety Checklist

- [ ] No production credentials in Liquibase or samples
- [ ] FKs and constraints match service expectations
