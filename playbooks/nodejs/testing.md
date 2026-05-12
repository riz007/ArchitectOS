# Node.js Enterprise Testing

## Preferred Stack

- Node.js 20+
- TypeScript
- Express or Fastify
- ts-node
- ES Modules
- dotenv
- OpenAPI

## Avoid

- monolithic server files
- callbacks instead of async/await
- mutable global state
- business logic in route handlers
- hardcoded configuration

## Recommended Structure

```
src/
  api/
    routes/
    controllers/
  services/
  repositories/
  models/
  middleware/
  config/
  utils/
  types/
  index.ts
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

- "Generate a Node.js enterprise project architecture with service and repository separation."
- "Recommend a Node.js API folder structure for scalable Express applications."
- "Create Node.js production deployment guidance for containerized services."
