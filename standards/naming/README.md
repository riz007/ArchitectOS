# ArchitectOS Naming Standards

Consistent naming reduces cognitive load and makes codebases navigable by both humans and AI agents. These conventions apply across all supported stacks.

## Universal Rules

- Names must express intent, not implementation detail
- Avoid abbreviations unless universally understood (`id`, `url`, `api`, `dto`)
- Do not use numeric suffixes (`handler2`, `serviceNew`) — rename with purpose
- Avoid negated booleans (`isNotLoading`, `hasNoErrors`) — invert the condition instead
- Boolean names start with `is`, `has`, `can`, `should`, or `was`

---

## TypeScript / JavaScript

| Artifact | Convention | Example |
|---|---|---|
| Variables | `camelCase` | `userId`, `orderTotal` |
| Functions | `camelCase` | `getUserById`, `calculateTax` |
| Classes | `PascalCase` | `UserService`, `OrderRepository` |
| Interfaces | `PascalCase` | `UserPayload`, `ApiResponse` |
| Type aliases | `PascalCase` | `UserId`, `EventHandler` |
| Enums | `PascalCase` | `UserRole`, `OrderStatus` |
| Enum members | `SCREAMING_SNAKE_CASE` | `UserRole.SUPER_ADMIN` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| Files | `kebab-case.ts` | `user-service.ts`, `api-client.ts` |
| Directories | `kebab-case` | `user-management/`, `shared-utils/` |
| React components | `PascalCase.tsx` | `UserCard.tsx` |
| Vue components | `PascalCase.vue` | `UserCard.vue` |
| Angular components | `kebab-case` selector | `<app-user-card>` |
| Composables (Vue) | `useNoun.ts` | `useAuth.ts`, `useOrders.ts` |
| Hooks (React) | `useNoun.ts` | `useAuth.ts`, `useOrders.ts` |
| Stores (Pinia) | `useNounStore.ts` | `useAuthStore.ts` |
| Test files | `*.spec.ts` / `*.test.ts` | `user.service.spec.ts` |

### Function Naming Patterns

```typescript
// Queries — return data, no side effects
getUserById(id: string): Promise<User>
findActiveOrders(): Promise<Order[]>
calculateOrderTotal(items: Item[]): number

// Commands — perform an action, may have side effects
createUser(dto: CreateUserDto): Promise<User>
sendWelcomeEmail(user: User): Promise<void>
publishOrderEvent(order: Order): void

// Guards / predicates — return boolean
isAuthenticated(user: User): boolean
canDeletePost(user: User, post: Post): boolean
hasPermission(user: User, permission: Permission): boolean

// Transformers / mappers
mapUserToDto(user: User): UserDto
toApiResponse<T>(data: T): ApiResponse<T>
```

---

## Python

| Artifact | Convention | Example |
|---|---|---|
| Variables | `snake_case` | `user_id`, `order_total` |
| Functions | `snake_case` | `get_user_by_id`, `calculate_tax` |
| Classes | `PascalCase` | `UserService`, `OrderRepository` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| Modules | `snake_case.py` | `user_service.py` |
| Packages | `snake_case` | `user_management/` |
| Type aliases | `PascalCase` | `UserId`, `EventHandler` |
| Private members | `_leading_underscore` | `_hash_password` |

```python
# Queries
def get_user_by_id(user_id: str) -> Optional[User]: ...
def find_active_orders() -> list[Order]: ...

# Commands
def create_user(dto: CreateUserDTO) -> User: ...
def send_welcome_email(user: User) -> None: ...

# Guards
def is_authenticated(user: User) -> bool: ...
def can_delete_post(user: User, post: Post) -> bool: ...
```

---

## Java

| Artifact | Convention | Example |
|---|---|---|
| Variables | `camelCase` | `userId`, `orderTotal` |
| Methods | `camelCase` | `getUserById`, `calculateTax` |
| Classes | `PascalCase` | `UserService`, `OrderRepository` |
| Interfaces | `PascalCase` | `UserRepository`, `EventPublisher` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| Enums | `PascalCase` | `UserRole`, `OrderStatus` |
| Enum constants | `SCREAMING_SNAKE_CASE` | `UserRole.SUPER_ADMIN` |
| Packages | `lowercase.dotted` | `com.acme.users.service` |
| Files | `PascalCase.java` | `UserService.java` |
| Test classes | `SubjectTest.java` | `UserServiceTest.java` |

