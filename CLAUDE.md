# Claude Instructions for ArchitectOS

You are Claude, operating inside the ArchitectOS repository. Your job is to produce engineering outputs that are immediately useful, repo-aligned, and review-ready.

## Mission

- Use `SPEC.md` to understand the requested scope.
- Use `ARCHITECTURE.md`, `ENGINEERING_PRINCIPLES.md`, and `standards/` to validate design decisions.
- Use `playbooks/` for stack-specific implementation patterns.
- Use `rules/` as the source of automated validation expectations.

## How to work

- Prefer existing code and patterns over new abstractions.
- Keep changes minimal and feature-scoped.
- Avoid introducing new top-level folders or broad restructuring unless the task explicitly requires it.
- When the request is ambiguous, clarify requirements before generating code.

## Engineering principles

- Write explicit, testable, and composable code.
- Keep business rules out of UI/view layer artifacts.
- Keep controllers/handlers thin and delegate logic to services or domain modules.
- Keep technology-specific behavior inside `playbooks/` guidance and matching folders.
- Use strong typing whenever the target stack supports it.

## Stack guidance

### Vue

- Use Composition API and `script setup`.
- Keep components declarative and pull behavior into composables.
- Prefer feature-based module organization.

### React

- Use functional components and hooks.
- Avoid prop drilling by using local context or feature hooks.
- Keep side effects isolated and testable.

### Angular

- Use standalone components and explicit dependency injection.
- Keep services narrow and responsible for a single domain concern.
- Prefer typed models and avoid mutable shared state.

### Node.js / NestJS

- Keep controllers thin.
- Place business logic in services.
- Use DTOs, validation pipes, and explicit API contracts.
- Avoid direct database access in controller code.

### Python / FastAPI

- Use Pydantic for request/response models.
- Separate routers, services, and persistence modules.
- Use async I/O for network/database operations when appropriate.

### Java

- Use constructor injection and layered architecture.
- Keep controllers thin and services explicit.
- Avoid god objects and large uncontrolled service classes.

## Security and quality

- Never hardcode secrets.
- Always validate and sanitize inputs.
- Avoid exposing internal errors or stack traces.
- Use parameterized queries for database access.
- Enforce authorization checks where required.

## Testing expectations

- Include unit tests for business logic.
- Include integration or contract tests for API behavior when the feature is surface-facing.
- Avoid delivering untested critical flows.

## Performance expectations

- Design for lazy loading, caching, and efficient data access.
- Avoid unnecessary work on the critical path.
- Avoid N+1 query patterns and blocking I/O in async stacks.

## Output behavior

- Generate complete, runnable implementations when code is requested.
- Avoid placeholder code unless the user explicitly asks for a draft.
- Keep explanations concise and tied to the repository architecture.
- Document any notable assumptions or tradeoffs in comments or accompanying text.

## When to pause

Stop and ask for clarification if:

- the task conflicts with repository standards.
- the requested change would require new architectural conventions.
- the existing repo structure does not match the requested output.
- there is missing information about the target stack or requirements.
