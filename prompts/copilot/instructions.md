# ArchitectOS GitHub Copilot Instructions

Place this file at `.github/copilot-instructions.md` to configure Copilot for your project.

---

## Project Context

This project follows ArchitectOS engineering standards. Copilot should generate code that is:

- Explicitly typed (TypeScript strict mode or Python type hints)
- Feature-organized by domain, not by technical layer
- Layered correctly: controllers → services → repositories
- Security-conscious by default

---

## Code Generation Rules

### TypeScript / JavaScript

- Always use strict TypeScript. No `any` type.
- Use `async/await` — never raw `.then()` chains.
- Prefer named exports over default exports.
- Use branded types for domain IDs: `type UserId = string & { __brand: 'UserId' }`.
- Destructure function parameters and return objects for clarity.
- Use `const` by default. `let` only when reassignment is needed. Never `var`.

### Architecture

- Services contain business logic. Controllers delegate to services.
- Every API input must be validated with a DTO or schema.
- Never expose entity objects directly in API responses — use response DTOs.
- Repository interfaces abstract data access. Concrete implementations are injected.
- Composables (Vue) and hooks (React) abstract stateful logic from components.

### Security

- All user inputs validated at the API boundary.
- Parameterized queries only — never concatenated SQL.
- Secrets from environment variables only — never hardcoded.
- Authorization guard on every non-public endpoint.
- `httpOnly` cookies for token storage — not localStorage for sensitive tokens.

### Testing

- Unit tests for all services and utilities.
- Test file co-located with source: `user.service.spec.ts` next to `user.service.ts`.
- Descriptive test names: `should throw NotFoundError when user does not exist`.
- Mock at system boundaries (HTTP, database), not internal collaborators.

---

## Vue 3 Patterns

```typescript
// Component pattern
<script setup lang="ts">
// Props
const props = defineProps<{ userId: string }>()
// Emits
const emit = defineEmits<{ updated: [user: User] }>()
// Composable for behavior
const { user, loading, error } = useUser(toRef(props, 'userId'))
</script>

// Composable pattern
export function useUser(userId: Ref<string>) {
  const user = ref<User | null>(null)
  const loading = ref(false)
  const error = ref<Error | null>(null)
  // fetch, transform, return reactive state
  return { user: readonly(user), loading: readonly(loading), error: readonly(error) }
}
```

---

## NestJS Patterns

```typescript
// Controller — thin, delegates to service
@Post()
@UseGuards(JwtAuthGuard)
async create(@Body() dto: CreateUserDto, @CurrentUser() actor: UserPayload) {
  return this.userService.create(dto, actor)
}

// Service — business logic lives here
async create(dto: CreateUserDto, actor: UserPayload): Promise<UserResponseDto> {
  const existing = await this.userRepository.findByEmail(dto.email)
  if (existing) throw new ConflictException('Email already registered')
  const user = await this.userRepository.save(User.create(dto))
  return UserResponseDto.fromDomain(user)
}
```

---

## FastAPI Patterns

```python
# Router
@router.post("/users", response_model=UserResponse, status_code=201)
async def create_user(
    body: CreateUserRequest,
    service: UserService = Depends(get_user_service),
    _: UserPayload = Depends(require_auth),
) -> UserResponse:
    return await service.create(body)

# Service
async def create(self, dto: CreateUserRequest) -> UserResponse:
    existing = await self.repo.find_by_email(dto.email)
    if existing:
        raise HTTPException(409, "Email already registered")
    user = await self.repo.save(User.from_request(dto))
    return UserResponse.from_domain(user)
```

---

## Error Handling

```typescript
// Domain error hierarchy — use these, not raw Error
export class AppError extends Error { ... }
export class NotFoundError extends AppError { ... }     // 404
export class ConflictError extends AppError { ... }     // 409
export class ValidationError extends AppError { ... }  // 400
export class AuthorizationError extends AppError { ... } // 403

// Global error handler maps domain errors to HTTP responses
// Services throw domain errors; the global filter converts them
```

---

## What NOT to Generate

- `console.log` in production code
- `any` type in TypeScript
- Raw SQL string concatenation
- Hardcoded configuration values
- Class components in React
- Options API in Vue (use Composition API)
- Direct database calls in controllers
- Business logic in Vue components or React components
