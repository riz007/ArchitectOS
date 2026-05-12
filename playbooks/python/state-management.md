# Python Enterprise State Management

## Preferred Stack

- Python 3.12+
- FastAPI
- Pydantic
- SQLAlchemy
- Alembic
- Uvicorn
- Poetry or pip

## Avoid

- global mutable state in app modules
- blocking I/O in async endpoints
- hardcoded credentials
- mixing business rules into routers
- large untyped data structures

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
  utils/
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

- "Create a Python enterprise playbook for FastAPI with Pydantic and SQLAlchemy."
- "Explain Python state management patterns for request-scoped dependencies."
- "Generate production deployment advice for a FastAPI service."
