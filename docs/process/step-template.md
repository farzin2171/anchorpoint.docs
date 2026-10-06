# Step template

Copy this file to `docs/steps/NN-<name>.md` in the repository that receives the commit. `NN` is the
next free step number in that repository. Delete these instructions and fill every section; a section
that does not apply says so in one sentence instead of being removed.

Write for a new engineer who has not seen the project. Include a Mermaid diagram when the step
changes a flow or a structure. Every command must work when run literally; run it before committing.

---

# Step NN: <title>

**Track**: <C | M | U | I | W | P> | **Task**: <T###> | **Commit scope**: <feat(infra) | feat(user) | feat(idsrv) | feat(tenant) | feat(web) | docs(platform) | chore | test | build>

## Goal

One or two sentences: what this step achieves and why it exists.

## Starting state

What is true before this step: the previous step's result, and anything the reader must already have.

## Changes

What this step adds, changes or removes, in plain language. Link the contract or ADR when behavior is
defined elsewhere instead of repeating it.

## Files

Every file created or modified, one per line.

## Source mapping

Every piece that derives from an existing source. The primary source is `C:\MyWork\stepwise_identity`;
secondary sources are `C:\work\Applications.IdentityGateway`, `C:\work\Services.User`,
`C:\work\ACME.API.Middleware` and `C:\work\Libraries.Infrastructure`.

| Source file | Treatment (kept as-is / adapted / dropped) | What changed and why |
|-------------|--------------------------------------------|----------------------|
| `C:\MyWork\stepwise_identity\src\...` | adapted | e.g. SQL Server provider replaced by Npgsql |

If nothing in a source corresponds to this step, write: "No source counterpart: <reason>".

## Resulting state

What is true after this step, and what the next step builds on. This is the starting state of the
next step.

## How to verify

Exact commands, with the expected result of each.

```powershell
dotnet build <solution>.slnx      # expect: 0 errors
dotnet test <solution>.slnx       # expect: all tests pass
```

## Decisions

ADRs created or relied on (link them). Write "None" when no architectural decision was made.

## Known limitations

What this step deliberately does not do, and the task or backlog item that will.
