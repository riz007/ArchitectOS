# Python Enterprise API Layer

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
