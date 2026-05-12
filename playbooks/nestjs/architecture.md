# NestJS Enterprise Architecture

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

### Why this structure?

- Keeps domain features isolated
- Makes reusable behavior easy to share
- Separates infrastructure from presentation
- Enables lazy loading and modular growth

## Scaling Advice

- Use feature modules so new domains can be added without broad refactors
- Keep service boundaries small and focused
- Use lazy loading for large modules
- Prefer encapsulated feature contracts over shared global state

## Production Deployment

- Build artifacts with optimization enabled
- Use environment-specific configuration for API endpoints and credentials
- Serve production assets from CDN or edge locations when appropriate
- Add health and metrics endpoints for observability
- Protect secrets and avoid exposing runtime internals

## Code Examples

### NestJS controller example

```ts
// src/modules/auth/auth.controller.ts
import { Controller, Post, Body } from "@nestjs/common";
import { AuthService } from "./auth.service";

@Controller("auth")
export class AuthController {
  constructor(private authService: AuthService) {}
  @Post("login")
  login(@Body() payload: LoginDto) {
    return this.authService.login(payload);
  }
}
```

### NestJS service example

```ts
// src/modules/auth/auth.service.ts
import { Injectable } from "@nestjs/common";

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
import { Module } from "@nestjs/common";
import { AuthModule } from "./modules/auth/auth.module";

@Module({
  imports: [AuthModule],
})
export class AppModule {}
```

## AI Prompting Examples

- "Create a NestJS enterprise architecture guide with modules, controllers, and services."
- "Explain how to design a NestJS API layer that uses DTOs and validation."
- "Generate NestJS deployment recommendations for production-ready services."
