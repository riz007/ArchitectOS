# FastAPI DDD Scaffold

Production-ready FastAPI + Python application following ArchitectOS standards with domain-driven design principles.

## Stack

| Concern | Technology |
|---|---|
| Framework | FastAPI |
| Language | Python 3.12+ |
| Validation | Pydantic v2 |
| ORM | SQLAlchemy 2.0 (async) |
| Database | PostgreSQL |
| Migrations | Alembic |
| Cache | Redis |
| Auth | JWT (python-jose) |
| Testing | pytest + pytest-asyncio |
| Type checking | mypy (strict) |
| Linting | Ruff |

## Quick Start

```bash
# From the ArchitectOS repo
./tools/cli/scaffold.sh fastapi-ddd my-api

# Or manually
cd scaffolds/fastapi-ddd
cp .env.example .env
docker-compose up -d
pip install -r requirements.txt
alembic upgrade head
uvicorn src.main:app --reload
```

## Project Structure

```
src/
├── domain/                    # Business rules — no framework dependencies
│   ├── entities/              # Domain entities (pure Python classes)
│   ├── repositories/          # Repository interfaces (Abstract Base Classes)
│   ├── services/              # Domain service interfaces
│   └── errors.py              # Domain error types
│
├── application/               # Use cases — orchestrates domain
│   ├── use_cases/             # One class per use case
│   └── services/              # Application-level services
│
├── infrastructure/            # Framework and external adapters
│   ├── api/
│   │   ├── routers/           # FastAPI routers — one per domain
│   │   ├── schemas/           # Pydantic request/response models
│   │   ├── dependencies.py    # FastAPI dependency injection
│   │   └── middleware.py      # Auth, logging, error middleware
│   ├── persistence/
│   │   ├── models/            # SQLAlchemy ORM models
│   │   ├── repositories/      # SQLAlchemy repository implementations
│   │   └── database.py        # Async engine, session factory
│   ├── cache/                 # Redis integration
│   └── external/              # External service adapters
│
├── config/
│   └── settings.py            # Pydantic Settings for env config
│
└── main.py                    # FastAPI app creation, middleware, startup

tests/
├── unit/                      # Domain and use case unit tests
├── integration/               # Repository and service integration tests
└── e2e/                       # HTTP E2E tests with pytest + httpx
```

## Architecture Patterns

### Thin router

```python
# infrastructure/api/routers/users.py
from fastapi import APIRouter, Depends, status
from ..dependencies import get_create_user_use_case, require_auth
from ..schemas.user import CreateUserRequest, UserResponse
from ...application.use_cases.create_user import CreateUserUseCase

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    body: CreateUserRequest,
    use_case: CreateUserUseCase = Depends(get_create_user_use_case),
    _: dict = Depends(require_auth),
) -> UserResponse:
    return await use_case.execute(body)
```

### Use case

```python
# application/use_cases/create_user.py
from ...domain.repositories.user import UserRepository
from ...domain.errors import ConflictError
from ...domain.entities.user import User
from ..services.password import PasswordService

class CreateUserUseCase:
    def __init__(
        self,
        user_repository: UserRepository,
        password_service: PasswordService,
    ) -> None:
        self._users = user_repository
        self._passwords = password_service

    async def execute(self, dto: CreateUserRequest) -> UserResponse:
        existing = await self._users.find_by_email(dto.email)
        if existing:
            raise ConflictError("Email already registered")

        password_hash = await self._passwords.hash(dto.password)
        user = User.create(
            email=dto.email,
            first_name=dto.first_name,
            last_name=dto.last_name,
            password_hash=password_hash,
        )

        await self._users.save(user)
        return UserResponse.from_domain(user)
```

### Domain entity

```python
# domain/entities/user.py
from dataclasses import dataclass, field
from datetime import datetime, UTC
import uuid

@dataclass
class User:
    id: str
    email: str
    first_name: str
    last_name: str
    password_hash: str
    is_active: bool = True
    created_at: datetime = field(default_factory=lambda: datetime.now(UTC))
    updated_at: datetime = field(default_factory=lambda: datetime.now(UTC))

    @classmethod
    def create(cls, **kwargs: object) -> "User":
        return cls(id=str(uuid.uuid4()), **kwargs)

    @property
    def full_name(self) -> str:
        return f"{self.first_name} {self.last_name}"

    def deactivate(self) -> None:
        self.is_active = False
        self.updated_at = datetime.now(UTC)
```

### Repository interface (domain)

```python
# domain/repositories/user.py
from abc import ABC, abstractmethod
from ..entities.user import User

class UserRepository(ABC):
    @abstractmethod
    async def find_by_id(self, user_id: str) -> User | None: ...

    @abstractmethod
    async def find_by_email(self, email: str) -> User | None: ...

    @abstractmethod
    async def save(self, user: User) -> None: ...

    @abstractmethod
    async def delete(self, user_id: str) -> None: ...
```

### Pydantic schema

```python
# infrastructure/api/schemas/user.py
from pydantic import BaseModel, EmailStr, field_validator
from ...domain.entities.user import User

class CreateUserRequest(BaseModel):
    email: EmailStr
    password: str
    first_name: str
    last_name: str

    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain an uppercase letter")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain a digit")
        return v

class UserResponse(BaseModel):
    id: str
    email: str
    first_name: str
    last_name: str
    is_active: bool

    @classmethod
    def from_domain(cls, user: User) -> "UserResponse":
        return cls(
            id=user.id,
            email=user.email,
            first_name=user.first_name,
            last_name=user.last_name,
            is_active=user.is_active,
        )
```

### Settings

```python
# config/settings.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "{{PROJECT_NAME}}"
    debug: bool = False
    database_url: str
    redis_url: str
    jwt_secret: str
    jwt_expiry_seconds: int = 900       # 15 minutes
    jwt_refresh_expiry_seconds: int = 604800  # 7 days

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}

settings = Settings()
```

## Environment Variables

```env
# .env.example
DATABASE_URL=postgresql+asyncpg://postgres:password@localhost:5432/{{PROJECT_NAME}}
REDIS_URL=redis://localhost:6379
JWT_SECRET=change-me-to-a-secure-random-string-at-least-32-chars
DEBUG=false
```

## Commands

```bash
uvicorn src.main:app --reload      # Development server
uvicorn src.main:app --workers 4   # Production (or use gunicorn)
pytest                             # Run all tests
pytest tests/unit/                 # Unit tests only
pytest tests/e2e/                  # E2E tests only
pytest --cov=src                   # Coverage report
mypy src                           # Type checking
ruff check src                     # Linting
ruff format src                    # Formatting
alembic revision --autogenerate -m "description"
alembic upgrade head
alembic downgrade -1
```

## Playbook

See [FastAPI Playbook](../../playbooks/fastapi/) for full architectural guidance.
