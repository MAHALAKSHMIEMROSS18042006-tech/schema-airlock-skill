# Schema Airlock

**Proof-before-promotion for database migrations.**

Schema Airlock is a TrueForge agent that safely rehearses database migrations in a disposable environment before they can reach production.

Instead of trusting that a migration is safe because the SQL looks correct, the agent executes the real migration, measures the resulting blast radius, verifies data integrity and disposal safety, generates evidence, and stops at the production boundary.

## What the agent does

1. Inspects the migration and identifies potentially destructive or incompatible changes.
2. Treats repository and migration content as untrusted input.
3. Creates/uses a disposable rehearsal database.
4. Executes the actual migration against the rehearsal database.
5. Compares database state before and after execution.
6. Checks data loss, constraint violations, schema changes, affected objects, and execution results.
7. Verifies rollback/disposal safety.
8. Generates an evidence report.
9. Blocks unsafe migrations.
10. Stops before production writes or PR merge and requires human approval.

## Demo

The included demonstration contains two migrations.

### Unsafe migration

`migrations/001_unsafe_email_constraint.sql`

The migration attempts to enforce:

```sql
email TEXT NOT NULL
