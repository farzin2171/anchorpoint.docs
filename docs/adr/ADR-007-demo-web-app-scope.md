# ADR-007: Demo Web App scope, client registration and environments

**Status**: Accepted (owner approval 2026-10-06) | **Date**: 2026-10-06 | **Deciders**: project owner

## Context

The Demo Web App demonstrates and tests sign-in end to end. The constitution (XII) makes it a test harness:
no production secrets and never deployed outside non-production. The reference solution has several
clients (`MvcClient`, `AgentPortal`, `ReactSpa`, `SampleApi`); the planned Demo Web App is one server-side
MVC application. Its repository folder is `anchorpoint.agent.portal.mvc`, which is not the name of the
reference project it derives from (`MvcClient`).

## Decision

1. **Scope**: one server-side (confidential) MVC application that signs in with authorization code and PKCE,
   shows the claims, ID and access token details, role and group based pages, and signs out. It may call a
   protected API with the access token as an optional demonstration.
2. **Not a product**: no business features, no persistence of its own beyond the session, no user
   management.
3. **Client registration**: one client, `demo-web`, confidential, code with PKCE, redirect and post-logout
   URIs for the development and test hosts only, scopes `openid`, `profile` and the platform scopes it shows.
   Its secret is supplied from user-secrets or an environment variable and seeded into the Identity Server
   from there.
4. **Environments**: development and test only. The registration is not created in any other environment, the
   application refuses to start when the environment name is production, and its documentation states the
   restriction at the top of the README.
5. **Source**: derived from `MvcClient` in the reference solution (adapted). `AgentPortal`, `ReactSpa` and
   `SampleApi` are out of scope. The folder name mismatch is recorded in the backlog.
6. **Timing**: Track W starts after the current phase (Tracks C, U, I). Until then the Identity Server is
   verified with a test client.

## Consequences

- Good: a clear, small harness; no production exposure; deterministic tests of the whole chain.
- Cost: end-to-end sign-in with a browser is not demonstrable until Track W exists.
- Cost: the application must carry a production-environment guard and the registration must be gated.

## Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| Single-page application client as in `ReactSpa` | Needs a public client and a different threat model; not required for the harness |
| Reuse `AgentPortal` | It imitates a business application with its own database and policy editing; far beyond a harness |
| Allow deployment to a shared staging environment | Violates constitution XII |
| Skip the Demo Web App and test with scripts only | Loses the end-to-end browser flow that documents sign-in for new engineers |
