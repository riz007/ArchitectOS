# Changelog

All notable changes to ArchitectOS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added

- **Model-invoked skills** — disciplines Claude applies automatically while coding, no command needed:
  `aos-implementing-features`, `aos-debugging`, `aos-tdd`, `aos-hardening`. Each is self-contained
  so it works even installed standalone.
- **Subagents** (`agents/`) — `aos-architect`, `aos-backend-engineer`, `aos-frontend-engineer`,
  `aos-reviewer`. `/aos-generate` now dispatches these real subagents via the Task tool instead of
  role-playing four agents in one context.
- **Git guardrails** (`hooks/`) — a `PreToolUse` hook that blocks force-push, `git reset --hard`,
  `git clean -f`, `--no-verify`, and direct commits on protected branches, with guidance on what to
  do instead. Override via `AOS_DISABLE_GIT_GUARDRAILS` / `AOS_ALLOW_PROTECTED`.
- `.claude-plugin/plugin.json` — Claude Code plugin manifest for plugin/marketplace distribution
- `CONTEXT.md` — shared domain glossary and layering model loaded by every skill

### Changed

- `/aos-generate` description and workflow updated to dispatch four subagents (Architect, Backend,
  Frontend, Reviewer) rather than three role-played in-context agents
- `/aos-setup` and `/aos-scaffold` now degrade gracefully when installed standalone (no repo
  `prompts/`/`scaffolds/` present) by generating content inline instead of failing
- `skills/README.md` and `README.md` document the user-invoked vs. model-invoked skill split
- Windsurf rules prompt (`prompts/windsurf/rules.md`) for `.windsurfrules` integration
- Aider configuration (`prompts/aider/`) with `aider.conf.yml` and `conventions.md`
- Continue.dev configuration (`prompts/continue/config.md`) with slash commands and context providers
- GitHub community files: issue templates (bug, feature, new stack), PR template, `dependabot.yml`
- `tools/cli/scaffold.sh` — project generator for all scaffold templates
- `tools/cli/validate.sh` — standards compliance checker with 8 check categories
- `react-enterprise` scaffold — React 18 + TypeScript + React Query + Zustand
- `nestjs-clean-arch` scaffold — NestJS + TypeScript + TypeORM + clean architecture
- `fastapi-ddd` scaffold — FastAPI + Pydantic + SQLAlchemy + DDD patterns
- Updated README with complete table of contents, scaffold quick start, and playbook coverage matrix

---

## [0.1.0] — 2025-05-17

### Added

- Core governance documents: `SPEC.md`, `ARCHITECTURE.md`, `ENGINEERING_PRINCIPLES.md`, `AGENTS.md`
- Engineering standards: coding, architecture, naming, security, performance, accessibility, git, reviews
- Architecture playbooks: Vue, React, Angular, Node.js, NestJS, Python, FastAPI, Java
- Infrastructure playbooks: Docker, Kubernetes, GitHub Actions, Terraform
- AI prompt integrations: Claude, Cursor, Copilot, generic system prompt
- Validation rules: frontend (ESLint), backend, API, database, security
- `vue-enterprise` scaffold — Vue 3 + TypeScript + Pinia + Vitest
- `fullstack-saas` example — Vue 3 + NestJS + PostgreSQL + clean architecture
- Contributing guidelines and MIT license

---

## Types of Changes

- `Added` — new features, content, or artifacts
- `Changed` — changes to existing content or behavior
- `Deprecated` — content or features planned for removal
- `Removed` — content or features that have been removed
- `Fixed` — corrections to incorrect, misleading, or broken content
- `Security` — security-related changes or fixes
