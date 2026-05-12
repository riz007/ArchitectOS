# FastAPI Enterprise State Management

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

- "Create a FastAPI enterprise architecture guide with typed routers and dependency injection."
- "Recommend a FastAPI production deployment checklist for async services."
- "Generate API layer best practices for FastAPI service contracts."
