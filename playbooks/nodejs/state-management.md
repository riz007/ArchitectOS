# Node.js Enterprise State Management

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

- "Generate a Node.js enterprise project architecture with service and repository separation."
- "Recommend a Node.js API folder structure for scalable Express applications."
- "Create Node.js production deployment guidance for containerized services."
