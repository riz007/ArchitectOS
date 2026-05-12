# FastAPI Enterprise Architecture

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

### Why this structure?

- Keeps domain features isolated
- Makes reusable behavior easy to share
- Separates infrastructure from presentation
- Enables lazy loading and modular growth

## Scaling Advice

- Use feature modules so new domains can be added without broad refactors
- Keep service boundaries small and focused
- Use lazy loading for large modules
- Prefer encapsulated feature contracts over shared global state

## Production Deployment

- Build artifacts with optimization enabled
- Use environment-specific configuration for API endpoints and credentials
- Serve production assets from CDN or edge locations when appropriate
- Add health and metrics endpoints for observability
- Protect secrets and avoid exposing runtime internals

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
