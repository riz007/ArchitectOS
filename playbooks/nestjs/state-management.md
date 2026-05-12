# NestJS Enterprise State Management

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

## Core Patterns

- Use request-scoped state and dependency injection
- Keep shared mutable state isolated behind service boundaries
- Use caching layers for expensive reads
- Keep session or request context minimal

## Scaling Advice

- Keep feature stores or service state small and focused
- Normalize collections and avoid nested state blobs
- Use lazy hydration for large state sets
- Persist only minimal authenticated session data

## Production Deployment

- Avoid persisting secrets in local or shared state
- Initialize state from secure server-side sources
- Evict or invalidate stale cache data on changes
- Clear transient state on logout or session expiry

## AI Prompting Examples

- "Create a NestJS enterprise architecture guide with modules, controllers, and services."
- "Explain how to design a NestJS API layer that uses DTOs and validation."
- "Generate NestJS deployment recommendations for production-ready services."
