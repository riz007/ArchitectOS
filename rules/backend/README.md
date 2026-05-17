# ArchitectOS Backend Rules

Validation rules for backend code across Node.js, NestJS, Python, FastAPI, and Java stacks. These rules enforce the patterns described in `playbooks/` and `standards/`.

---

## Architecture Rules

### Rule: Controllers Must Be Thin

Controllers receive requests, delegate to services, and return responses. They must not contain business logic.

```typescript
// ✅ Thin controller
@Post()
async createUser(@Body() dto: CreateUserDto, @Request() req: RequestWithUser) {
  const user = await this.userService.create(dto, req.user)
  return UserResponseDto.fromDomain(user)
}

// ❌ Business logic in controller
@Post()
async createUser(@Body() dto: CreateUserDto) {
  // Controller doing too much:
  const existing = await this.db.users.findOne({ email: dto.email })
  if (existing) throw new ConflictException()
  const hash = await bcrypt.hash(dto.password, 12)
  const user = await this.db.users.create({ ...dto, password: hash })
  await this.mailer.send({ to: user.email, subject: 'Welcome' })
  return user
}
```

**ESLint custom rule**: `architect-os/no-business-logic-in-controllers`
**Trigger**: Method bodies in `@Controller` classes exceeding 10 statements

---

### Rule: No Direct Database Access in Controllers

Controllers must not import or reference ORM entities, repositories, or raw database clients.

```typescript
// ❌ Repository injected directly into controller
@Controller('users')
export class UserController {
  constructor(
    @InjectRepository(UserEntity)
    private userRepo: Repository<UserEntity>, // Not allowed in controller
  ) {}
}

// ✅ Service layer in between
@Controller('users')
export class UserController {
  constructor(private userService: UserService) {}
}
```

---

### Rule: Use DTOs for All API Inputs and Outputs

Never accept or return raw entity objects at the API boundary. Always transform through DTOs.

```typescript
// ✅ DTO with validation decorators
import { IsEmail, IsString, MinLength, MaxLength } from 'class-validator'

export class CreateUserDto {
  @IsEmail()
  email: string

  @IsString()
  @MinLength(8)
  @MaxLength(72)
  password: string

  @IsString()
  @MinLength(1)
  @MaxLength(100)
  firstName: string
}

// ✅ Response DTO that controls what is exposed
export class UserResponseDto {
  id: string
  email: string
  firstName: string
  lastName: string
  role: string
  createdAt: string

  static fromDomain(user: User): UserResponseDto {
    const dto = new UserResponseDto()
    dto.id = user.id
    dto.email = user.email
    dto.firstName = user.firstName
    dto.lastName = user.lastName
    dto.role = user.role
    dto.createdAt = user.createdAt.toISOString()
    return dto
  }
  // Note: password hash is never included
}
```

---

### Rule: Services Must Have Single Responsibility

A service class must be responsible for one domain concept. Split services that grow beyond ~200 lines.

```typescript
// ❌ God service
export class UserService {
  createUser() {}
  deleteUser() {}
  sendEmail() {}          // email is a separate concern
  processPayment() {}     // payment is a separate concern
  generateReport() {}     // reporting is a separate concern
}

// ✅ Focused services
export class UserService { createUser(); deleteUser(); updateProfile() }
export class EmailService { sendWelcomeEmail(); sendPasswordReset() }
export class PaymentService { processPayment(); refundPayment() }
```

---

## Validation Rules

### Rule: Validate All Inputs at the API Boundary

Every controller action that accepts user input must use a validation pipe or schema.

```typescript
// NestJS — enable globally
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,        // Strip unknown properties
  forbidNonWhitelisted: true,  // Reject unknown properties
  transform: true,        // Auto-transform payloads to DTO instances
  transformOptions: {
    enableImplicitConversion: true,
  },
}))

// FastAPI — Pydantic validates automatically when using type hints
@app.post('/users')
async def create_user(user: CreateUserRequest) -> UserResponse:
    # Pydantic already validated 'user' before this runs
    return await user_service.create(user)
```

---

