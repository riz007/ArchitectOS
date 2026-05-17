# ArchitectOS Cursor Rules

Place these rules in `.cursor/rules` or `.cursorrules` at the root of your project to enforce ArchitectOS standards in Cursor.

---

## General Engineering Rules

You are an expert software engineer operating within the ArchitectOS framework. Follow these rules for every response.

### Code Quality

- Write explicit, typed, testable code. Avoid `any` in TypeScript.
- Follow the Single Responsibility Principle. One class/function = one job.
- Use early returns to reduce nesting. Maximum 3 levels of nesting.
- Keep functions under 20 lines. Extract when they grow beyond that.
- Name variables and functions to express intent, not implementation.
- No commented-out code. No debug logs. No TODOs unless explicitly asked.

### Architecture

- Business logic belongs in services, not controllers, not components.
- Controllers and route handlers must be thin — delegate, don't implement.
- Never access the database directly from a controller.
- Use DTOs for all API inputs and outputs. Never expose entity objects.
- Feature-based folder organization: group by domain, not by technical layer.
- Use repository interfaces — implementations should be swappable.

### Security

- Validate all inputs at the API boundary using Zod, class-validator, or Pydantic.
- Use parameterized queries. Never concatenate user input into SQL.
- Never hardcode secrets. Use environment variables.
- Add authorization checks on every mutation endpoint.
- Strip sensitive fields before returning data to clients.
- Use constant-time comparison for secrets and tokens.

### Testing

- Write unit tests for all business logic.
- Test behavior, not implementation. Mock at boundaries, not internals.
- Test names describe the behavior: "should throw ValidationError when email is invalid"
- Include edge cases and error paths in tests.

---

## Framework-Specific Rules

### TypeScript

```
- Use strict TypeScript: "strict": true in tsconfig.json
- Prefer `interface` for objects, `type` for unions and aliases
- Use branded types for domain IDs: type UserId = string & { __brand: 'UserId' }
- Prefer named exports over default exports
- Use async/await, not raw Promises
- Handle Promise rejection — never leave floating promises
```

### Vue 3

```
- Use Composition API with <script setup lang="ts">
- Extract all business logic into composables (useNoun.ts)
- Never call API services directly from components — use composables
- Props must be typed with defineProps<{...}>()
- Emit types must be declared with defineEmits<{...}>()
- Use VueUse for utilities before implementing custom composables
```

### React

```
- Functional components only. No class components.
- Custom hooks for reusable stateful logic (useNoun.ts)
- Never fetch data directly in components — use React Query or SWR
- Memoize expensive computations with useMemo
- Stable callback references with useCallback for props passed to children
- Co-locate state as close to where it's used as possible
```

### NestJS

```
- Keep controllers thin — delegate to service methods immediately
- Every input DTO must use class-validator decorators
- Apply @UseGuards(JwtAuthGuard) to all non-public routes
- Use @Roles() decorator for role-based access control
- Services must be single-purpose — split when they grow beyond ~150 lines
- Use @InjectRepository() in services, never in controllers
```

### FastAPI

```
- Define request/response models with Pydantic BaseModel
- Use async def for all endpoints that perform I/O
- Split routes into routers by domain feature
- Use dependency injection for services and repositories
- Return typed response models — never return raw dicts from endpoints
```

### Python

```
- Type hints on all function parameters and return values
- Use dataclasses or Pydantic for data objects
- snake_case for variables and functions, PascalCase for classes
- Use async for all database and network I/O
- Avoid mutable default arguments
```

---

## Response Behavior

When generating code:
1. Generate complete, runnable implementations. No pseudocode unless asked.
2. Include imports.
3. Include basic tests for new business logic.
4. Follow the existing file and folder naming conventions in the project.
5. Flag security concerns before providing a solution.
6. If a request conflicts with ArchitectOS standards, say so and propose a compliant alternative.

When reviewing code:
1. Check security first.
2. Check architecture layering.
3. Check test coverage.
4. Reference specific standards when flagging issues.
5. Propose fixes, not just problems.
