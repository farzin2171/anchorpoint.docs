# ADR-001: How Libraries.Infrastructure is consumed, versioned and released

**Status**: Accepted (owner approval 2026-10-06) | **Date**: 2026-10-06 | **Deciders**: project owner

## Context

Every .NET project in every track must use the shared library `anchorpoint.lib.infrastructure` for
cross-cutting concerns and must never copy its code (constitution IX). The library is built
incrementally: a small v0.1.0 first, then grown. We must be able to (a) consume a released, versioned
build, and (b) test library changes together with a consumer.

Facts that shape the decision:

- The team's existing convention (`C:\work\Applications.Apply`) has three solutions per application and an
  MSBuild property `IncludeInfrastructureSource` that switches package references to project references;
  library versions are pinned in `build/Versions.props`.
- The production library `C:\work\Libraries.Infrastructure` is proprietary ("Copyright Equisoft. All
  rights reserved") and lives on an internal Azure DevOps feed. Discovery
  (`docs/discovery/infrastructure-inventory.md`) treats it as a design reference only. The new library
  is an original implementation under this repository's own licence and must not depend on any
  `DigitalInsuranceTools.*` package.
- No package feed exists yet. The owner chose **GitHub Packages** (NuGet registry) as the feed.
- Consumers' CI runs on GitHub Actions.

## Decision

1. **Two reference modes in every consuming repository.**
   - Package mode (default): `PackageReference` to the library packages at the version in
     `build/Versions.props` (`AnchorpointInfrastructureVersion`).
   - Source mode: `ProjectReference` to the sibling library repository, enabled when the property
     `IncludeInfrastructureSource` is `true`. It is `true` automatically when the solution name ends in
     `.WithLibrary` and can be forced with `-p:IncludeInfrastructureSource=true`.
2. **Two solutions per consuming repository**: `<repo>.slnx` (package mode) and `<repo>.WithLibrary.slnx`
   (also lists the library projects, source mode). CI builds and tests both.
3. **One package per component**, named `Anchorpoint.Infrastructure.<Component>`, no umbrella package that
   pulls unrelated dependencies.
4. **SemVer with git tags.** The version comes from tags `vMAJOR.MINOR.PATCH` in the library repository.
   While below 1.0.0, a MINOR bump may break. A consumer upgrades deliberately by editing
   `Versions.props` in its own commit.
5. **Feed: GitHub Packages.** The library repository publishes its packages to the GitHub Packages NuGet
   registry of the owning GitHub account or organization (`https://nuget.pkg.github.com/<owner>/index.json`;
   the owner name is to be filled in when the repositories are pushed). A tag-triggered release workflow
   builds, tests, packs and publishes. Consumers declare the source in a `nuget.config` and authenticate with
   the workflow's `GITHUB_TOKEN` in CI (read access to the package is granted to each consuming repository in
   the package settings) and with a personal access token (scope `read:packages`) on developer machines. A
   local folder feed (`artifacts/packages`, produced by `build/pack-local.ps1`) is kept for developers who
   want to test an unreleased build and for the first release before anything is published.
6. **Release flow.** A change that a service needs is merged and released in the library first (own
   commit, docs, version bump, tag), then consumed in a later commit of the service. A service never adds
   the code locally "to move later".
7. **Licence.** The library is an original implementation. Design ideas may come from the discovery
   documents; code is not copied from the proprietary library.

## Consequences

- Good: library changes can be tested with a real consumer (source mode) before release; released builds
  are reproducible (package mode); no copy-paste.
- Good: matches the convention the team already knows.
- Cost: two solutions per repository and a conditional reference block in each project file.
- Cost: every consuming repository needs package-read access and a feed credential (`GITHUB_TOKEN` in CI, a
  personal access token locally), documented in the library's `docs/consuming.md`.
- Cost: GitHub Packages requires the repositories to be on GitHub under one owner; until they are pushed,
  only the local folder feed and source mode work.
- Cost: the library version is pinned per consumer, so upgrades need an explicit commit in each consumer.

## Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| Git submodule of the library in each service | Couples histories, conflicts with one repository per track |
| Copy the code into each service | Forbidden by constitution IX; creates divergent copies |
| Single solution with only project references | Cannot test the released, versioned artifact; services could not pin versions |
| Azure Artifacts as the feed | Not chosen by the owner; GitHub Packages keeps source, CI and packages in one place |
| Single mono-repository | Rejected by the program structure (one repository per track) |
| Depend on the proprietary `DigitalInsuranceTools.*` packages | Not publicly installable; licensing; pulls Azure and Redis transitively |
