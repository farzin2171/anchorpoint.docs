# Step 03: Step and step-report templates

**Track**: P (platform documentation) | **Task**: T009 | **Commit scope**: `docs(platform)`

## Goal

Give every later step one agreed shape for its documentation and its hand-over report, so each step
document answers the same questions and can be followed literally.

## Starting state

The documentation baseline (step 01) and docs CI (step 02). `docs/process/` holds only a placeholder README.

## Changes

- Added `docs/process/step-template.md`: the template for `docs/steps/NN-<name>.md` with the sections
  required by the spec (goal, starting state, changes, files, source mapping, resulting state, how to
  verify, decisions, known limitations).
- Added `docs/process/step-report-template.md`: the report sent after each step.
- Rewrote `docs/process/README.md` as an index of the two templates.

## Files

- `docs/process/step-template.md`, `docs/process/step-report-template.md`, `docs/process/README.md`
- `docs/steps/03-process-templates.md`, `docs/steps/README.md`, `CHANGELOG.md`

## Source mapping

| Source | Treatment | Why |
|--------|-----------|-----|
| `C:\MyWork\stepwise_identity\src\*\README.md` (per-phase "what this phase adds and why" write-ups) | Adapted | The source explains each phase in prose per project; the template makes the same explanation uniform and adds a source-mapping table |
| (no counterpart) step-report template | New | The one-commit-per-step review rule is this program's constitution (principle I), not in the source |

## Resulting state

Templates exist. Every later step copies the step template and finishes with the step report.

## How to verify

```powershell
pwsh ./tools/check-mermaid.ps1     # expect: exit 0 (no diagrams yet)
```

Open `docs/process/README.md`; both links resolve. Compare any existing step document
(for example `docs/steps/01-docs-baseline.md`) with the template: the headings match.

## Decisions

None. Implements spec FR-051 and FR-052 and the stop-after-each-step rule (FR-010).

## Known limitations

- Steps 01 and 02 in each repository were written before the template existed; they were given a
  "Resulting state" section so they match it.
- The rule that a change to `src/` must come with a step document is enforced by CI in task T085.
