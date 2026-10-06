# ADR-002: Service-to-service authentication

**Status**: Accepted (owner approval 2026-10-06) | **Date**: 2026-10-06 | **Deciders**: project owner

## Context

Two internal calls exist: Identity Server to User Service (`user.read`), and User Service to Tenant
Middleware (`tenant.read`). Discovery found that both the reference solution and the production
Identity Gateway call downstream services with a **self-issued JWT that carries no scope**, and that the
caller kind (user versus service) is inferred from the absence of a `sub` claim. The target flow in the
specification requires real client credentials with a scope per callee. Four different token clients exist
across the code bases, with different cache margins (1 s, 30 s, 90 percent) and error contracts
(`docs/discovery/infrastructure-inventory.md`).

## Decision

1. **OAuth 2.0 client credentials** against the Identity Server's token endpoint. The Identity Server is
   the only token authority.
2. **One client per calling service**, and one API resource with one scope per callee:

   | Caller | Callee | Client | Scope |
   |--------|--------|--------|-------|
   | Identity Server (profile service) | User Service | `identity-server` | `user.read` |
   | User Service | Tenant Middleware | `user-service` | `tenant.read` |

3. **One shared token client** (library component `ServiceAuth`, step C-10): requests a token, caches it in
   memory until `expires_in` minus 30 seconds, and throws one documented exception type on failure. No
   per-service copy.
4. **Callee validation**: JWT bearer validation against the Identity Server authority and the callee's
   audience, plus a scope-based authorization policy (`user.read`, `tenant.read`) from the library `Auth`
   component. Inbound claim mapping is off (`MapInboundClaims = false`) so `sub` and `scope` keep their names.
5. **Service identity is explicit**, not inferred from a missing `sub`: the callee checks the scope.
6. **Secrets**: client secrets come from user-secrets, environment variables or Key Vault references. They
   are seeded into the Identity Server's configuration store at startup from those sources, never from the
   repository.
7. **The per-tenant client naming** (`{clientId}.{tenant}`) used by the reference solution is not adopted
   in v1: one tenant per user and no per-tenant service accounts yet.

## Consequences

- Good: callee authorization is real and testable (a token without the scope gets 403); one token client to
  maintain; revoking a caller is one client.
- Good: closes the "self-issued token without scope" gap found in discovery.
- Cost: the Identity Server calls its own token endpoint over HTTP when it needs a token for the User
  Service. The call is cached, and Duende does not run the profile service for client-credentials grants,
  so there is no deadlock; but it is a dependency of the Identity Server on itself.
- Cost: callee configuration needs the authority URL and audience in every environment.
- Per-tenant service accounts are a future decision when multi-tenant service access is needed.

## Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| Self-issued JWT in-process (`IdentityServerTools`), as the reference solution does | Works without a network call, but the token is not a real client-credentials token with a registered client; harder to revoke and to audit; production and reference both end with scope-less tokens |
| Mutual TLS between services | Heavier infrastructure; not required for a development and test platform |
| Shared static API key | No scopes, no expiry, no revocation; rejected on security grounds |
| Per-tenant client per service (reference solution) | Adds a tenant dimension that v1 does not need |
