# NestJS Enterprise API Layer

## Preferred Stack

- NestJS 11
- TypeScript
- Modules
- Class Validator
- Swagger
- Fastify adapter
- CQRS optional

## Avoid

- fat controllers
- shared mutable providers
- direct database access in controllers
- business logic in decorators
- unclear module boundaries

## Recommended Structure

```
src/
  modules/
    auth/
      controllers/
      services/
      dto/
      entities/
    users/
  common/
    guards/
    interceptors/
    filters/
    decorators/
  config/
  shared/
  main.ts
```

## Recommended Pattern

- Centralize HTTP and API clients in shared services
- Use typed request/response models
- Keep components/controllers thin and delegate work to services
- Handle errors and validation at the boundary

## Scaling Advice

- Version API contracts where needed
- Keep feature APIs small and composable
- Use pagination and filtering for large datasets
- Cache repeated reads with consistent invalidation

## Production Deployment

- Enforce HTTPS and auth on all endpoints
- Use centralized logging and tracing for API requests
- Validate and sanitize all external input
- Use rate limiting and circuit breakers when needed

## Code Examples

### NestJS controller example
```ts
// src/modules/auth/auth.controller.ts
import { Controller, Post, Body } from "@nestjs/common"
import { AuthService } from "./auth.service"

@Controller("auth")
export class AuthController {
  constructor(private authService: AuthService) {}
  @Post("login")
  login(@Body() payload: LoginDto) {
    return this.authService.login(payload)
  }
}
```

### NestJS service example
```ts
// src/modules/auth/auth.service.ts
import { Injectable } from "@nestjs/common"

@Injectable()
export class AuthService {
  async login(payload: LoginDto) {
    // auth logic
  }
}
```

### NestJS root module
```ts
// src/app.module.ts
import { Module } from "@nestjs/common"
import { AuthModule } from "./modules/auth/auth.module"

@Module({
  imports: [AuthModule],
})
export class AppModule {}
```

## AI Prompting Examples

- "Create a NestJS enterprise architecture guide with modules, controllers, and services."
- "Explain how to design a NestJS API layer that uses DTOs and validation."
- "Generate NestJS deployment recommendations for production-ready services."
