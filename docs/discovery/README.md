# Discovery

Read-only analysis of the source projects, written before any building starts. Primary source:
`C:\MyWork\stepwise_identity`. Secondary sources: `C:\work\Applications.IdentityGateway`,
`C:\work\Services.User`, `C:\work\ACME.API.Middleware`, `C:\work\Libraries.Infrastructure`.
Nothing in any source folder was modified.

| Document | What it answers |
|----------|-----------------|
| [source-analysis.md](source-analysis.md) | What is in `stepwise_identity`, how the projects reference each other, how sign-in and service calls work, and the risks for the rebuild |
| [comparison.md](comparison.md) | Gap tables, Mini versus production, with an include now, later or never decision and a reason for every row |
| [commit-map.md](commit-map.md) | The source's 33 commits: purpose, whether needed, and which new step and track each maps to |
| [infrastructure-inventory.md](infrastructure-inventory.md) | Every plumbing component across the code bases: shared library or stays in a service, and the planned layout of the new library |
| [postgres-migration-notes.md](postgres-migration-notes.md) | Every SQL Server-specific item per service, and proposed PostgreSQL conventions for ADR-005 |
| [mini-userservice-split.md](mini-userservice-split.md) | How `Mini.UserService` splits into the User Service, the Tenant Middleware, or nothing |
| [contracts.md](contracts.md) | Draft Identity Server to User Service and User Service to Tenant Middleware contracts (authoritative) |

Sections titled "Not read / unverified" in each document list what the analysis did not cover. Treat
those as open until a later step verifies them.
