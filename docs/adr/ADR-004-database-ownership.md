# ADR-004: Database ownership and migration strategy per service

**Status**: Accepted (owner approval 2026-10-06) | **Date**: 2026-10-06 | **Deciders**: project owner

## Context

PostgreSQL is the only database. Constitution V and X require each service to own its database or schema
with its own migrations, and forbid one service reading another's database. Discovery found that the
reference solution already gives each service its own database, but that two EF contexts share one database
in `Mini.UserService` (needing a second migration history table), that all migrations are SQL Server DDL, and
that production applies schema either through startup helpers or a dacpac.

## Decision

1. **One database per service**, on a PostgreSQL server that several services may share in development
   (the compose file creates `identity` and `users`, and later `tenants`). A service never connects to
   another service's database; cross-service data goes through the contracts.
2. **One EF Core context per database where possible.** The Identity Server's two Duende contexts
   (configuration and operational) share one database and use separate migration history tables
   (`__ef_migrations_history_configuration`, `__ef_migrations_history_grants`).
3. **Migrations are generated from the model for PostgreSQL and committed.** SQL Server migrations are
   never ported. The Duende store migrations are regenerated for Npgsql (see the regeneration notes in
   `docs/discovery/postgres-migration-notes.md`).
4. **How migrations are applied**:
   - Development and test: automatically at startup through the library persistence helper, controlled by
     an option `Database:MigrateOnStartup` (default true only in Development and in tests).
   - Other environments: applied explicitly (`dotnet ef database update` or a migration bundle) as a
     deployment step. The option defaults to false.
5. **Seeding**: static reference data with fixed UUIDs is part of migrations; demo and test data is seeded
   by a seeder that runs only in Development and tests. No seed data contains secrets.
6. **Every migration is verified on a fresh PostgreSQL** in CI (Testcontainers), spec SC-012.
7. **The PostgreSQL major version is pinned** in compose files and Testcontainers fixtures (proposal: 17).

## Consequences

- Good: services deploy and evolve independently; no hidden coupling through a shared schema.
- Good: migrations are reviewable in pull requests and tested on the real engine.
- Cost: more databases to provision; a dev compose file must create them.
- Cost: regenerating the Duende migrations means re-verifying them on each Duende upgrade.
- Cost: running migrations in deployment is an explicit step that must be documented in each service's
  `docs/operations.md`.

## Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| One shared database with a schema per service | Weaker isolation; migrations and roles harder to separate; allowed by the constitution but not chosen |
| Always migrate at startup | Risky in production (concurrent instances, long migrations) |
| Port the SQL Server migrations | Encode SQL Server types and quoting; regenerating is safer |
| SQL-script or dacpac deployment as in `Services.User` | Tool and source of truth differ from EF; dacpac source not found in discovery |
