---
name: aos-feature
description: Generates a complete vertical feature slice following ArchitectOS patterns — service, controller, repository interface, DTOs, and unit tests in one pass. Use when user wants to generate, add, or implement a feature, endpoint, module, or domain entity.
---

# /aos-feature

```
/aos-feature <name> [stack]
```

## Examples

```
/aos-feature user nestjs
/aos-feature order fastapi
/aos-feature product react
/aos-feature invoice vue
```

## What gets generated

**Backend (NestJS / FastAPI):**

```
src/modules/<name>/
  dto/
    create-<name>.dto.ts     — validated input
    update-<name>.dto.ts
    <name>-response.dto.ts   — safe output (no entity exposure)
  entities/
    <name>.entity.ts         — domain entity
  repositories/
    <name>.repository.ts     — interface (not implementation)
  services/
    <name>.service.ts        — all business logic here
    <name>.service.spec.ts   — behavior-focused unit tests
  controllers/
    <name>s.controller.ts    — thin, one line per route
  <name>s.module.ts
```

**Frontend (React / Vue):**

```
src/modules/<name>s/
  api/<name>sApi.ts          — HTTP calls only, no logic
  hooks/use<Name>s.ts        — data fetching with React Query / Vue composable
  hooks/useCreate<Name>.ts   — mutation hook
  components/<Name>List.tsx  — display component
  components/<Name>Form.tsx  — form component
  types/<name>.ts
  index.ts                   — public API for the module
```

## Workflow

1. **Ask** for feature name and stack if not in the command. Ask frontend, backend, or fullstack.
2. **Generate all files in one pass** — complete and runnable, no placeholders.
3. **Include tests** — at minimum, happy path and one error path per service method.
4. **Summarize** — list every file created and note any assumptions (e.g. UUID PKs, JWT auth assumed).

## Code rules applied

- DTOs use class-validator (NestJS), Pydantic (FastAPI), or Zod (plain Node)
- Services throw domain errors — not HTTP exceptions
- Controllers have `@UseGuards(JwtAuthGuard)` on all non-public routes
- Repository interface lives in domain layer; implementation lives in infrastructure
- No `any` in TypeScript; type hints on all Python functions
- Test names: `should throw ConflictError when email is already taken`

## Stack patterns

Full code examples for NestJS, FastAPI, Vue, and React: See [REFERENCE.md](REFERENCE.md)
