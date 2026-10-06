# anchorpoint.docs

The **main documentation repository** for the Anchorpoint / DIT identity platform. It is the single
entry point for engineers: platform overview, repository map, service catalog, glossary,
cross-service flows, milestone tracker, local-run guide, and decisions that span services.

Each service keeps its own detailed documentation in its own repository, because that
documentation changes in the same commit as the code. This repository links to it; a document has
one authoritative original and is never hand-maintained in two places.

## Where things live

| Folder | Contents |
|--------|----------|
| [docs/platform/](docs/platform/) | Platform overview, repo map, service catalog, glossary, local-run guide, milestone tracker (added step by step, task T074 onward) |
| [docs/discovery/](docs/discovery/) | Analysis of the source projects (task T011 onward) |
| [docs/adr/](docs/adr/) | Architecture decisions that span services: ADR-001 to ADR-007 (task T021 onward) |
| [docs/process/](docs/process/) | Step and step-report templates, review and verification records |
| [docs/steps/](docs/steps/) | One document per step committed in this repository |
| [docs/step-plan.md](docs/step-plan.md) | The cross-track step plan (task T019) |

## Repositories

The authoritative list will be [docs/platform/repo-map.md](docs/platform/repo-map.md). The main
ones are `anchorpoint.lib.infrastructure`, `anchorpoint.service.user`, `anchorpoint.identity.gateway`,
`anchorpoint.middleware.api-` and `anchorpoint.agent.portal.mvc`.

## Primary source

The reference solution is `C:\MyWork\stepwise_identity`. Every step document records what came from
it, what changed and why.

## Contributing

One step is one commit. Each commit includes its step document (`docs/steps/NN-<name>.md`) and a
`CHANGELOG.md` entry, and uses Conventional Commits with the `docs(platform)` scope.
