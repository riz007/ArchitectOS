---
name: aos-scaffold
description: Creates a new project from an ArchitectOS template — folder structure, config files, and dependencies included. Use when user wants to start a new project, scaffold a service, bootstrap an app, or says "create a new <stack> app/service/api".
---

# /aos-scaffold

```
/aos-scaffold <template> <project-name>
```

## Templates

| Template | Stack | Use for |
|---|---|---|
| `vue` | Vue 3 + TypeScript + Pinia + Vitest | Frontend SPA |
| `react` | React 18 + TypeScript + React Query + Zustand | Frontend SPA |
| `nestjs` | NestJS + TypeScript + TypeORM + clean architecture | REST API |
| `fastapi` | FastAPI + Pydantic + SQLAlchemy + DDD | Python API |

## Examples

```
/aos-scaffold vue my-dashboard
/aos-scaffold react admin-panel
/aos-scaffold nestjs user-service
/aos-scaffold fastapi analytics-api
```

## What gets created

```
my-project/
├── src/              — source code with feature-based structure
├── tests/            — unit and integration tests
├── .env.example      — all required env vars documented
├── Dockerfile        — multi-stage production build
├── docker-compose.yml
├── .eslintrc / ruff.toml
└── README.md         — stack-specific setup instructions
```

## Workflow

1. Parse `<template>` and `<project-name>` — ask if not provided.
2. **If the ArchitectOS repo is checked out** (`tools/cli/scaffold.sh` and `scaffolds/`
   exist), run `./tools/cli/scaffold.sh <template> <project-name>`.
   **Otherwise** (installed as a standalone skill) generate the structure yourself: create
   the feature-based folders below, complete config files (`package.json`/`requirements.txt`,
   `.env.example`, `Dockerfile`, lint config, `README.md`), and apply the
   [aos-implementing-features](../aos-implementing-features/SKILL.md) layering. No
   placeholders — every file must run.
3. List every file created.
4. Show next steps: `cp .env.example .env.local`, install command, dev server command.

## Rules

- Do not overwrite an existing directory. Check first.
- If the template name is unrecognized, list the four available options.
- Every generated file must be complete — no `// TODO` placeholders.
