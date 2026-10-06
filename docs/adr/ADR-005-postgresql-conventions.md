# ADR-005: PostgreSQL conventions

**Status**: Accepted (owner approval 2026-10-06) | **Date**: 2026-10-06 | **Deciders**: project owner

## Context

Moving from SQL Server to PostgreSQL changes naming, key generation, time handling and above all string
comparison. Discovery (`docs/discovery/postgres-migration-notes.md`, sections 5 and 6) found:
the reference solution relies on SQL Server's case-insensitive default collation (for example
`Key == tenantKey` and `LIKE` in a CORS check); production uses `NEWSEQUENTIALID()` and SQL Server types;
PostgreSQL truncates identifiers over 63 bytes silently and `timestamptz` rejects non-UTC `DateTime` values.

## Decision

| Topic | Convention |
|-------|-----------|
| Names | `snake_case` for tables, columns, keys and indexes; plural table names (`users`, `external_identities`, `roles`, `user_roles`). Applied through one library naming convention to all contexts, including Duende's |
| Constraint names | `pk_<table>`, `fk_<table>_<ref>`, `ix_<table>_<cols>`, `ux_<table>_<cols>`, each under 63 bytes; a test fails on any longer generated name |
| Application keys | `uuid`, generated in the application with `Guid.CreateVersion7()` (time ordered); no database default needed. Duende tables keep Duende's `int` identity keys |
| Strings | `text`; `varchar(n)` only where a business rule fixes a limit |
| Booleans | `boolean` |
| Timestamps | `timestamptz` everywhere; code uses UTC (`DateTime` with `Kind=Utc` or `DateTimeOffset`); column names end in `_at`; the library persistence component rejects non-UTC values |
| Case sensitivity | Columns are case sensitive (the default). Natural keys typed by people (role key, tenant key, group key) are stored lowercase and validated lowercase in the application. `(provider, provider_user_id)` stays case sensitive. `citext` is not used. Pattern matches that must ignore case use `ILike` |
| Schema | The default `public` schema in each service's own database |
| Seed data | Static reference data with fixed UUIDs in migrations; otherwise a development-only seeder; no `HasData` with integer ids |
| Migration history | EF default table renamed to snake_case (`__ef_migrations_history`) |
| Provider | `Npgsql.EntityFrameworkCore.PostgreSQL` matching the EF Core major version; PostgreSQL major version pinned (proposal: 17) |
| Multiple readers on one connection | Not used (Npgsql does not support MARS) |

## Consequences

- Good: no quoting in hand-written SQL; no accidental truncation; no dependency on a collation default.
- Good: time-ordered UUIDs keep index locality without a database function.
- Cost: every natural key entering the system must be normalized to lowercase at the boundary, and tests
  must cover mixed-case input.
- Cost: a custom naming convention covers third-party (Duende) tables, so each Duende upgrade needs the
  migration regenerated and checked.
- Cost: users of `text` rely on application validation for length limits.

## Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| `citext` for case-insensitive keys | Extension to install and manage; hides the rule in the database; chosen against in favor of explicit lowercase |
| Database-generated UUIDs (`gen_random_uuid()`) | Random v4 hurts index locality; kept only as a fallback |
| PascalCase names as in SQL Server | Requires quoting everywhere in raw SQL and psql |
| Integer identity keys for application tables | Leaks counts and causes sequence drift with seeded rows (reference solution `HasData` ids) |
| `varchar(n)` everywhere | No performance benefit in PostgreSQL; limits belong to business rules |
