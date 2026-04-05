---
name: database
description: PostgreSQL, Liquibase, indexing, full-text search, backup, RLS, connection pooling. Use for schema and DB operations.
---

# Database Skill

## When to Use

- User asks for "schema", "migration", "Liquibase", "PostgreSQL", "index", or "Supabase".
- Adding tables, indexes, or changing schema.

## Instructions

1. **Migrations**
   - Liquibase changesets; include rollback; one logical change per changeset.
   - No manual DDL in prod outside migrations.

2. **Schema**
   - FKs enforced; naming consistent; document RLS if used.

3. **Performance**
   - Indexes for hot queries; full-text where needed; run EXPLAIN on critical queries.
   - Document query monitoring and alerting.

4. **Backup and pool**
   - Daily backups documented; restore tested. Connection pool limits set.

5. **Test data**
   - Anonymize or generate test data; no prod PII in non-prod without anonymization.

## Safety Checklist

- [ ] Every migration has rollback
- [ ] Backups and pool limits documented
- [ ] FKs enforced; test data anonymized where needed
