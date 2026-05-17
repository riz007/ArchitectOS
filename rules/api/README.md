# ArchitectOS API Rules

Design rules for REST and GraphQL APIs. Consistent API design reduces integration friction and allows AI agents to generate correct client code.

---

## REST API Rules

### Rule: Use Nouns for Resource Paths

HTTP methods express the action. Paths express the resource.

```
✅ POST   /users           → create a user
✅ GET    /users           → list users
✅ GET    /users/{id}      → get one user
✅ PUT    /users/{id}      → replace a user
✅ PATCH  /users/{id}      → partial update a user
✅ DELETE /users/{id}      → delete a user

❌ POST   /createUser
❌ GET    /getUser/{id}
❌ POST   /users/delete/{id}
```

Exception: use verb-based sub-paths for actions that do not map to CRUD operations:

```
POST /orders/{id}/cancel       ← trigger state transition
POST /users/{id}/verify-email  ← trigger a process
POST /payments/{id}/refund     ← trigger an action
```

---

### Rule: Use Correct HTTP Status Codes

| Scenario | Code |
|---|---|
| Created successfully | `201 Created` |
| Found / success | `200 OK` |
| No content (DELETE) | `204 No Content` |
| Bad input / validation error | `400 Bad Request` |
| Unauthenticated | `401 Unauthorized` |
| Authenticated but forbidden | `403 Forbidden` |
| Resource not found | `404 Not Found` |
| Conflict (duplicate) | `409 Conflict` |
| Unprocessable entity | `422 Unprocessable Entity` |
| Rate limited | `429 Too Many Requests` |
| Internal server error | `500 Internal Server Error` |
| Service unavailable | `503 Service Unavailable` |

Never return `200` for errors. Never use `500` for validation failures.

---

### Rule: Consistent Error Response Shape

All error responses must follow this structure:

```json
{
  "statusCode": 400,
  "error": "VALIDATION_ERROR",
  "message": "Request validation failed",
  "details": [
    {
      "field": "email",
      "message": "Must be a valid email address"
    },
    {
      "field": "password",
      "message": "Must be at least 8 characters"
    }
  ],
  "requestId": "req_01HXYZ..."
}
```

- `statusCode`: mirrors the HTTP status code
- `error`: machine-readable error code in `SCREAMING_SNAKE_CASE`
- `message`: human-readable summary
- `details`: optional array for field-level validation errors
- `requestId`: correlation ID for tracing (must be present on 5xx)

---

### Rule: Version All Public APIs

```
# Path-based versioning (recommended for REST)
/v1/users
/v2/users

# Header-based versioning (alternative)
API-Version: 2
```

- Never break an existing version without a deprecation period
- Document deprecated versions with a `Sunset` response header
- Maintain at minimum N-1 versions concurrently

---

### Rule: Paginate All Collection Endpoints

No collection endpoint may return an unbounded result set.

```json
// ✅ Consistent pagination envelope
{
  "data": [...],
  "pagination": {
    "page": 2,
    "perPage": 20,
    "total": 847,
    "totalPages": 43,
    "hasNextPage": true,
    "hasPreviousPage": true
  }
}
```

For large datasets, prefer cursor-based pagination:

```json
{
  "data": [...],
  "cursor": {
    "next": "eyJpZCI6Ijk5OTk4In0=",
    "previous": "eyJpZCI6Ijk5OTc5In0="
  }
}
```

Query parameter standards:
```
?page=1&perPage=20          ← offset pagination
?cursor=eyJpZCI6Ijk...      ← cursor pagination
?sort=createdAt&order=desc  ← sorting
?status=active&role=admin   ← filtering
?q=search+term              ← search
```

---

### Rule: Include Request IDs

Every response must include a correlation ID for tracing.

```typescript
// ✅ Middleware to attach request IDs
app.use((req, res, next) => {
  req.id = req.headers['x-request-id'] || crypto.randomUUID()
  res.setHeader('X-Request-Id', req.id)
  next()
})
```

---

### Rule: Use ISO 8601 for All Dates

```json
// ✅ ISO 8601 UTC
{
  "createdAt": "2024-03-15T14:30:00.000Z",
  "updatedAt": "2024-03-15T15:45:12.123Z",
  "expiresAt": "2024-04-15T00:00:00.000Z"
}

// ❌ Ambiguous formats
{
  "createdAt": "03/15/2024",
  "updatedAt": 1710510000
}
```

---

### Rule: camelCase for JSON Fields

```json
// ✅ camelCase
{
  "userId": "uuid-here",
  "firstName": "Jane",
  "lastName": "Smith",
  "createdAt": "2024-03-15T14:30:00.000Z"
}

// ❌ snake_case in JSON (database convention, not API convention)
{
  "user_id": "uuid-here",
  "first_name": "Jane"
}
```

---

### Rule: API Documentation is Mandatory

Every API must have an OpenAPI 3.0+ specification.

```yaml
# openapi.yaml
openapi: 3.0.3
info:
  title: My API
  version: 1.0.0
  description: API for My Application

paths:
  /users:
    post:
      summary: Create a user
      operationId: createUser
      tags: [Users]
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'
        '400':
          $ref: '#/components/responses/ValidationError'
        '409':
          $ref: '#/components/responses/ConflictError'
```

Serve the spec at `/docs` (Swagger UI) and `/openapi.json` in all non-production environments.

---

## Security Rules for APIs

### Rule: Authentication on All Non-Public Endpoints

```typescript
// ✅ Global guard with explicit opt-out for public routes
app.useGlobalGuards(new JwtAuthGuard())

// Public route opt-out
@Get('health')
@Public()  // Custom decorator that skips JwtAuthGuard
health() {}

// ❌ Opt-in authentication — developers forget to add guards
@Get('admin/users')
// No guard — this endpoint is accidentally public
async listAllUsers() {}
```

### Rule: CORS Must Be Explicitly Configured

Never use wildcard `*` CORS in production.

```typescript
// ✅ Explicit CORS configuration
app.enableCors({
  origin: process.env.CORS_ORIGINS.split(','),
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-Id'],
  credentials: true,
})

// ❌ Wildcard — allows any origin
app.enableCors({ origin: '*' })
```

### Rule: Rate Limit All Endpoints

```typescript
const defaultLimiter = rateLimit({ windowMs: 60_000, max: 100 })
const authLimiter = rateLimit({ windowMs: 900_000, max: 10 })
const uploadLimiter = rateLimit({ windowMs: 60_000, max: 10 })

app.use('/api', defaultLimiter)
app.use('/auth', authLimiter)
app.use('/upload', uploadLimiter)
```

---

## GraphQL Rules

### Rule: Always Set Query Depth Limits

```typescript
import depthLimit from 'graphql-depth-limit'

const server = new ApolloServer({
  schema,
  validationRules: [depthLimit(10)],  // Prevent deeply nested attacks
})
```

### Rule: Always Set Query Complexity Limits

```typescript
import { createComplexityLimitRule } from 'graphql-validation-complexity'

validationRules: [
  createComplexityLimitRule(1000, {
    onCost: (cost) => console.log('Query cost:', cost),
  }),
]
```

### Rule: Avoid N+1 with DataLoader

```typescript
// ✅ DataLoader batches and deduplicates loads
const userLoader = new DataLoader(async (ids: readonly string[]) => {
  const users = await userRepo.findByIds([...ids])
  return ids.map(id => users.find(u => u.id === id) ?? null)
})

// In resolver
@ResolveField('user')
async user(@Parent() order: Order) {
  return this.userLoader.load(order.userId)  // Batched, not N individual queries
}
```
