# Step 05: Step plan and ADR-001 to ADR-007

**Track**: P (platform documentation) | **Tasks**: T019 to T029 | **Commit scope**: `docs(platform)`

## Goal

One reviewed, dependency-ordered plan for all six tracks, and the seven architectural decisions that must
be recorded before the steps that depend on them. Nothing in the building phases starts until the owner
approves this step (the approval gate, task T029).

## Starting state

Discovery is committed and approved (step 04). Tasks T001 to T018 are done.

## Changes

- Added `docs/step-plan.md`: one table per track (P, C, U, I, M, W) with step id, objective, dependencies,
  commit message, parallel candidates and documentation produced; a Mermaid dependency graph; the
  integration milestones (IM-0 to IM-6 and the ADR gates); a documentation coverage matrix naming, for every
  required document, the step that creates it and the step that completes it; the effect of the discovery on
  the plan; and the open items for the owner.
- Added `docs/adr/ADR-001` to `ADR-007` (Context, Decision, Consequences, Alternatives), and rewrote
  `docs/adr/README.md` as an index.
- Added `docs/backlog.md` entries in the authorization, notification and UX service repositories recording
  their future adoption of the shared library and documentation standards (no other change to them).
- Task list: scaffold steps for each track also create skeleton `README.md` and `docs/architecture.md`, so
  documentation is not left to the end.

## Files

- `docs/step-plan.md`
- `docs/adr/README.md`, `ADR-001-library-consumption.md`, `ADR-002-service-to-service-auth.md`,
  `ADR-003-claims-and-failure-policy.md`, `ADR-004-database-ownership.md`, `ADR-005-postgresql-conventions.md`,
  `ADR-006-tenant-middleware-shape.md`, `ADR-007-demo-web-app-scope.md`
- `docs/steps/05-step-plan-and-adrs.md`, `docs/steps/README.md`, `CHANGELOG.md`
- In other repositories: `docs/backlog.md` in `anchorpoint.service.authorization`,
  `anchorpoint.service.notification`, `anchorpoint.service.ux`

## Source mapping

| Source | Treatment | Why |
|--------|-----------|-----|
| `docs/discovery/*` (this repository) | Used as evidence | Every plan decision and ADR cites a discovery finding |
| `C:\work\Applications.Apply\Equisoft.Apply.WithCoreAndLibrary.slnx`, `build\IncludeInfrastructureSource.props`, `build\Versions.props` | Adapted in ADR-001 | The two-solution, `IncludeInfrastructureSource` convention the team already uses |
| `C:\MyWork\stepwise_identity\docs\adr\0001-messaging-transport.md` | Format reference only | The source's single ADR; messaging itself is out of scope for this phase |
| `C:\MyWork\stepwise_identity` commit history | Used for step ordering | Mapped in `docs/discovery/commit-map.md` |

## Resulting state

An approved plan and seven accepted ADRs. The library work (Track C) can start with step C-04.

## How to verify

```powershell
pwsh ./tools/check-mermaid.ps1      # expect: exit 0 (the dependency graph is checked)
```

Check that every step id used in a "Depends on" cell exists as a row, that every task T001 to T091 in
`specs/001-identity-platform-build/tasks.md` appears in at least one step's objective (T010 appears three times, once per repository), and that every document
in the coverage matrix has a creating step. Open `docs/adr/README.md`: every link resolves.

## Owner approval (task T029)

The owner approved the plan and all seven ADRs on 2026-10-06 (see the Approval section of `docs/step-plan.md`).

## Decisions

ADR-001 to ADR-007, **Accepted** by the owner on 2026-10-06. At the same time the owner decided: Entra ID provider
id is `oid`; the package feed is GitHub Packages; the Tenant Middleware folder is `anchorpoint.middleware.api-`.

## Known limitations

- Several choices are marked unverified in the discovery (for example how the
  source and production read the Entra id claim).
- Steps for Tracks M and W are outlined, not detailed; they are refined when those tracks start.
- The plan could not detect every dependency between library components; the order in Track C is a
  reasonable build order, and steps that turn out to depend on a later one will be reordered.
