---
name: aos-generate
description: Multi-agent full-stack feature generator. Orchestrates three specialised agents — Architecture, Backend, Frontend — to design and generate a complete vertical slice in one pass. Use when user wants to generate a complete feature end-to-end, says "generate the full feature", or needs fullstack scaffolding beyond what /aos-feature provides.
---

# /aos-generate

Generate a complete full-stack feature using a coordinated chain of specialised agents.

```
/aos-generate <feature-name> [stack]
```

## Examples

```
/aos-generate user-management nestjs+vue
/aos-generate order-processing fastapi+react
/aos-generate notifications nestjs+react
/aos-generate product-catalogue fastapi+vue
```

## How it works

`/aos-generate` runs four agents in sequence. Each agent receives the output of the previous as context.

```
┌─────────────────────────────────────────────────────────┐
│                      /aos-generate                       │
└──────────────────────────┬──────────────────────────────┘
                           │
              ┌────────────▼────────────┐
              │   1. Architecture Agent  │
              │   Plans the feature:     │
              │   • Domain entities      │
              │   • API contract         │
              │   • Data model           │
              │   • Module boundaries    │
              └────────────┬────────────┘
                           │ architecture plan
              ┌────────────▼────────────┐
              │   2. Backend Agent       │
              │   Generates:             │
              │   • DTOs                 │
              │   • Domain entity        │
              │   • Repository interface │
              │   • Service + tests      │
              │   • Controller           │
              │   • Module               │
              └────────────┬────────────┘
                           │ API contract
              ┌────────────▼────────────┐
              │   3. Frontend Agent      │
              │   Generates:             │
              │   • API client module    │
              │   • Data-fetching hook   │
              │   • List component       │
              │   • Form component       │
              │   • Route + types        │
              └────────────┬────────────┘
                           │ complete feature
              ┌────────────▼────────────┐
              │   4. Review Agent        │
              │   Runs /aos-review on    │
              │   all generated files    │
              └─────────────────────────┘
```

## Workflow

### Step 1 — Gather requirements

Ask the user:
1. Feature name (if not provided)
2. Backend stack: `nestjs` or `fastapi`
3. Frontend stack: `vue` or `react`
4. Brief description: what does this feature do?
5. Any specific requirements: auth-protected? file uploads? pagination?

### Step 2 — Architecture Agent

Act as an Architecture Agent. Design the feature before writing any code.

Output a structured architecture plan:

```
## Architecture Plan: <feature-name>

### Domain Model
- Entity: <Name>
  - id: UUID
  - <field>: <type> — <purpose>
  ...

### API Contract
POST   /api/<resources>          — create
GET    /api/<resources>          — list (paginated)
GET    /api/<resources>/:id      — get one
PATCH  /api/<resources>/:id      — update
DELETE /api/<resources>/:id      — delete

### Business Rules
- <rule>: <description>
- <validation>: <when it applies>

### Module Boundaries
- <ModuleName> owns: <entities/logic>
- Depends on: <other modules, if any>

### Data Model
<table/schema definition>
```

### Step 3 — Backend Agent

Act as a Backend Agent. Using the architecture plan, generate all backend files with **no placeholders**.

Generate in this order:
1. `src/modules/<name>/dto/create-<name>.dto.ts`
2. `src/modules/<name>/dto/update-<name>.dto.ts`
3. `src/modules/<name>/dto/<name>-response.dto.ts`
4. `src/modules/<name>/entities/<name>.entity.ts`
5. `src/modules/<name>/repositories/<name>.repository.ts` (interface)
6. `src/modules/<name>/services/<name>.service.ts`
7. `src/modules/<name>/services/<name>.service.spec.ts`
8. `src/modules/<name>/controllers/<name>s.controller.ts`
9. `src/modules/<name>/<name>s.module.ts`

Rules:
- Services throw domain errors, not HTTP exceptions
- Controllers are thin — one line per route
- `@UseGuards(JwtAuthGuard)` on all non-public endpoints
- Tests cover: happy path, not-found, duplicate/conflict, unauthorized
- No `any` in TypeScript

### Step 4 — Frontend Agent

Act as a Frontend Agent. Using the API contract from the architecture plan, generate all frontend files with **no placeholders**.

Generate in this order:
1. `src/modules/<name>s/types/<name>.ts`
2. `src/modules/<name>s/api/<name>sApi.ts`
3. `src/modules/<name>s/hooks/use<Name>s.ts` (React) or `composables/use<Name>s.ts` (Vue)
4. `src/modules/<name>s/hooks/useCreate<Name>.ts` / `composables/useCreate<Name>.ts`
5. `src/modules/<name>s/components/<Name>List.tsx` / `<Name>List.vue`
6. `src/modules/<name>s/components/<Name>Form.tsx` / `<Name>Form.vue`
7. `src/modules/<name>s/index.ts`

Rules:
- API module does HTTP only — no logic
- Components handle loading, error, and empty states
- Forms validate before submit
- No `any` in TypeScript

### Step 5 — Review Agent

Run `/aos-review` on all generated files. Report any issues and fix them immediately.

## Output

```
## Generated: <feature-name>

### Architecture
✔ Domain model: <entities>
✔ API contract: <N> endpoints
✔ Business rules: <N> rules defined

### Backend (<stack>)
✔ src/modules/<name>/dto/create-<name>.dto.ts
✔ src/modules/<name>/dto/update-<name>.dto.ts
✔ src/modules/<name>/dto/<name>-response.dto.ts
✔ src/modules/<name>/entities/<name>.entity.ts
✔ src/modules/<name>/repositories/<name>.repository.ts
✔ src/modules/<name>/services/<name>.service.ts
✔ src/modules/<name>/services/<name>.service.spec.ts
✔ src/modules/<name>/controllers/<name>s.controller.ts
✔ src/modules/<name>/<name>s.module.ts

### Frontend (<stack>)
✔ src/modules/<name>s/types/<name>.ts
✔ src/modules/<name>s/api/<name>sApi.ts
✔ src/modules/<name>s/hooks/use<Name>s.ts
✔ src/modules/<name>s/components/<Name>List.tsx
✔ src/modules/<name>s/components/<Name>Form.tsx
✔ src/modules/<name>s/index.ts

### Review
✔ 0 failures · 0 warnings

Next steps:
1. Register <Name>sModule in AppModule
2. Add the <Name>s route to your router
3. Run: npm test src/modules/<name>/
```

## Full reference

See [REFERENCE.md](REFERENCE.md) for complete generated code examples.
