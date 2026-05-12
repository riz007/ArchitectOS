# Fullstack SaaS Example

A complete SaaS application built with ArchitectOS standards, demonstrating Vue 3 frontend, NestJS backend, PostgreSQL database, and modern DevOps practices.

## Features

- 🔐 **Multi-tenant authentication** with JWT
- 👥 **User management** with role-based access
- 📊 **Dashboard** with analytics and reporting
- 💳 **Subscription management** with Stripe integration
- 📧 **Email notifications** with templates
- 🔍 **Advanced search** and filtering
- 📱 **Responsive design** with mobile support
- 🚀 **API-first architecture** with OpenAPI docs
- 🧪 **Comprehensive testing** (Unit, Integration, E2E)
- 📦 **Docker containerization**
- 🚢 **CI/CD pipeline** with GitHub Actions
- 📈 **Monitoring** with Prometheus/Grafana
- 🔒 **Security** best practices

## Tech Stack

### Frontend

- **Vue 3** with Composition API
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **Pinia** for state management
- **Vue Router** for routing
- **Axios** for HTTP requests

### Backend

- **NestJS** with modular architecture
- **TypeScript** throughout
- **PostgreSQL** with TypeORM
- **Redis** for caching and sessions
- **JWT** for authentication
- **Stripe** for payments

### Infrastructure

- **Docker** for containerization
- **Kubernetes** for orchestration
- **NGINX** for reverse proxy
- **PostgreSQL** for database
- **Redis** for caching
- **MinIO** for file storage

### DevOps

- **GitHub Actions** for CI/CD
- **Terraform** for infrastructure
- **Prometheus** for monitoring
- **Grafana** for dashboards
- **ELK Stack** for logging

## Architecture

### Clean Architecture Pattern

```
src/
├── domain/              # Business entities and rules
│   ├── entities/        # Domain entities
│   ├── services/        # Domain services
│   └── repositories/    # Repository interfaces
├── application/         # Application layer
│   ├── use-cases/       # Application use cases
│   ├── services/        # Application services
│   └── dto/             # Data transfer objects
├── infrastructure/      # Infrastructure layer
│   ├── controllers/     # HTTP controllers
│   ├── repositories/    # Repository implementations
│   ├── external/        # External service integrations
│   └── config/          # Configuration
└── presentation/        # Presentation layer
    ├── views/           # Frontend views
    ├── components/      # UI components
    └── stores/          # State management
```

## Domain Model

### Core Entities

```typescript
// domain/entities/user.ts
export class User {
  constructor(
    public readonly id: string,
    public email: string,
    public firstName: string,
    public lastName: string,
    public role: UserRole,
    public tenantId: string,
    public isActive: boolean = true,
    public createdAt: Date = new Date(),
    public updatedAt: Date = new Date(),
  ) {}

  get fullName(): string {
    return `${this.firstName} ${this.lastName}`;
  }

  updateProfile(firstName: string, lastName: string): void {
    this.firstName = firstName;
    this.lastName = lastName;
    this.updatedAt = new Date();
  }

  deactivate(): void {
    this.isActive = false;
    this.updatedAt = new Date();
  }
}

export enum UserRole {
  ADMIN = "admin",
  MANAGER = "manager",
  USER = "user",
}
```

```typescript
// domain/entities/organization.ts
export class Organization {
  constructor(
    public readonly id: string,
    public name: string,
    public domain: string,
    public subscriptionPlan: SubscriptionPlan,
    public isActive: boolean = true,
    public createdAt: Date = new Date(),
    public updatedAt: Date = new Date(),
  ) {}

  updateSubscription(plan: SubscriptionPlan): void {
    this.subscriptionPlan = plan;
    this.updatedAt = new Date();
  }

  deactivate(): void {
    this.isActive = false;
    this.updatedAt = new Date();
  }
}

export enum SubscriptionPlan {
  FREE = "free",
  PRO = "pro",
  ENTERPRISE = "enterprise",
}
```

### Domain Services

```typescript
// domain/services/auth-service.ts
export interface AuthService {
  hashPassword(password: string): Promise<string>;
  verifyPassword(password: string, hash: string): Promise<boolean>;
  generateTokens(user: User): { accessToken: string; refreshToken: string };
  verifyAccessToken(token: string): Promise<UserPayload>;
  verifyRefreshToken(token: string): Promise<string>;
}

export interface UserPayload {
  userId: string;
  email: string;
  role: UserRole;
  tenantId: string;
}
```

