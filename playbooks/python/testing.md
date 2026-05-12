# Python Enterprise Testing

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

- "Create a Python enterprise playbook for FastAPI with Pydantic and SQLAlchemy."
- "Explain Python state management patterns for request-scoped dependencies."
- "Generate production deployment advice for a FastAPI service."
