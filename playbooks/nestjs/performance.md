# NestJS Enterprise Performance

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

## Core Performance Patterns

- Lazy load large modules and routes
- Memoize expensive computations
- Use async streams and chunked response handling
- Keep the critical path small and fast

## Scaling Advice

- Profile regularly and remove bottlenecks
- Move heavy work off the main thread where possible
- Use caching and CDNs for static assets
- Optimize database queries and pagination

## Production Deployment

- Enable build optimizer and minification
- Use compression and asset caching
- Add health checks and failure recovery
- Monitor latency and error rates in production

## AI Prompting Examples

- "Create a NestJS enterprise architecture guide with modules, controllers, and services."
- "Explain how to design a NestJS API layer that uses DTOs and validation."
- "Generate NestJS deployment recommendations for production-ready services."
