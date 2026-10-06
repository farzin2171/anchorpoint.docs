# Architecture decision records

Decisions that span services are authored here. Each ADR has Context, Decision, Consequences and
Alternatives. Service-local decisions live in that service's `docs/adr/` and link back here.

| ADR | Decision | Status |
|-----|----------|--------|
| [ADR-001](ADR-001-library-consumption.md) | How `Libraries.Infrastructure` is consumed, versioned and released (two reference modes, SemVer tags, GitHub Packages feed) | Accepted |
| [ADR-002](ADR-002-service-to-service-auth.md) | Service-to-service authentication: client credentials, one client per caller, one scope per callee | Accepted |
| [ADR-003](ADR-003-claims-and-failure-policy.md) | Claims contract and failure policy: fail closed at both hops, no profile caching at the Identity Server | Accepted |
| [ADR-004](ADR-004-database-ownership.md) | One database per service, regenerated migrations, how migrations are applied | Accepted |
| [ADR-005](ADR-005-postgresql-conventions.md) | PostgreSQL naming, keys, timestamps, case sensitivity | Accepted |
| [ADR-006](ADR-006-tenant-middleware-shape.md) | Tenant Middleware as a standalone service; stub behind an interface | Accepted |
| [ADR-007](ADR-007-demo-web-app-scope.md) | Demo Web App scope, client registration, non-production only | Accepted |

All seven ADRs were accepted by the owner on 2026-10-06 (task T029).
