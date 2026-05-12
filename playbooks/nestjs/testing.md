# NestJS Enterprise Testing

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

## Testing Pattern

- Use unit tests for core business logic
- Use integration tests for service/API interactions
- Use end-to-end tests for critical user journeys
- Mock external systems for reliability

## Scaling Advice

- Organize tests by feature to reduce complexity
- Keep test helpers reusable and small
- Use parallel test execution in CI
- Gate releases on complete test suites

## Production Deployment

- Run tests in CI before deployment
- Enforce coverage thresholds for critical modules
- Validate production build artifacts in smoke tests
- Capture test results and performance metrics

## AI Prompting Examples

- "Create a NestJS enterprise architecture guide with modules, controllers, and services."
- "Explain how to design a NestJS API layer that uses DTOs and validation."
- "Generate NestJS deployment recommendations for production-ready services."
