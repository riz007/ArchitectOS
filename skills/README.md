# ArchitectOS Skills

Fourteen Claude Code slash commands for engineering work that follows ArchitectOS standards.

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

---

### `/aos-review`

**Review code against ArchitectOS standards.**

```
/aos-review
```

Checks architecture, type safety, security, testing, and performance. Reports `[FAIL]`, `[WARN]`, or `[PASS]` with file references and concrete fixes.

---

### `/aos-feature`

**Generate a complete vertical feature slice in one pass.**

```
/aos-feature <name> [stack]
```

Generates: DTO, domain entity, repository interface, service with tests, thin controller (backend) + API module, composable/hook, list and form components (frontend).

---

### `/aos-audit`

**Security audit before shipping.**

```
/aos-audit
/aos-audit auth
/aos-audit uploads
/aos-audit payments
```

Checks auth, input validation, IDOR, secrets, SQL injection, security headers, and file upload safety. Reports `[HIGH]`, `[MEDIUM]`, `[LOW]` with risk and fix.

---

### `/aos-frontend`

**Review frontend component code.**

```
/aos-frontend
/aos-frontend components
/aos-frontend forms
/aos-frontend styles
```

Checks component design, CSS architecture, responsive design, accessibility (WCAG 2.1), performance, and state management.

---

### `/aos-ux`

**Review UI implementation for usability.**

```
/aos-ux
/aos-ux forms
/aos-ux navigation
/aos-ux onboarding
```

Checks loading/error/empty states, form UX, visual hierarchy, navigation patterns, microcopy quality, and mobile responsiveness.

---

### `/aos-qa`

**Audit test suite quality and coverage.**

```
/aos-qa
/aos-qa unit
/aos-qa integration
/aos-qa e2e
```

Checks test pyramid balance, naming conventions, isolation, mocking strategy, coverage completeness, and test data quality.

---

### `/aos-vuetify`

**Review Vuetify 3 + Vue 3 component code.**

```
/aos-vuetify
/aos-vuetify forms
/aos-vuetify tables
/aos-vuetify theme
```

Checks component usage, form validation patterns, responsive grid, data tables, theme configuration, dialog patterns, and tree-shaking setup.

---

### `/aos-pragmatic`

**Review code against Pragmatic Programmer principles.**

```
/aos-pragmatic
```

Checks DRY, orthogonality, reversibility, no programming by coincidence, broken windows, boy scout rule, and good-enough software. Cites chapter and principle in every finding.

---

### `/aos-codereview`

**Full pull request review.**

```
/aos-codereview
/aos-codereview security
/aos-codereview breaking
/aos-codereview tests
```

Reviews correctness, readability, breaking changes, security, performance, and testing. Produces `[BLOCK]`, `[REQUEST]`, and `nit:` comments with a final APPROVE or REQUEST CHANGES decision.

---

### `/aos-refactor`

**Safely refactor code using named patterns.**

```
/aos-refactor
/aos-refactor complexity
/aos-refactor naming
/aos-refactor duplication
```

Checks the safety net first, then identifies opportunities: extract function, rename, guard clauses, decompose conditional, replace magic number, introduce parameter object, strangle fig, parallel change.

---

### `/aos-ci`

**Set up automated Claude-powered PR review in GitHub Actions.**

```
/aos-ci setup
```

Adds a GitHub Action workflow that runs on every PR, diffs changed source files, sends the diff to Claude, and posts `[FAIL]` / `[WARN]` findings as a PR comment. Fails the CI check if there are blocking findings.

Requires: `ANTHROPIC_API_KEY` secret in your repository settings.

---

### `/aos-generate`

**Multi-agent full-stack feature generator.**

```
/aos-generate <feature-name> [backend+frontend]
```

Examples:
```
/aos-generate user-management nestjs+vue
/aos-generate order-processing fastapi+react
```

Coordinates four agents in sequence:
1. **Architecture Agent** — designs the domain model, API contract, and business rules
2. **Backend Agent** — generates DTOs, entity, repository interface, service + tests, controller
3. **Frontend Agent** — generates API client, composable/hook, list and form components
4. **Review Agent** — runs `/aos-review` on all generated files and fixes any findings

Every file is complete — no placeholders.

---

## Suggested workflow

```
# 1. Configure the project once
/aos-setup

# 2. Scaffold a new service or app
/aos-scaffold nestjs payment-service

# 3. Generate a feature end-to-end
/aos-feature subscription nestjs

# 4. Review what was generated
/aos-review

# 5. Security check before opening a PR
/aos-audit payments

# 6. Full PR review before merge
/aos-codereview

# 7. UX and frontend quality before shipping
/aos-frontend
/aos-ux

# 8. Clean up existing code
/aos-refactor complexity
/aos-pragmatic

# 9. Generate a complete fullstack feature with multi-agent orchestration
/aos-generate subscription nestjs+vue

# 10. Automate reviews on every PR (run once to set up)
/aos-ci setup
```
