# Step 01: Documentation repository baseline

**Track**: P (platform documentation) | **Task**: T004 | **Commit scope**: `docs(platform)`

## Goal

Turn this repository into the main documentation entry point for the platform, with the folder
structure and rules that later steps fill in.

## Starting state

An empty repository: a README with only a title and no other files.

## Changes

- Rewrote `README.md` as the entry point (purpose, where things live, primary source, how to contribute).
- Added the folders `docs/platform`, `docs/discovery`, `docs/adr`, `docs/steps` and `docs/process`,
  each with a short README saying what will be added and by which task.
- Added `.gitignore` (OS noise plus the same secret and key-material rules as the other repos).
- Added `CHANGELOG.md`, `docs/backlog.md` and the step index `docs/steps/README.md`.

## Files

- `README.md`, `.gitignore`, `CHANGELOG.md`
- `docs/backlog.md`, `docs/adr/README.md`, `docs/platform/README.md`, `docs/discovery/README.md`, `docs/process/README.md`
- `docs/steps/README.md`, `docs/steps/01-docs-baseline.md`

## Source mapping

| Source | Treatment | Why |
|--------|-----------|-----|
| `C:\MyWork\stepwise_identity\README.md` and `docs/` (architecture, reference, ADR folders) | Referenced, not copied | They are the model for the platform documentation set; discovery (task T011) records what is reused |
| (no counterpart) folder layout and ownership rules | New | The two-level documentation model (service docs plus main repo) is defined by this program's spec (FR-057, FR-058) |

## Resulting state

A documentation repository with a README entry point, folder structure and ignore rules. The next step adds CI checks.

## How to verify

- Open `README.md`; every link in the "Where things live" table resolves to an existing folder or
  is explicitly marked as added by a later task (`docs/step-plan.md` is created in task T019).
- `git check-ignore -v tempkey.jwk appsettings.Local.json .env` reports all three files ignored.

## Decisions

No new ADR. Implements the documentation ownership decision in the spec (FR-057, FR-058).

## Known limitations

- The Markdown link and Mermaid checks arrive in task T008; the step templates in task T009.
- The discovery step (task T018) is therefore step 02 in this repository.
