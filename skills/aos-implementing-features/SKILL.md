---
name: aos-implementing-features
description: Apply ArchitectOS layering and patterns when adding or changing application code — new endpoints, services, controllers, components, hooks, repositories, DTOs, or domain entities. Use proactively whenever writing a feature, route, module, form, or data-fetching layer, even if the user did not ask for a review. Keeps business logic in services, controllers thin, inputs validated at the boundary, and entities out of API responses.
---

# Implementing features the ArchitectOS way

This is a model-invoked discipline. When you are about to write or modify feature code,
follow these rules before producing the code — not after. They are self-contained here;
you do not need the rest of the repo present.

## The layering contract

```
HTTP / UI  →  Controller / Component  →  Service (use case)  →  Repository  →  DB
                     (thin)              (all business logic)   (interface)
```

- **Controllers / route handlers** delegate in one line. No `if/else`, no calculations,
  no DB calls, no validation logic. Parse request → call service → map result.
- **Services / use cases** hold all business logic. They throw **domain errors**
  (`ConflictError`, `NotFoundError`), never HTTP exceptions.
- **Repositories** are interfaces in the domain layer; implementations live in
  infrastructure. Services depend on the interface.
- **UI components** never call HTTP directly. They call a hook / composable that calls an
  API module. No business logic in components.

## Always-on rules

- **Validate at the boundary** — Zod, class-validator, or Pydantic on every input DTO.
- **Never expose entities** — return a response DTO; strip password hashes, internal flags.
- **No `any`** in TypeScript (use `unknown` or a real type); type hints on all Python defs.
- **Auth guard** on every state-changing or sensitive route.
- **Verify resource ownership** before read or mutation (IDOR check).
- **Parameterised queries** only — never string-concatenate SQL.
- **Feature-based folders** — group by domain (`modules/order/...`), not by technical layer.
- **Tests with the code** — at minimum a happy path and one error path per service method.
  See [aos-tdd](../aos-tdd/SKILL.md) when the change is behavior-driven.

## Target structure (backend)

```
src/modules/<name>/
  dto/            create / update / response DTOs
  entities/       domain entity
  repositories/   <name>.repository.ts   (interface)
  services/       <name>.service.ts + <name>.service.spec.ts
  controllers/    <name>s.controller.ts  (thin)
  <name>s.module.ts
```

## Target structure (frontend)

```
src/modules/<name>s/
  api/<name>sApi.ts        HTTP only, no logic
  hooks/use<Name>s.ts      data fetching (React Query / Vue composable)
  components/<Name>List.*  display
  components/<Name>Form.*  form
  types/<name>.ts
  index.ts                 public surface of the module
```

## Before you finish

- Did logic leak into a controller or component? Move it to the service.
- Is every input validated and every output a DTO?
- Are there tests for the error path, not just the happy path?

For an explicit, on-demand generation of a full slice use `/aos-feature`. For a standards
pass over what you wrote use `/aos-review`.
