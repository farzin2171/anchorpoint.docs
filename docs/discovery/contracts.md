# Contracts: Identity Server to User Service, and User Service to Tenant Middleware

**Task**: T017 | **Status**: approved by the owner on 2026-10-06 | **Authoritative copy**: this file

This is the first version of the two service contracts. When the contracts are finalized, each is
published as a versioned DTO package; until then this document is the single source. The earlier
outlines under `specs/001-identity-platform-build/contracts/` in `anchorpoint.identity.gateway` are
superseded by this file.

## Decisions the contracts encode

| Decision | Source |
|----------|--------|
| Users are matched by (provider, provider's stable user ID), never by email | Clarification 2026-10-05 |
| One tenant per user in v1 | Clarification 2026-10-05 |
| Both hops fail closed; no partial profile is ever returned | Clarification 2026-10-05 |
| The Identity Server does not cache profiles | Clarification 2026-10-05 |
| Unknown or inactive users are refused, never auto-created | Clarification 2026-10-05 |
| Authentication between services: OAuth2 client credentials, one client per caller, one scope per callee | Research R9, to be fixed in ADR-002 |
| Stub responses carry the header `X-DIT-Data-Source: stub` | Spec FR-024 |

## Common rules (both contracts)

- **Versioning**: the URL carries the major version (`/api/v1/...`). DTOs ship as SemVer packages
  (`Anchorpoint.Contracts.User`, `Anchorpoint.Contracts.Tenant`). A breaking change is a new major version.
- **Authentication**: `Authorization: Bearer <access token>` obtained with client credentials. The token
  must carry the callee's scope, otherwise the call returns 403.
- **Correlation**: callers send `X-Correlation-ID`; callees echo it and put it in logs and error bodies.
  A call without one gets a generated ID.
- **Errors**: `application/problem+json` (RFC 7807) with `type`, `title`, `status`, `detail` and
  `correlationId`. No stack traces and no internal identifiers.
- **Timeouts and retries**: callers apply a timeout, bounded retries on 5xx and network errors only, and
  a circuit breaker. Retrying a 4xx is never allowed.
- **Fail closed**: a callee that cannot produce the full answer returns an error, never a smaller answer.
- **Identifiers**: `subject` is an opaque, stable, internal UUID. Provider values appear only in requests.

## Contract 1: Identity Server to User Service

Scope: `user.read`. Caller: the Identity Server's profile service, at token issuance.

### DTOs

**ProfileLookupRequest**

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `provider` | string | yes | Non-empty. Provider key, lowercase (for example `entra`) |
| `providerUserId` | string | yes | Non-empty. The provider's stable user ID (open question 1 below) |

**UserProfile**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `subject` | string (UUID) | yes | Becomes the `sub` claim |
| `name` | string | yes | Display name; `name` claim |
| `email` | string | yes | Informational; `email` claim; never used for matching |
| `roles` | string[] | yes | Role keys; may be empty; `role` claims |
| `groups` | string[] | yes | Group keys from the Tenant Middleware; may be empty; `group` claims |
| `tenant` | string | yes | Exactly one tenant key; `tenant` claim |

**Problem**: `type`, `title`, `status`, `detail`, `correlationId` (all strings except `status`, an integer).

### Operation

`POST /api/v1/profiles/lookup`: body `ProfileLookupRequest`, returns `UserProfile`.

| Status | Meaning | Identity Server behavior |
|--------|---------|--------------------------|
| 200 | Merged profile | Issue tokens with the mapped claims |
| 400 | Invalid request | Treat as a bug; refuse sign-in, log |
| 401 | Missing or invalid token | Refuse sign-in, log as configuration error |
| 403 | Token lacks `user.read` | Refuse sign-in, log as configuration error |
| 404 | Not provisioned (unknown or inactive user) | Refuse sign-in with a clear "not provisioned" message |
| 503 | Upstream unavailable (Tenant Middleware) | Refuse sign-in with a clear error; no reduced-claims token |

```yaml
openapi: 3.0.3
info: { title: User Service API, version: 1.0.0-draft }
security: [ { bearer: [user.read] } ]
paths:
  /api/v1/profiles/lookup:
    post:
      summary: Resolve a signed-in person to their merged profile
      requestBody:
        required: true
        content:
          application/json:
            schema: { $ref: '#/components/schemas/ProfileLookupRequest' }
      responses:
        '200': { description: Merged profile, content: { application/json: { schema: { $ref: '#/components/schemas/UserProfile' } } } }
        '400': { description: Invalid request }
        '401': { description: Missing or invalid service token }
        '403': { description: Token lacks the user.read scope }
        '404': { description: Not provisioned }
        '503': { description: Tenant Middleware unavailable }
components:
  securitySchemes:
    bearer: { type: http, scheme: bearer, bearerFormat: JWT }
  schemas:
    ProfileLookupRequest:
      type: object
      required: [provider, providerUserId]
      properties:
        provider: { type: string }
        providerUserId: { type: string }
    UserProfile:
      type: object
      required: [subject, name, email, roles, groups, tenant]
      properties:
        subject: { type: string, format: uuid }
        name: { type: string }
        email: { type: string }
        roles: { type: array, items: { type: string } }
        groups: { type: array, items: { type: string } }
        tenant: { type: string }
```

### Claims the Identity Server issues from this contract

| Claim | From | Notes |
|-------|------|-------|
| `sub` | `subject` | Internal UUID, opaque |
| `name` | `name` | |
| `email` | `email` | |
| `role` | `roles` | One claim per role |
| `group` | `groups` | One claim per group |
| `tenant` | `tenant` | Single value |

## Contract 2: User Service to Tenant Middleware

Scope: `tenant.read`. Caller: the User Service, while building a profile.

### DTOs

**IdentityLookupRequest**: same fields and rules as `ProfileLookupRequest` (`provider`, `providerUserId`).

**TenantIdentity**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `tenant` | object `{ key, name }` | yes | Exactly one tenant |
| `groups` | array of `{ key, name }` | yes | May be empty; all belong to `tenant` |
| `displayName` | string | no | Informational |
| `email` | string | no | Informational |

### Operation

`POST /api/v1/identities/lookup`: body `IdentityLookupRequest`, returns `TenantIdentity`.

| Status | Meaning | User Service behavior |
|--------|---------|-----------------------|
| 200 | Tenant and groups | Merge with roles |
| 401 / 403 | Token missing, invalid, or lacking `tenant.read` | Return 503 upstream-unavailable, log as configuration error |
| 404 | Identity unknown to the tenant data source | Return 404 not provisioned: a person without a tenant cannot sign in |
| 5xx, timeout, network error | Unavailable | Retry within limits, then return 503 |

While backed by stub data, every 200 response carries `X-DIT-Data-Source: stub`.

```yaml
openapi: 3.0.3
info: { title: Tenant Middleware API, version: 1.0.0-draft }
security: [ { bearer: [tenant.read] } ]
paths:
  /api/v1/identities/lookup:
    post:
      summary: Get a person's tenant and groups
      requestBody:
        required: true
        content:
          application/json:
            schema: { $ref: '#/components/schemas/IdentityLookupRequest' }
      responses:
        '200':
          description: Tenant and groups
          headers:
            X-DIT-Data-Source: { schema: { type: string, example: stub } }
          content: { application/json: { schema: { $ref: '#/components/schemas/TenantIdentity' } } }
        '401': { description: Missing or invalid service token }
        '403': { description: Token lacks the tenant.read scope }
        '404': { description: Identity unknown }
components:
  securitySchemes:
    bearer: { type: http, scheme: bearer, bearerFormat: JWT }
  schemas:
    IdentityLookupRequest:
      type: object
      required: [provider, providerUserId]
      properties:
        provider: { type: string }
        providerUserId: { type: string }
    TenantIdentity:
      type: object
      required: [tenant, groups]
      properties:
        tenant:
          type: object
          required: [key, name]
          properties: { key: { type: string }, name: { type: string } }
        groups:
          type: array
          items:
            type: object
            required: [key, name]
            properties: { key: { type: string }, name: { type: string } }
        displayName: { type: string }
        email: { type: string }
```

## Differences from the source (so nobody reintroduces them)

| Source behavior | This contract |
|-----------------|---------------|
| Identity Server calls a tenant API and a user API separately | One call to the User Service; the User Service calls the Tenant Middleware |
| Calls authenticate with a self-issued JWT and no scope | Real client-credentials tokens with a scope per callee |
| Role lookup by local user id, or by email | Lookup by (provider, provider user ID) only |
| Role is one string; production fails open and issues a token without it | Roles are a list; failure refuses sign-in |
| Id-conversion callback from User Service to Identity Server | Removed (no circular dependency) |
| Federated `sub` is `external:{scheme}:{id}` | `sub` is an internal opaque UUID |

## Owner review (2026-10-06)

Approved as written: one tenant claim holding the tenant key (question 2), group claims holding keys (question 3), a temporary home for the DTO packages in the User Service repository (question 4), and the Tenant Middleware owning the tenant registry (question 5). **Question 1 was settled on 2026-10-06**: for Entra ID, `providerUserId` is the `oid` claim (ADR-003).

## Open questions

1. **Stable provider ID**: decided, `oid` for Entra ID (ADR-003). Unverified until the first Entra integration test confirms the claim is present.
2. **Tenant claim value**: a readable tenant `key` (proposed) or a GUID? Production issues both `tenant` and `tenantId`.
3. **Groups as keys or names**: proposed keys in the `group` claim.
4. **Where the contract DTO packages live** until Track M exists (temporary home in the User Service repository, per task T048).
5. **Who owns the tenant registry** long term (Tenant Middleware, per ADR-006, decided when real data replaces the stub).
