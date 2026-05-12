# FastAPI Enterprise Testing

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

- "Create a FastAPI enterprise architecture guide with typed routers and dependency injection."
- "Recommend a FastAPI production deployment checklist for async services."
- "Generate API layer best practices for FastAPI service contracts."
