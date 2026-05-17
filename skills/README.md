# ArchitectOS Skills

Five Claude Code slash commands for engineering work that follows ArchitectOS standards.

## Install

```bash
npx skills add riz007/architect-os
```

Pick which skills you want, then run `/aos-setup` in Claude Code.

---

## Commands

### `/aos-setup`

**Configure ArchitectOS for your project.** Run once.

Detects your stack from existing files, asks which AI tools you use, and writes the right config files automatically.

```
/aos-setup
```

What happens:
1. Reads `package.json`, `pyproject.toml`, etc. to guess your stack
2. Asks you to confirm frontend + backend + AI tools
3. Writes `.cursorrules`, `.windsurfrules`, `.github/copilot-instructions.md`, or `.aider.conf.yml` depending on your answer
4. Prints your playbook links and available commands

---

### `/aos-scaffold`

**Start a new project from a template.**

```
/aos-scaffold <template> <project-name>
```

| Template | Stack |
|---|---|
| `vue` | Vue 3 + TypeScript + Pinia + Vitest |
| `react` | React 18 + TypeScript + React Query + Zustand |
| `nestjs` | NestJS + TypeScript + TypeORM + clean architecture |
| `fastapi` | FastAPI + Pydantic + SQLAlchemy + DDD |

Examples:
```
/aos-scaffold vue my-dashboard
/aos-scaffold nestjs user-service
/aos-scaffold fastapi analytics-api
```

Generates: folder structure, config files, `.env.example`, `Dockerfile`, linting config, and a README with setup instructions.

---

### `/aos-review`

**Review code against ArchitectOS standards.**

Select the files you want reviewed (or paste code), then run the command.

```
/aos-review
```

Checks across five categories and reports `[FAIL]`, `[WARN]`, or `[PASS]` for each:

| Category | What it checks |
|---|---|
| Architecture | Business logic placement, thin controllers, DTOs, feature structure |
| Type safety | No `any`, typed parameters, branded domain IDs |
| Security | Input validation, auth guards, no hardcoded secrets, no IDOR |
| Testing | Behavior-focused tests, mocks at boundaries, error path coverage |
| Performance | N+1 queries, unbounded collections, blocking I/O |

Output includes file + line reference, a concrete fix, and the standard being violated.

---

### `/aos-feature`

**Generate a complete feature in one pass.**

```
/aos-feature <name> [stack]
```

Examples:
```
/aos-feature user nestjs
/aos-feature order fastapi
/aos-feature product react
```

Generates everything for a vertical slice — no placeholders:

- **Backend**: DTO (input + response), domain entity, repository interface, service with tests, thin controller
- **Frontend**: API module, data-fetching hook/composable, list and form components, types, module index

All code follows the relevant playbook (`playbooks/nestjs/`, `playbooks/fastapi/`, etc.).

---

### `/aos-audit`

**Security audit before shipping.**

Select the files to audit, then run the command. For targeted audits:

```
/aos-audit
/aos-audit auth
/aos-audit uploads
/aos-audit payments
```

Checks:
- Input validation (Zod / class-validator / Pydantic)
- JWT lifetime and refresh token rotation
- Authorization and IDOR prevention
- Hardcoded secrets and env var validation
- Security headers (CSP, HSTS, X-Frame-Options)
- File upload safety

Each finding includes severity (`[HIGH]` / `[MEDIUM]` / `[LOW]`), the risk if exploited, and a concrete code fix.

---

## Suggested workflow

```
# 1. Configure the project
/aos-setup

# 2. Start a new service (or skip if adding to an existing project)
/aos-scaffold nestjs payment-service

# 3. Generate a feature
/aos-feature subscription nestjs

# 4. Review what was generated
/aos-review

# 5. Security check before opening a PR
/aos-audit payments
```