---

## API Naming

### REST Endpoints

Use nouns (not verbs) for resource paths. Verbs are carried by HTTP methods.

```
# Collections
GET    /users
POST   /users

# Individual resources
GET    /users/{id}
PUT    /users/{id}
PATCH  /users/{id}
DELETE /users/{id}

# Nested resources
GET    /users/{id}/orders
POST   /users/{id}/orders

# Actions (use sparingly — prefer HTTP semantics)
POST   /orders/{id}/cancel
POST   /users/{id}/verify-email
```

Rules:
- Lowercase, hyphen-separated path segments: `/user-profiles`, not `/userProfiles`
- Plural nouns for collections: `/users`, not `/user`
- Consistent versioning: `/v1/users` or header-based `API-Version: 1`
- Query params for filtering/sorting: `?status=active&sort=createdAt`
- Never leak implementation details in paths (`/db/users/query`)

### Event / Message Naming

```
# Pattern: {domain}.{entity}.{past_tense_verb}
user.account.created
user.password.reset
order.payment.completed
order.shipment.dispatched
```

---

## Database Naming

| Artifact | Convention | Example |
|---|---|---|
| Tables | `snake_case` plural | `users`, `order_items` |
| Columns | `snake_case` | `user_id`, `created_at` |
| Primary keys | `id` | `id UUID PRIMARY KEY` |
| Foreign keys | `{table_singular}_id` | `user_id`, `order_id` |
| Indexes | `idx_{table}_{column(s)}` | `idx_users_email` |
| Unique constraints | `uq_{table}_{column(s)}` | `uq_users_email` |
| Check constraints | `chk_{table}_{rule}` | `chk_orders_positive_total` |
| Join tables | `{table1}_{table2}` | `users_roles`, `posts_tags` |
| Boolean columns | `is_` / `has_` prefix | `is_active`, `has_verified_email` |
| Timestamp columns | `created_at`, `updated_at`, `deleted_at` | |

---

## Git Naming

### Branches

```
feature/{ticket-id}-short-description
bugfix/{ticket-id}-short-description
hotfix/{ticket-id}-short-description
release/{version}
chore/{description}

# Examples
feature/AUTH-123-oauth2-google-login
bugfix/CART-456-fix-price-calculation
hotfix/SEC-789-patch-jwt-validation
release/2.4.0
```

### Commit Messages

Follow Conventional Commits:

```
<type>(<scope>): <short description>

[optional body]

[optional footer]

# Types: feat, fix, docs, style, refactor, perf, test, chore, ci, build
# Examples
feat(auth): add OAuth2 Google login
fix(cart): correct price calculation for discounted items
docs(api): update OpenAPI spec for /users endpoints
perf(db): add index on orders.created_at
test(auth): add unit tests for JWT refresh flow
chore(deps): bump typescript to 5.4
```

---

## Environment Variables

```
# Pattern: {SERVICE}_{COMPONENT}_{SETTING}
DATABASE_HOST
DATABASE_PORT
DATABASE_NAME
DATABASE_PASSWORD

JWT_SECRET
JWT_ACCESS_TOKEN_TTL
JWT_REFRESH_TOKEN_TTL

REDIS_URL
REDIS_TTL

EMAIL_SMTP_HOST
EMAIL_FROM_ADDRESS

STRIPE_SECRET_KEY
STRIPE_WEBHOOK_SECRET

# Boolean flags use 0/1 or true/false consistently
FEATURE_FLAG_DARK_MODE=true
DEBUG_LOGGING=false
```

---

## Component and Module Naming

### Frontend Feature Modules

```
features/
  auth/                    # Feature name: noun
    AuthLoginForm.vue      # Component: PascalCase, noun-last
    AuthRegisterForm.vue
    useAuth.ts             # Composable: use + noun
    useAuthStore.ts        # Store: use + noun + Store
    auth.service.ts        # Service: noun + .service
    auth.types.ts          # Types: noun + .types
    auth.api.ts            # API: noun + .api
```

### Backend Modules

```
modules/
  users/
    users.controller.ts
    users.service.ts
    users.repository.ts
    users.module.ts
    dto/
      create-user.dto.ts
      update-user.dto.ts
    entities/
      user.entity.ts
    interfaces/
      user.interface.ts
```
