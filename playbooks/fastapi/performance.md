# FastAPI Enterprise Performance

## Preferred Stack

- FastAPI
- Pydantic
- SQLAlchemy or Tortoise ORM
- Alembic
- Uvicorn
- HTTPX
- Redis

## Avoid

- non-async database access in async endpoints
- mutable global state
- duplicated validation logic
- unbounded request payloads
- exposing internal errors to clients

## Recommended Structure

```
app/
  api/
    routers/
    dependencies/
  core/
    config.py
    security.py
  db/
    base.py
    session.py
  models/
  schemas/
  services/
  tests/
  main.py
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

- "Create a FastAPI enterprise architecture guide with typed routers and dependency injection."
- "Recommend a FastAPI production deployment checklist for async services."
- "Generate API layer best practices for FastAPI service contracts."