## Application Layer

### Use Cases

```typescript
// application/use-cases/create-user.ts
export class CreateUserUseCase {
  constructor(
    private userRepository: UserRepository,
    private authService: AuthService,
    private eventPublisher: EventPublisher,
  ) {}

  async execute(input: CreateUserInput): Promise<User> {
    // Validate input
    const validatedInput = CreateUserSchema.parse(input);

    // Check if user already exists
    const existingUser = await this.userRepository.findByEmail(
      validatedInput.email,
    );
    if (existingUser) {
      throw new ConflictError("User with this email already exists");
    }

    // Hash password
    const passwordHash = await this.authService.hashPassword(
      validatedInput.password,
    );

    // Create user
    const user = new User(
      crypto.randomUUID(),
      validatedInput.email,
      validatedInput.firstName,
      validatedInput.lastName,
      validatedInput.role || UserRole.USER,
      validatedInput.tenantId,
    );

    // Save user
    await this.userRepository.save(user);

    // Publish event
    await this.eventPublisher.publish(
      new UserCreatedEvent(user.id, user.email),
    );

    return user;
  }
}

export interface CreateUserInput {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  role?: UserRole;
  tenantId: string;
}
```

### Application Services

```typescript
// application/services/email-service.ts
export interface EmailService {
  sendWelcomeEmail(user: User): Promise<void>;
  sendPasswordResetEmail(email: string, resetToken: string): Promise<void>;
  sendSubscriptionUpgradeEmail(
    user: User,
    plan: SubscriptionPlan,
  ): Promise<void>;
}
```

## Infrastructure Layer

### Controllers

```typescript
// infrastructure/controllers/auth.controller.ts
@Controller("auth")
export class AuthController {
  constructor(
    private loginUseCase: LoginUseCase,
    private refreshTokenUseCase: RefreshTokenUseCase,
    private logoutUseCase: LogoutUseCase,
  ) {}

  @Post("login")
  @UseGuards(LocalAuthGuard)
  async login(@Request() req, @Body() body: LoginDto) {
    const result = await this.loginUseCase.execute({
      email: body.email,
      password: body.password,
      userAgent: req.get("User-Agent"),
      ipAddress: req.ip,
    });

    return {
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      user: result.user,
    };
  }

  @Post("refresh")
  async refresh(@Body() body: RefreshTokenDto) {
    const result = await this.refreshTokenUseCase.execute(body.refreshToken);
    return result;
  }

  @Post("logout")
  @UseGuards(JwtAuthGuard)
  async logout(@Request() req) {
    await this.logoutUseCase.execute(req.user.id);
    return { success: true };
  }
}
```

### Repositories

```typescript
// infrastructure/repositories/typeorm-user.repository.ts
@Injectable()
export class TypeORMUserRepository implements UserRepository {
  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
  ) {}

  async findById(id: string): Promise<User | null> {
    const entity = await this.userRepository.findOne({
      where: { id, isActive: true },
    });

    return entity ? this.mapToDomain(entity) : null;
  }

  async findByEmail(email: string): Promise<User | null> {
    const entity = await this.userRepository.findOne({
      where: { email, isActive: true },
    });

    return entity ? this.mapToDomain(entity) : null;
  }

  async save(user: User): Promise<void> {
    const entity = this.mapToEntity(user);
    await this.userRepository.save(entity);
  }

  private mapToDomain(entity: UserEntity): User {
    return new User(
      entity.id,
      entity.email,
      entity.firstName,
      entity.lastName,
      entity.role,
      entity.tenantId,
      entity.isActive,
      entity.createdAt,
      entity.updatedAt,
    );
  }

  private mapToEntity(user: User): UserEntity {
    const entity = new UserEntity();
    entity.id = user.id;
    entity.email = user.email;
    entity.firstName = user.firstName;
    entity.lastName = user.lastName;
    entity.role = user.role;
    entity.tenantId = user.tenantId;
    entity.isActive = user.isActive;
    entity.createdAt = user.createdAt;
    entity.updatedAt = user.updatedAt;
    return entity;
  }
}
```

