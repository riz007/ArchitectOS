# ArchitectOS Aider Conventions

This file configures Aider's behavior for ArchitectOS projects.

## Usage

Reference this file in your Aider session:

```bash
aider --read prompts/aider/conventions.md
```

Or set it as a persistent convention file in your `.aider.conf.yml`:

```yaml
read:
  - prompts/aider/conventions.md
```

---

## Engineering Standards

You are operating within the ArchitectOS framework. Apply these conventions to every change.

### Architecture Layering

- Business logic belongs in services — not controllers, route handlers, or components.
- Controllers and handlers must be thin. They receive input, call one service method, return output.
- Never access the database directly from a controller or UI component.
- Use DTOs for all API inputs and outputs. Never expose entity or ORM objects directly.
- Organize code by domain feature, not by technical layer (not `controllers/`, `services/` at the top).
- Repository interfaces abstract data access; implementations are injected dependencies.

### Code Quality

- Write explicit, strongly typed code. No `any` in TypeScript. No untyped Python functions.
- Follow Single Responsibility Principle. One module, one job.
- Use early returns to reduce nesting. Maximum 3 nesting levels per function.
- Keep functions under 20 lines. Extract to named helpers when they grow.
- No commented-out code, debug logs, or unresolved TODOs unless explicitly requested.

### Security

- Validate all external inputs at system boundaries using schema validators (Zod, class-validator, Pydantic).
- Never concatenate user input into SQL strings. Use parameterized queries.
- Never hardcode secrets or credentials. Use environment variables.
- Apply authorization checks on every state-changing endpoint.
- Strip sensitive fields (passwords, tokens) from outgoing API responses.

### Testing

- Include unit tests for all new business logic.
- Test behavior, not implementation detail. Name tests descriptively.
- Mock at system boundaries — HTTP clients, database connections, external APIs.
- Include edge cases and error paths in tests.

---

## TypeScript Conventions

```
- strict: true in tsconfig.json — mandatory
- interface for object shapes, type for unions and aliases
- Branded types for domain IDs: type OrderId = string & { __brand: 'OrderId' }
- Named exports over default exports
- async/await, never raw .then() chains
- No floating promises — always handle rejection
```

---

## Vue 3 Conventions

```
- Composition API with <script setup lang="ts"> exclusively
- Business logic in composables (useNoun.ts), not in components
- Never call API services directly in components
- defineProps<{...}>() and defineEmits<{...}>() for typed interfaces
- Return readonly refs from composables
```

---

## React Conventions

```
- Functional components only
- Custom hooks (useNoun.ts) for reusable stateful logic
- React Query or SWR for data fetching — not useEffect + fetch
- useMemo for expensive computations
- Co-locate state as close to usage as possible
```

---

## NestJS Conventions

```
- Thin controllers — delegate to service immediately
- class-validator decorators on every DTO
- @UseGuards(JwtAuthGuard) on every non-public route
- @Roles() decorator for RBAC
- Services stay single-purpose, split at ~150 lines
```

---

## FastAPI Conventions

```
- Pydantic BaseModel for all request and response shapes
- async def for every endpoint performing I/O
- Routers split by domain feature
- Dependency injection for services and repositories
- Never return raw dict from endpoints — use typed response models
```

---

## Python Conventions

```
- Type hints on all parameters and return values
- dataclass or Pydantic for data objects
- snake_case for functions/variables, PascalCase for classes
- async for all I/O operations
- No mutable default arguments
```

---

## Commit Message Format

Use conventional commits:

```
feat: add JWT refresh token rotation
fix: resolve N+1 query in order list endpoint
docs: add NestJS authentication playbook
refactor: extract email validation to shared utility
test: add unit tests for CreateUserUseCase
```

---

## File and Folder Naming

- TypeScript/JavaScript: `kebab-case.ts`, `kebab-case.service.ts`, `kebab-case.controller.ts`
- Vue components: `PascalCase.vue`
- Python: `snake_case.py`
- Java: `PascalCase.java`
- Tests co-located: `user.service.spec.ts` next to `user.service.ts`
