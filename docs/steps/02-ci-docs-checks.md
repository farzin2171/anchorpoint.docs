# Step 02: CI pipeline for documentation (GitHub Actions)

**Track**: P (platform documentation) | **Task**: T008 | **Commit scope**: `build`

## Goal

Every push and pull request checks that the documentation's links and diagrams are well formed and
that no secret has been committed, so documentation does not rot silently.

## Starting state

The documentation baseline from step 01 (README, folder READMEs, no CI).

## Changes

- Added `.github/workflows/ci.yml` with two jobs:
  - **Docs checks**: a Markdown link check (lychee, offline mode, in-repo links and anchors) and a
    Mermaid structural check.
  - **Secret scan**: full-history gitleaks scan, same as the code repositories.
- Added `tools/check-mermaid.ps1`: finds every ```` ```mermaid ```` block in the Markdown files and
  fails if one is empty or does not start with a known diagram keyword. It is a structural check,
  not a full parse.

## Files

- `.github/workflows/ci.yml`, `tools/check-mermaid.ps1`
- `docs/steps/02-ci-docs-checks.md`, `docs/steps/README.md`, `CHANGELOG.md`

## Source mapping

| Source | Treatment | Why |
|--------|-----------|-----|
| `C:\MyWork\stepwise_identity\.github\workflows\` | Nothing to port | The folder exists but contains no workflow files |
| (no counterpart) | New | Docs checks are a program requirement (spec FR-042, FR-047) |

## Resulting state

Every push and pull request checks links, Mermaid blocks and secrets. The next step adds the step templates.

## How to verify

```powershell
pwsh ./tools/check-mermaid.ps1          # exit code 0 (no diagrams yet)
```

To see it fail, put a block starting with `notadiagram` inside a ```` ```mermaid ```` fence in any
`.md` file and run it again: exit code 1. After pushing to GitHub, the **Actions** tab shows both
jobs green.

## Decisions

CI system: GitHub Actions (owner's choice). The link check runs `--offline`, so it only checks
links inside this repository; cross-repository links are checked by `tools/check-links.ps1` (task T080).

## Known limitations

- The Mermaid check is structural. A real render check can replace it later.
- The workflow could not be executed locally; the first GitHub run is the real test.
- Step templates (T009) and the discovery step (T018) follow; each takes the next step number.