## Frontend Implementation

### Store Management

```typescript
// presentation/stores/auth.ts
export const useAuthStore = defineStore("auth", () => {
  const user = ref<User | null>(null);
  const accessToken = ref<string | null>(null);
  const refreshToken = ref<string | null>(null);

  const isAuthenticated = computed(() => !!user.value);
  const userRole = computed(() => user.value?.role ?? null);

  const login = async (credentials: LoginCredentials) => {
    try {
      const response = await authApi.login(credentials);

      user.value = response.user;
      accessToken.value = response.accessToken;
      refreshToken.value = response.refreshToken;

      // Store tokens securely
      localStorage.setItem("accessToken", response.accessToken);
      localStorage.setItem("refreshToken", response.refreshToken);

      return response.user;
    } catch (error) {
      throw new AuthenticationError("Login failed");
    }
  };

  const logout = async () => {
    try {
      await authApi.logout();
    } finally {
      user.value = null;
      accessToken.value = null;
      refreshToken.value = null;

      localStorage.removeItem("accessToken");
      localStorage.removeItem("refreshToken");
    }
  };

  const refreshAccessToken = async () => {
    try {
      const response = await authApi.refresh(refreshToken.value!);
      accessToken.value = response.accessToken;
      localStorage.setItem("accessToken", response.accessToken);
      return response.accessToken;
    } catch (error) {
      await logout();
      throw error;
    }
  };

  const initializeAuth = async () => {
    const storedAccessToken = localStorage.getItem("accessToken");
    const storedRefreshToken = localStorage.getItem("refreshToken");

    if (storedAccessToken && storedRefreshToken) {
      accessToken.value = storedAccessToken;
      refreshToken.value = storedRefreshToken;

      try {
        user.value = await userApi.getCurrentUser();
      } catch (error) {
        await logout();
      }
    }
  };

  return {
    user,
    isAuthenticated,
    userRole,
    login,
    logout,
    refreshAccessToken,
    initializeAuth,
  };
});
```

### API Integration

```typescript
// presentation/services/api.ts
class ApiClient {
  private instance: AxiosInstance;

  constructor() {
    this.instance = axios.create({
      baseURL: import.meta.env.VITE_API_BASE_URL,
      timeout: 10000,
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    // Request interceptor
    this.instance.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem("accessToken");
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error),
    );

    // Response interceptor
    this.instance.interceptors.response.use(
      (response) => response,
      async (error) => {
        if (error.response?.status === 401) {
          // Try to refresh token
          try {
            const authStore = useAuthStore();
            await authStore.refreshAccessToken();

            // Retry original request
            const token = localStorage.getItem("accessToken");
            error.config.headers.Authorization = `Bearer ${token}`;
            return this.instance.request(error.config);
          } catch (refreshError) {
            // Refresh failed, logout
            const authStore = useAuthStore();
            authStore.logout();
            return Promise.reject(refreshError);
          }
        }
        return Promise.reject(error);
      },
    );
  }

  get<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return this.instance.get(url, config).then((res) => res.data);
  }

  post<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    return this.instance.post(url, data, config).then((res) => res.data);
  }

  put<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    return this.instance.put(url, data, config).then((res) => res.data);
  }

  delete<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return this.instance.delete(url, config).then((res) => res.data);
  }
}

export const apiClient = new ApiClient();
```

## Testing Strategy

### Unit Tests

```typescript
// domain/entities/user.test.ts
import { describe, it, expect } from "vitest";
import { User, UserRole } from "./user";

describe("User", () => {
  it("should create a user with correct properties", () => {
    const user = new User(
      "123",
      "john@example.com",
      "John",
      "Doe",
      UserRole.USER,
      "tenant-123",
    );

    expect(user.id).toBe("123");
    expect(user.email).toBe("john@example.com");
    expect(user.firstName).toBe("John");
    expect(user.lastName).toBe("Doe");
    expect(user.role).toBe(UserRole.USER);
    expect(user.tenantId).toBe("tenant-123");
    expect(user.isActive).toBe(true);
  });

  it("should return full name", () => {
    const user = new User(
      "123",
      "john@example.com",
      "John",
      "Doe",
      UserRole.USER,
      "tenant-123",
    );

    expect(user.fullName).toBe("John Doe");
  });

  it("should update profile", () => {
    const user = new User(
      "123",
      "john@example.com",
      "John",
      "Doe",
      UserRole.USER,
      "tenant-123",
    );

    user.updateProfile("Jane", "Smith");

    expect(user.firstName).toBe("Jane");
    expect(user.lastName).toBe("Smith");
  });

  it("should deactivate user", () => {
    const user = new User(
      "123",
      "john@example.com",
      "John",
      "Doe",
      UserRole.USER,
      "tenant-123",
    );

    user.deactivate();

    expect(user.isActive).toBe(false);
  });
});
```