### Rule: Never Trust Path Parameters Without Validation

```typescript
// ✅ Validate path params are the expected type
@Get(':id')
async getUser(@Param('id', ParseUUIDPipe) id: string) {
  return this.userService.findById(id)
}

// ❌ Raw string from URL — could be SQL injection or garbage
@Get(':id')
async getUser(@Param('id') id: string) {
  return this.userService.findById(id)
}
```

---

## Security Rules

### Rule: Authorization Check on Every Mutation

Every `POST`, `PUT`, `PATCH`, `DELETE` endpoint must have explicit authorization validation.

```typescript
// ✅ Authorization guard applied
@Delete(':id')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
async deleteUser(@Param('id', ParseUUIDPipe) id: string) {
  await this.userService.delete(id)
}

// ❌ No authorization — any unauthenticated request can delete users
@Delete(':id')
async deleteUser(@Param('id') id: string) {
  await this.userService.delete(id)
}
```

---

### Rule: Never Log Sensitive Fields

Passwords, tokens, credit card numbers, and PII must never appear in logs.

```typescript
// ✅ Log safe fields only
this.logger.log('User login attempt', { email: credentials.email, ip })

// ❌ Logs the password
this.logger.log('Login attempt', { ...credentials })

// ✅ Sanitize before logging DTOs
const logSafe = { ...dto }
delete logSafe.password
delete logSafe.creditCardNumber
this.logger.debug('Creating user', logSafe)
```

---

### Rule: Use Parameterized Queries Only

Never concatenate user input into SQL strings.

```typescript
// ✅ Parameterized query
const user = await db.query(
  'SELECT * FROM users WHERE email = $1',
  [email]
)

// ✅ ORM query builder (uses parameterization internally)
const user = await userRepo.findOne({ where: { email } })

// ❌ String concatenation — SQL injection risk
const user = await db.query(
  `SELECT * FROM users WHERE email = '${email}'`
)
```

---

## Error Handling Rules

### Rule: Never Expose Internal Errors to Clients

All unhandled errors must be caught by a global error handler that sanitizes the response.

```typescript
// ✅ Global exception filter (NestJS)
@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp()
    const response = ctx.getResponse<Response>()

    if (exception instanceof HttpException) {
      const status = exception.getStatus()
      response.status(status).json(exception.getResponse())
      return
    }

    // Log the real error internally, return a safe message externally
    this.logger.error('Unhandled exception', { exception })
    response.status(500).json({
      statusCode: 500,
      message: 'Internal server error',
    })
  }
}

// ❌ Stack trace leaking to client
res.status(500).json({ error: exception.stack })
```

---

### Rule: Use Domain Error Types

Define a typed error hierarchy. Do not throw raw `Error` objects from services.

```typescript
// ✅ Domain error types
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 500,
  ) {
    super(message)
    this.name = this.constructor.name
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} ${id} not found`, 'NOT_FOUND', 404)
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(message, 'CONFLICT', 409)
  }
}

export class AuthorizationError extends AppError {
  constructor(message = 'Forbidden') {
    super(message, 'FORBIDDEN', 403)
  }
}
```

---

## Observability Rules

### Rule: Every Service Must Have Health Endpoints

```typescript
// ✅ /health — liveness probe
@Get('health')
health() {
  return { status: 'ok', timestamp: new Date().toISOString() }
}

// ✅ /ready — readiness probe (checks dependencies)
@Get('ready')
async ready() {
  const dbOk = await this.db.isConnected()
  const redisOk = await this.cache.isConnected()

  if (!dbOk || !redisOk) {
    throw new ServiceUnavailableException('Dependencies not ready')
  }

  return { status: 'ready' }
}
```

---

### Rule: Structured Logging Required

All log output must be structured JSON in production. Never use `console.log` in production code.

```typescript
// ✅ Structured logging with context
this.logger.log({
  message: 'Order created',
  orderId: order.id,
  userId: user.id,
  total: order.total,
  durationMs: Date.now() - startTime,
})

// ❌ Unstructured — ungreppable in production
console.log('Order created: ' + order.id)
```
