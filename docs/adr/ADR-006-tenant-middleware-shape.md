# ADR-006: Tenant Middleware shape and the stub-to-real data swap

**Status**: Accepted (owner approval 2026-10-06) | **Date**: 2026-10-06 | **Deciders**: project owner

## Context

The owner confirmed the Tenant Middleware is a **standalone service** (repository
`anchorpoint.middleware.api-`; the folder name, trailing hyphen included, was confirmed by the owner on 2026-10-06). It returns a person's tenant,
identity and groups, using deterministic dummy data first, and the dummy data must be replaceable by a real
backend without changing the contract.

Discovery found that `C:\work\ACME.API.Middleware` is **not** such a service: it is a mock insurance API for a
plugins system, with one identity-related controller that returns no tenant and a single role taken from the
first Entra group name. The reference solution has no tenant-and-groups service at all: its tenants live in
`Mini.UserService`, and groups do not exist. So the contract and the service are new design.

## Decision

1. **Standalone service** with one read operation, `POST /api/v1/identities/lookup` (contract in
   `docs/discovery/contracts.md`), secured with scope `tenant.read`.
2. **A single interface boundary** inside the service, `IIdentityDirectory` (name provisional), with one
   method that returns a tenant and its groups for an external identity. The HTTP layer depends only on this
   interface and on the contract DTOs.
3. **The stub is one implementation** of that interface, selected by configuration
   (`TenantDirectory:Provider = Stub`). A real backend is a second implementation selected by changing the
   configuration; the contract, endpoints and DTOs do not change.
4. **Stub data is deterministic and labeled**: a fixed set of tenants, groups and users with fixed ids, listed
   in `docs/stub-data.md`; every response from the stub carries `X-DIT-Data-Source: stub`.
5. **Every stub user belongs to exactly one tenant** (v1 rule). Groups belong to one tenant.
6. **The contract DTOs are a versioned package** (`Anchorpoint.Contracts.Tenant`). Until this repository
   exists they live temporarily in the User Service repository (step U-09) and move here in step M-03.
7. **Ownership of the tenant registry** belongs to the Tenant Middleware, decided when a real backend is
   chosen.
8. **Swap procedure** (documented in `docs/tenant-and-group-model.md` when built): implement the interface,
   add contract tests that both implementations must pass, switch the configuration, and remove the stub
   header only when the data is real.

## Consequences

- Good: the User Service is built and tested against a stable contract before the real backend exists.
- Good: the swap is a configuration change plus an implementation, with shared contract tests.
- Cost: the contract is designed here without a real data source; it may need a version bump when the real
  backend's shape is known.
- Cost: the contract DTOs have a temporary home and a later move, tracked in the backlog.

## Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| Keep tenants inside the User Service (reference solution) | The owner wants a separate Tenant Middleware service; the User Service must not own tenant data |
| Reuse `ACME.API.Middleware` | It is a mock insurance API and does not return tenants or groups |
| Hard-code stub data in the User Service | Defeats the separate service and the swap; stub data would leak into a production service |
| A package or library instead of a service | The owner confirmed a service |