### Integration Tests

```typescript
// application/use-cases/create-user.integration.test.ts
import { Test, TestingModule } from "@nestjs/testing";
import { CreateUserUseCase } from "./create-user";
import { UserRepository } from "../../domain/repositories/user-repository";
import { AuthService } from "../../domain/services/auth-service";
import { EventPublisher } from "../../domain/services/event-publisher";
import { InMemoryUserRepository } from "../../../test/repositories/in-memory-user-repository";
import { MockAuthService } from "../../../test/services/mock-auth-service";
import { MockEventPublisher } from "../../../test/services/mock-event-publisher";

describe("CreateUserUseCase", () => {
  let useCase: CreateUserUseCase;
  let userRepository: UserRepository;
  let authService: AuthService;
  let eventPublisher: EventPublisher;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CreateUserUseCase,
        {
          provide: UserRepository,
          useClass: InMemoryUserRepository,
        },
        {
          provide: AuthService,
          useClass: MockAuthService,
        },
        {
          provide: EventPublisher,
          useClass: MockEventPublisher,
        },
      ],
    }).compile();

    useCase = module.get<CreateUserUseCase>(CreateUserUseCase);
    userRepository = module.get<UserRepository>(UserRepository);
    authService = module.get<AuthService>(AuthService);
    eventPublisher = module.get<EventPublisher>(EventPublisher);
  });

  it("should create a user successfully", async () => {
    const input = {
      email: "john@example.com",
      password: "password123",
      firstName: "John",
      lastName: "Doe",
      tenantId: "tenant-123",
    };

    const user = await useCase.execute(input);

    expect(user.email).toBe(input.email);
    expect(user.firstName).toBe(input.firstName);
    expect(user.lastName).toBe(input.lastName);
    expect(user.tenantId).toBe(input.tenantId);
  });

  it("should throw error for duplicate email", async () => {
    const input = {
      email: "john@example.com",
      password: "password123",
      firstName: "John",
      lastName: "Doe",
      tenantId: "tenant-123",
    };

    await useCase.execute(input);

    await expect(useCase.execute(input)).rejects.toThrow(
      "User with this email already exists",
    );
  });
});
```

### E2E Tests

```typescript
// test/e2e/auth.e2e-spec.ts
import { Test, TestingModule } from "@nestjs/testing";
import { INestApplication } from "@nestjs/common";
import * as request from "supertest";
import { AppModule } from "../../src/app.module";
import { UserRepository } from "../../src/domain/repositories/user-repository";
import { InMemoryUserRepository } from "../repositories/in-memory-user-repository";

describe("Auth (e2e)", () => {
  let app: INestApplication;
  let userRepository: UserRepository;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(UserRepository)
      .useClass(InMemoryUserRepository)
      .compile();

    app = moduleFixture.createNestApplication();
    userRepository = moduleFixture.get<UserRepository>(UserRepository);
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  describe("/auth/login (POST)", () => {
    it("should login user with valid credentials", () => {
      return request(app.getHttpServer())
        .post("/auth/login")
        .send({
          email: "john@example.com",
          password: "password123",
        })
        .expect(201)
        .expect((res) => {
          expect(res.body).toHaveProperty("accessToken");
          expect(res.body).toHaveProperty("refreshToken");
          expect(res.body).toHaveProperty("user");
          expect(res.body.user.email).toBe("john@example.com");
        });
    });

    it("should return 401 for invalid credentials", () => {
      return request(app.getHttpServer())
        .post("/auth/login")
        .send({
          email: "john@example.com",
          password: "wrongpassword",
        })
        .expect(401);
    });
  });
});
```

