# Node.js Enterprise Performance

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

- "Generate a Node.js enterprise project architecture with service and repository separation."
- "Recommend a Node.js API folder structure for scalable Express applications."
- "Create Node.js production deployment guidance for containerized services."
