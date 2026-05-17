# ArchitectOS Tools

CLI tools and utilities for scaffolding, validating, and working with ArchitectOS projects.

## CLI Tools

### `scaffold.sh` — Project generator

Generates a new project from an ArchitectOS scaffold template.

```bash
./tools/cli/scaffold.sh <template> <project-name> [destination]
```

**Available templates:**

| Template | Stack | Use case |
|---|---|---|
| `vue-enterprise` | Vue 3 + TypeScript + Pinia + Vitest | Frontend SPA |
| `react-enterprise` | React 18 + TypeScript + React Query + Zustand | Frontend SPA |
| `nestjs-clean-arch` | NestJS + TypeScript + TypeORM | REST API / microservice |
| `fastapi-ddd` | FastAPI + Pydantic + SQLAlchemy | Python API with DDD |
| `microservice-template` | NestJS + messaging | Event-driven microservice |

**Examples:**

```bash
# Create a Vue enterprise frontend
./tools/cli/scaffold.sh vue-enterprise my-frontend

# Create a NestJS API in a specific directory
./tools/cli/scaffold.sh nestjs-clean-arch user-service ./services/user-service

# Create a FastAPI project
./tools/cli/scaffold.sh fastapi-ddd analytics-api /workspace/analytics-api
```

**What it does:**

1. Copies the scaffold template to the destination
2. Replaces `{{PROJECT_NAME}}` placeholders with your project name
3. Initializes a git repository with an initial commit
4. Installs dependencies (npm or pip, depending on stack)
5. Prints next steps

---

### `validate.sh` — Standards compliance checker

Validates a project against ArchitectOS standards. Run before PRs or as part of CI.

```bash
./tools/cli/validate.sh [project-path]
```

**Checks performed:**

| Category | Checks |
|---|---|
| Repository | .git, .gitignore, README.md, .env.example |
| Secrets | Hardcoded passwords, API keys, tokens |
| TypeScript | tsconfig.json, strict mode, safety flags |
| Linting | ESLint, Prettier, Husky hooks |
| Testing | Test framework, test file count |
| Docker | Dockerfile, .dockerignore, multi-stage builds |
| CI/CD | GitHub Actions workflows |
| Architecture | Feature-based organization, service layer |

**Exit codes:**

- `0` — Passed (with or without warnings)
- `1` — Failed (blocking issues found)

**CI integration:**

```yaml
# .github/workflows/standards.yml
- name: ArchitectOS Standards Check
  run: ./tools/cli/validate.sh .
```

---

## Adding Tools

Tools in this directory should:

- Be self-contained shell scripts or lightweight Node.js scripts
- Accept `--help` or print usage when called with no arguments
- Exit `0` on success, non-zero on failure
- Print clear, human-readable output
- Depend only on commonly available system tools (bash, git, node, npm)

Place new scripts in `tools/cli/` and document them in this README.