## Deployment

### Docker Configuration

```dockerfile
# Dockerfile.backend
FROM node:18-alpine as build

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:18-alpine as production

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

COPY --from=build /app/dist ./dist
COPY --from=build /app/migrations ./migrations

USER node

EXPOSE 3000

CMD ["npm", "run", "start:prod"]
```

```dockerfile
# Dockerfile.frontend
FROM node:18-alpine as build

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose

```yaml
# docker-compose.yml
version: "3.8"

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: saas_app
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: postgresql://postgres:password@postgres:5432/saas_app
      REDIS_URL: redis://redis:6379
      JWT_SECRET: your-jwt-secret
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - backend

volumes:
  postgres_data:
```

### Kubernetes Manifests

```yaml
# k8s/backend-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: your-registry/backend:latest
          ports:
            - containerPort: 3000
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: database-url
            - name: REDIS_URL
              valueFrom:
                secretKeyRef:
                  name: redis-secret
                  key: redis-url
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: jwt-secret
                  key: secret
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
```

## Monitoring

### Application Metrics

```typescript
// infrastructure/monitoring/metrics.ts
import {
  register,
  collectDefaultMetrics,
  Gauge,
  Counter,
  Histogram,
} from "prom-client";

collectDefaultMetrics();

export const httpRequestDuration = new Histogram({
  name: "http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.1, 0.5, 1, 2, 5, 10],
});

export const activeUsers = new Gauge({
  name: "active_users_total",
  help: "Number of active users",
});

export const apiRequestsTotal = new Counter({
  name: "api_requests_total",
  help: "Total number of API requests",
  labelNames: ["method", "endpoint", "status"],
});

export const databaseQueryDuration = new Histogram({
  name: "database_query_duration_seconds",
  help: "Duration of database queries in seconds",
  labelNames: ["operation", "table"],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2],
});
```

### Health Checks

```typescript
// infrastructure/controllers/health.controller.ts
@Controller("health")
export class HealthController {
  constructor(
    private databaseHealthIndicator: DatabaseHealthIndicator,
    private redisHealthIndicator: RedisHealthIndicator,
  ) {}

  @Get()
  @HealthCheck()
  check() {
    return HealthCheckServiceBuilder.newBuilder()
      .addCheck("database", () =>
        this.databaseHealthIndicator.isHealthy("database"),
      )
      .addCheck("redis", () => this.redisHealthIndicator.isHealthy("redis"))
      .build()
      .check();
  }

  @Get("ready")
  @HealthCheck()
  readiness() {
    return HealthCheckServiceBuilder.newBuilder()
      .addCheck("database", () =>
        this.databaseHealthIndicator.isHealthy("database"),
      )
      .build()
      .check();
  }
}
```

## Security Implementation

### Authentication Middleware

```typescript
// infrastructure/auth/jwt-auth.guard.ts
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private authService: AuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      throw new UnauthorizedException();
    }

    try {
      const payload = await this.authService.verifyAccessToken(token);
      request.user = payload;
      return true;
    } catch (error) {
      throw new UnauthorizedException();
    }
  }

  private extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(" ") ?? [];
    return type === "Bearer" ? token : undefined;
  }
}
```

### Authorization Guard

```typescript
// infrastructure/auth/roles.guard.ts
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<UserRole[]>(
      "roles",
      [context.getHandler(), context.getClass()],
    );

    if (!requiredRoles) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user as UserPayload;

    return requiredRoles.some((role) => user.role?.includes(role));
  }
}

// Usage
@Controller("admin")
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
export class AdminController {
  // Only admins can access these endpoints
}
```

### Rate Limiting

```typescript
// infrastructure/middleware/rate-limit.middleware.ts
@Injectable()
export class RateLimitMiddleware implements NestMiddleware {
  private limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: "Too many requests from this IP, please try again later.",
    standardHeaders: true,
    legacyHeaders: false,
  });

  use(req: Request, res: Response, next: NextFunction) {
    this.limiter(req, res, next);
  }
}
```

This example demonstrates a complete, production-ready SaaS application built with ArchitectOS standards. It showcases clean architecture, comprehensive testing, security best practices, and modern DevOps approaches.
