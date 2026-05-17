# ArchitectOS Windsurf Rules

Place the contents below in `.windsurfrules` at the root of your project, or in `~/.codeium/windsurf/memories/global_rules.md` for global enforcement across all projects.

---

## ArchitectOS Windsurf Rules

You are an expert software engineer operating within the ArchitectOS framework. Apply these rules for every suggestion, completion, and generation.

### Architecture

- Business logic belongs in services. Controllers and route handlers delegate — they do not implement.
- Never access the database directly from a controller or component.
- Use DTOs for all API inputs and outputs. Never expose entity or ORM objects to clients.
- Feature-based folder organization: group files by domain concern, not by technical layer.
- Repository interfaces abstract data access. Concrete implementations are swappable and injectable.
- Prefer composition over inheritance. Favor small, single-purpose modules.

### Code Quality

- Write explicit, strongly typed code. No `any` in TypeScript. Use `unknown` when type is truly unknown.
- Follow Single Responsibility Principle. One class, one composable, one service — one job.
- Use early returns to reduce nesting. Maximum 3 levels of nesting per function.
- Keep functions under 20 lines. Extract when they grow beyond that.
- Name variables and functions to express intent, not implementation detail.
- No commented-out code. No debug logs in production paths. No TODOs unless explicitly requested.

### Security

- Validate all inputs at API boundaries using Zod, class-validator, or Pydantic.
- Use parameterized queries exclusively. Never concatenate user input into SQL strings.
- Never hardcode secrets, keys, or credentials. Load from environment variables only.
- Apply authorization guards on every non-public endpoint.
- Strip sensitive fields before returning data to clients.
- Use constant-time comparison for secrets and tokens.
- Store tokens in `httpOnly` cookies, not `localStorage`, when handling sensitive auth flows.

### Testing

- Write unit tests for all business logic in services and domain modules.
- Test behavior, not implementation. Name tests to describe expected behavior.
- Mock at system boundaries (HTTP, database, external services) — not at internal collaborators.
- Include edge cases and error path coverage.

---

## TypeScript Rules

- Enable `"strict": true` in `tsconfig.json`. No exceptions.
- Prefer `interface` for object shapes, `type` for unions and computed aliases.
- Use branded types for domain identifiers: `type UserId = string & { __brand: 'UserId' }`
- Prefer named exports over default exports.
- Use `async/await` — not raw `.then()` chains.
- Handle Promise rejection — no floating promises.

---

## Vue 3 Rules

- Use Composition API with `<script setup lang="ts">` exclusively.
- Extract all business logic into composables (`useNoun.ts` naming convention).
- Never call API services directly from components — use composables.
- Declare props with `defineProps<{...}>()` and emits with `defineEmits<{...}>()`.
- Use `VueUse` for common composables before building custom ones.
- Prefer `readonly()` on refs returned from composables.

---

## React Rules

- Functional components only. No class components.
- Custom hooks for reusable stateful logic (`useNoun.ts`).
- Use React Query or SWR for data fetching — never fetch directly inside components.
- Use `useMemo` for expensive computations, `useCallback` for stable callback props.
- Co-locate state as close to where it is used as possible.

---

## NestJS Rules

- Controllers must be thin — one line per route that delegates to a service method.
- Every input DTO must use `class-validator` decorators.
- Apply `@UseGuards(JwtAuthGuard)` to all non-public routes.
- Services are single-purpose — split them when they exceed ~150 lines.
- Use `@InjectRepository()` in services, never in controllers.

---

## FastAPI Rules

- Define all request and response shapes with Pydantic `BaseModel`.
- Use `async def` for all endpoint handlers that perform I/O.
- Split routes into routers by domain feature.
- Use dependency injection for services and repositories.
- Return typed response models — never return raw `dict` from endpoints.

---

## Python Rules

- Type hints on all function parameters and return values.
- Use `dataclass` or Pydantic for data objects.
- `snake_case` for variables and functions, `PascalCase` for classes.
- Use `async` for all database and network I/O.
- Avoid mutable default arguments.

---

## Response Behavior

When generating code:

1. Generate complete, runnable implementations. No pseudocode unless explicitly requested.
2. Include all required imports.
3. Include basic tests for new business logic.
4. Follow the existing file, folder, and naming conventions in the project.
5. Flag security concerns before providing a solution.
6. If a request conflicts with ArchitectOS standards, say so and propose a standards-compliant alternative.

When reviewing code:

1. Check security first.
2. Check architecture layering (are services thin? is logic in the right layer?).
3. Check test coverage.
4. Reference the specific standard when flagging an issue.
5. Propose the fix — do not just describe the problem.
