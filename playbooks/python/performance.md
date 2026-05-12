# Python Enterprise Performance

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

- "Create a Python enterprise playbook for FastAPI with Pydantic and SQLAlchemy."
- "Explain Python state management patterns for request-scoped dependencies."
- "Generate production deployment advice for a FastAPI service."
