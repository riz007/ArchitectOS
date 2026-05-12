# FastAPI Enterprise API Layer

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

## Recommended Pattern

- Centralize HTTP and API clients in shared services
- Use typed request/response models
- Keep components/controllers thin and delegate work to services
- Handle errors and validation at the boundary

## Scaling Advice

- Version API contracts where needed
- Keep feature APIs small and composable
- Use pagination and filtering for large datasets
- Cache repeated reads with consistent invalidation

## Production Deployment

- Enforce HTTPS and auth on all endpoints
- Use centralized logging and tracing for API requests
- Validate and sanitize all external input
- Use rate limiting and circuit breakers when needed

## Code Examples

### FastAPI app with router registry
```python
# app/main.py
from fastapi import FastAPI
from app.api.routers import auth

app = FastAPI()
app.include_router(auth.router)
```

### Pydantic settings
```python
# app/core/config.py
from pydantic import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    class Config:
        env_file = ".env"

settings = Settings()
```

### Dependency injection for request state
```python
# app/api/dependencies.py
from app.db.session import async_session

async def get_db():
    async with async_session() as session:
        yield session
```

## AI Prompting Examples

- "Create a FastAPI enterprise architecture guide with typed routers and dependency injection."
- "Recommend a FastAPI production deployment checklist for async services."
- "Generate API layer best practices for FastAPI service contracts."
