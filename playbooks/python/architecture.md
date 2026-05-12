# Python Enterprise Architecture

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

### FastAPI router example
```python
# app/api/routers/auth.py
from fastapi import APIRouter
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth")

@router.post("/login")
async def login(payload: LoginSchema):
    return await AuthService().login(payload)
```

### Central settings with Pydantic
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

### Service layer pattern
```python
# app/services/auth_service.py
from app.db.session import async_session

class AuthService:
    async def login(self, payload: LoginSchema):
        async with async_session() as session:
            return {"access_token": "token"}
```

## AI Prompting Examples

- "Create a Python enterprise playbook for FastAPI with Pydantic and SQLAlchemy."
- "Explain Python state management patterns for request-scoped dependencies."
- "Generate production deployment advice for a FastAPI service."
