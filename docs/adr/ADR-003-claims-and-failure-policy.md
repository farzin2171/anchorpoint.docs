# ADR-003: Claims mapping contract and failure policy at each hop

**Status**: Accepted (owner approval 2026-10-06) | **Date**: 2026-10-06 | **Deciders**: project owner

## Context

The Identity Server issues tokens whose claims come from the User Service, which merges its own roles with
tenant and groups from the Tenant Middleware. The owner already decided (clarification, 2026-10-05): both
hops fail closed; the Identity Server does not cache profiles; unknown users are refused and never
auto-created; each user has exactly one tenant; users are matched by (provider, provider's stable user ID),
never by email.

Discovery found that production does the opposite on two points: it **fails open** (issues the token without
a role when the User Service errors) and **auto-creates** unknown external users. It also found that its
claims are `identityRole`, `tenantId` and `tenant`, and that the reference solution issues a prefixed
`external:{scheme}:{id}` subject, no `email` and no groups for federated users.

## Decision

1. **Claims issued** (one place: the Identity Server profile service):

   | Claim | Source | Notes |
   |-------|--------|-------|
   | `sub` | User Service `subject` | Internal opaque UUID, never the provider's id |
   | `name` | `name` | |
   | `email` | `email` | Informational |
   | `role` | `roles` | One claim per role |
   | `group` | `groups` | One claim per group key |
   | `tenant` | `tenant` | The tenant key, single value |

2. **Fail closed at both hops.** If the User Service cannot produce the full profile (not provisioned,
   inactive, upstream unavailable, timeout, error), sign-in is refused with a clear message and **no token
   with reduced claims is issued**. The User Service returns 404 (not provisioned) or 503 (upstream
   unavailable); it never returns a partial profile.
3. **No profile caching at the Identity Server.** Every sign-in asks the User Service, so role changes apply
   at the next sign-in.
4. **No caching at the User Service to Tenant Middleware hop in v1** (proposal). While the data is
   deterministic stub data a cache adds risk and no benefit. A short, configurable cache can be added with
   the real backend by a new decision; stale data must never be served on failure.
5. **Provider's stable user ID**: for Entra ID it is the **`oid`** claim (owner decision, 2026-10-06). `sub`
   is unique per application and changes if the application registration changes; `oid` is stable across
   applications. Other providers define their own claim in the provider configuration. Unverified: which claim
   the source and production read; the first Entra integration test must confirm `oid` is present in the
   tokens the Identity Server receives.
6. **Refusals are observable**: every refused sign-in is logged with the correlation id and reason, and the
   user sees a message that does not reveal internal details.
7. **Inbound claim mapping off** (`MapInboundClaims = false`) so claim names are exactly as issued.

## Consequences

- Good: no sign-in with wrong or missing access; outages are visible and testable (spec SC-010).
- Good: removes the production behaviors (fail open, auto-provision) that the owner rejected.
- Cost: an outage of the User Service or Tenant Middleware blocks every sign-in. Availability is a
  deployment concern, not solved here.
- Cost: every sign-in makes a network call chain (two hops); latency is the sum of both.
- The claim names differ from production (`role`, `group`, `tenant` instead of `identityRole`, `tenantId`,
  `tenant`); consumers must be written for the new names.

## Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| Fail open with reduced claims (production behavior) | Could silently grant wrong or no access; rejected by the owner |
| Short cache of profiles at the Identity Server | Role changes would lag; stale data on outage; rejected by the owner |
| Cache tenant and groups at the User Service now | Adds invalidation and staleness rules for stub data; deferred |
| Match users by email | Emails change and can be reused; rejected by the owner |
| `sub` as the provider id for Entra ID | Not stable across applications; the owner chose `oid` |
