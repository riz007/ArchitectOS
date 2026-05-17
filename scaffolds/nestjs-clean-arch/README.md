# NestJS Clean Architecture Scaffold

Production-ready NestJS + TypeScript API following ArchitectOS clean architecture standards.

## Stack

| Concern | Technology |
|---|---|
| Framework | NestJS v10 |
| Language | TypeScript (strict mode) |
| ORM | TypeORM |
| Database | PostgreSQL |
| Cache | Redis |
| Auth | JWT + Passport |
| Validation | class-validator + class-transformer |
| API docs | Swagger / OpenAPI |
| Unit tests | Jest |
| E2E tests | Jest + Supertest |
| Process manager | PM2 (production) |

## Quick Start

```bash
# From the ArchitectOS repo
./tools/cli/scaffold.sh nestjs-clean-arch my-service

# Or manually
cd scaffolds/nestjs-clean-arch
cp .env.example .env
docker-compose up -d
npm install
npm run start:dev
```

## Project Structure

```
src/
├── domain/                    # Business rules — no framework dependencies
│   ├── entities/              # Domain entities (pure TypeScript classes)
│   ├── repositories/          # Repository interfaces (contracts)
│   ├── services/              # Domain service interfaces
│   └── errors/                # Domain error types
│
├── application/               # Use cases — orchestrates domain
│   ├── use-cases/             # One class per use case
│   │   ├── create-user/
│   │   │   ├── create-user.use-case.ts
│   │   │   ├── create-user.use-case.spec.ts
│   │   │   └── create-user.dto.ts
│   │   └── ...
│   └── services/              # Application-level services
│
├── infrastructure/            # Framework, database, HTTP — adapts domain
│   ├── http/
│   │   ├── controllers/       # Thin NestJS controllers
│   │   ├── dto/               # Request/response DTOs (class-validator)
│   │   ├── guards/            # JWT, roles guards
│   │   ├── filters/           # Global exception filters
│   │   └── interceptors/      # Logging, transform interceptors
│   ├── persistence/
│   │   ├── entities/          # TypeORM entity definitions
│   │   ├── repositories/      # TypeORM repository implementations
│   │   └── migrations/        # TypeORM migrations
│   ├── cache/                 # Redis integration
│   └── external/              # External service adapters (email, storage)
│
├── config/                    # Configuration loading and validation
│   ├── app.config.ts
│   ├── database.config.ts
│   └── env.schema.ts          # Zod schema for env validation
│
└── main.ts                    # Bootstrap, global middleware, Swagger

test/
├── unit/                      # Domain and use case unit tests
└── e2e/                       # Supertest E2E integration tests
```

## Architecture Patterns

### Thin controller

```typescript
// infrastructure/http/controllers/users.controller.ts
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly createUser: CreateUserUseCase) {}

  @Post()
  @HttpCode(201)
  create(@Body() dto: CreateUserDto, @CurrentUser() actor: UserPayload) {
    return this.createUser.execute({ ...dto, actorId: actor.userId })
  }
}
```

### Use case

```typescript
// application/use-cases/create-user/create-user.use-case.ts
@Injectable()
export class CreateUserUseCase {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly passwordService: PasswordService,
    private readonly events: EventPublisher,
  ) {}

  async execute(input: CreateUserInput): Promise<UserResponseDto> {
    const existing = await this.userRepository.findByEmail(input.email)
    if (existing) throw new ConflictError('Email already registered')

    const hash = await this.passwordService.hash(input.password)
    const user = User.create({ ...input, passwordHash: hash })

    await this.userRepository.save(user)
    await this.events.publish(new UserCreatedEvent(user.id, user.email))

    return UserResponseDto.fromDomain(user)
  }
}
```

### Repository interface (domain)

```typescript
// domain/repositories/user.repository.ts
export interface UserRepository {
  findById(id: string): Promise<User | null>
  findByEmail(email: string): Promise<User | null>
  save(user: User): Promise<void>
  delete(id: string): Promise<void>
}

export const USER_REPOSITORY = Symbol('UserRepository')
```

### Repository implementation (infrastructure)

```typescript
// infrastructure/persistence/repositories/typeorm-user.repository.ts
@Injectable()
export class TypeOrmUserRepository implements UserRepository {
  constructor(
    @InjectRepository(UserEntity)
    private readonly repo: Repository<UserEntity>,
  ) {}

  async findById(id: string): Promise<User | null> {
    const entity = await this.repo.findOne({ where: { id } })
    return entity ? UserMapper.toDomain(entity) : null
  }

  async save(user: User): Promise<void> {
    await this.repo.save(UserMapper.toEntity(user))
  }
}
```

### DTO with validation

```typescript
// infrastructure/http/dto/create-user.dto.ts
export class CreateUserDto {
  @IsEmail()
  @IsNotEmpty()
  email: string

  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, {
    message: 'Password must contain uppercase, lowercase, and number',
  })
  password: string

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  firstName: string

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  lastName: string
}
```

### Environment validation

```typescript
// config/env.schema.ts
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRY: z.string().default('15m'),
  JWT_REFRESH_EXPIRY: z.string().default('7d'),
})

export type Env = z.infer<typeof envSchema>
export const env = envSchema.parse(process.env)
```

## Environment Variables

```env
# .env.example
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://postgres:password@localhost:5432/{{PROJECT_NAME}}
REDIS_URL=redis://localhost:6379
JWT_SECRET=change-me-to-a-secure-random-string-at-least-32-chars
JWT_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d
```

## Commands

```bash
npm run start:dev        # Development with hot reload
npm run start:prod       # Production
npm run build            # Compile TypeScript
npm run test             # Unit tests
npm run test:cov         # Unit tests with coverage
npm run test:e2e         # E2E tests
npm run lint             # Lint + fix
npm run type-check       # TypeScript type check
npm run migration:generate -- src/migrations/MigrationName
npm run migration:run    # Apply pending migrations
npm run migration:revert # Revert last migration
```

## Playbook

See [NestJS Playbook](../../playbooks/nestjs/) for full architectural guidance.
