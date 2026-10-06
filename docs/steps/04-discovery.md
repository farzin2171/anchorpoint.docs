# Step 04: Discovery of the source projects

**Track**: P (platform documentation) | **Tasks**: T011 to T018 | **Commit scope**: `docs(platform)`

## Goal

Understand the existing sources before building anything, so every later step is derived from evidence
and nothing is copied blindly. Every comparison row ends in a decision (now, later or never) with a reason.

## Starting state

Documentation baseline, docs CI and process templates (steps 01 to 03). `docs/discovery/` holds only a
placeholder README.

## Changes

Added seven documents under `docs/discovery/`, and rewrote the folder README as an index:

- `source-analysis.md`: inventory of every project in `C:\MyWork\stepwise_identity`, how they reference
  each other, sign-in and service-to-service diagrams, and risks.
- `comparison.md`: seven gap tables (user/role/group model, claims, tenants, service-to-service auth,
  caching, API surface, other areas) against the production repositories, plus a section on what
  `ACME.API.Middleware` is and what Track M should take from it.
- `commit-map.md`: the 33 source commits mapped to new steps and tracks.
- `infrastructure-inventory.md`: 31 plumbing components classified as shared library or service-local,
  with the planned `Anchorpoint.Infrastructure.<Component>` layout.
- `postgres-migration-notes.md`: every SQL Server-specific item per service and proposed PostgreSQL conventions.
- `mini-userservice-split.md`: the proposed split of `Mini.UserService` into Track U, Track M and dropped pieces.
- `contracts.md`: the two draft service contracts with DTOs, status codes and OpenAPI outlines.

## Files

- `docs/discovery/README.md`, `source-analysis.md`, `comparison.md`, `commit-map.md`,
  `infrastructure-inventory.md`, `postgres-migration-notes.md`, `mini-userservice-split.md`, `contracts.md`
- `docs/steps/04-discovery.md`, `docs/steps/README.md`, `CHANGELOG.md`

## Source mapping

| Source | Treatment | Why |
|--------|-----------|-----|
| `C:\MyWork\stepwise_identity` (all of `src`, `tests`, `docs`, git history) | Read, analyzed | Primary source of truth; not modified |
| `C:\work\Applications.IdentityGateway`, `C:\work\Services.User`, `C:\work\ACME.API.Middleware`, `C:\work\Libraries.Infrastructure` | Read, analyzed | Production references; used to decide what the reference solution lacks. Not modified |
| Planning drafts `specs/001-identity-platform-build/contracts/*.yaml` in `anchorpoint.identity.gateway` | Superseded by `contracts.md` | One authoritative copy of each contract |

## Key findings

1. **The source is larger than five projects.** It is a 24-phase solution with authorization, messaging,
   an outbox, a React SPA and connectors. Only the Identity Server, `Mini.UserService`,
   `Mini.Infrastructure` and the MVC client matter for this phase.
2. **`Mini.UserService` plays two roles** (Tenant API and User API). The new platform splits them.
3. **There is no "User Service calls Tenant Middleware" hop** in the source: the Identity Server calls
   both APIs directly. That hop, groups, and a many-to-many role model are new design.
4. **A circular dependency exists**: the Identity Server calls the User Service at token issuance and the
   User Service calls back for id conversion. The new contracts remove it.
5. **Most Track C components have no source to port.** Only the token client, the HTTP resilience policies
   and the identity context exist. Logging, configuration validation, errors, health checks, observability,
   persistence and test utilities are new work.
6. **Production fails open** (token issued without a role when the User Service errors) and **auto-creates
   unknown users**. The clarified decisions reverse both.
7. **Secrets are committed** in the source (`tempkey.jwk` with its private key, plaintext client secrets)
   and in production repositories (identity-provider configuration, a database-stored Graph secret, a
   test database password). The new repositories ignore key material and run a secret scan. No secret
   value is reproduced in these documents.
8. **The internal `DigitalInsuranceTools.Persistence.SqlServer` package** is a dependency of both
   production services; the new library needs a PostgreSQL equivalent, the largest single migration item.
9. **`Libraries.Infrastructure` is marked "Copyright Equisoft. All rights reserved".** It is used as a
   design reference only; the legal position on reusing its code is unverified.

## Owner review (task T018)

The owner reviewed the discovery on 2026-10-06 and approved the proposals as written:

1. Tenant ownership moves to the Tenant Middleware, with stub data first.
2. The role model grows to User, ExternalIdentity, Role and UserRole.
3. The id-conversion endpoint and its callback are dropped.
4. Per-tenant connectors are deferred; the User Service owns roles in a local table.
5. The tenant claim holds the tenant key; group claims hold group keys.
6. `C:\work\Libraries.Infrastructure` is treated as a design reference only (reuse of its code is not assumed).

**Settled later (2026-10-06)**: the provider's stable user ID for Entra ID is `oid` (ADR-003).

## Resulting state

Discovery is documented and approved. The step plan and the ADRs (tasks T019
to T029) are written from these findings.

## How to verify

```powershell
pwsh ./tools/check-mermaid.ps1      # expect: exit 0, 6 mermaid blocks checked
```

Open `docs/discovery/README.md`: every link resolves. In each document, check that every claim cites a
file path. Spot checks done when this step was written: the source's `tempkey.jwk` is tracked in git and
holds a private member; the source has 33 commits; the hashes cited in `commit-map.md` exist.

## Decisions

No ADR is created here. Findings feed ADR-001 (consumption and licensing), ADR-002 (service auth),
ADR-003 (claims and failure policy), ADR-004 and ADR-005 (database and PostgreSQL conventions) and ADR-006
(Tenant Middleware shape).

## Known limitations

- The analysis was done by reading code and the sources' own documentation; nothing was run.
- Each document ends with a "Not read / unverified" section. Notably: EF migration bodies were only
  searched, phase READMEs were skimmed, the internal `DIT.*` packages are not in the repositories, and
  `commit-map.md` derives commit purposes from file statistics and README lines, not full diffs.
- The proposals in `mini-userservice-split.md`, `contracts.md` and the PostgreSQL conventions are drafts
  for the owner's review, not decisions.
