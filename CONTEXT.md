# ArchitectOS — Shared Context for Agents

Read this once at the start of a session. It is the shared vocabulary so you don't have to
re-derive how this project thinks. Keep it loaded; the rules here are assumed by every
ArchitectOS skill.

## What ArchitectOS is

An opinionated reference system for production software across stacks (Vue, React, Angular,
NestJS, FastAPI, Java, plus Docker/K8s/Terraform). It is **conventions + skills**, not a
framework or an autonomous agent. Humans own architecture and release decisions; agents are
guided contributors.

## The one diagram that explains everything

```
HTTP / UI  →  Controller / Component  →  Service (use case)  →  Repository  →  DB
                     (thin)              (all business logic)   (interface)
```

If you remember nothing else: **logic lives in services, boundaries are validated, entities
never leave the building.**

## Glossary

- **Service / use case** — where business logic lives. Throws *domain errors*, not HTTP errors.
- **Controller / route handler** — thin. One line of delegation per route. No logic.
- **Repository** — a domain-layer *interface*; the implementation lives in infrastructure.
- **DTO** — validated input shape and safe output shape. API surfaces speak DTOs, never entities.
- **Domain error** — `ConflictError`, `NotFoundError`, etc. The HTTP layer maps these to status codes.
- **IDOR** — Insecure Direct Object Reference: reading/mutating a resource by `id` without
  checking the caller owns it. The most common security bug we guard against.
- **Feature-based structure** — folders grouped by domain (`modules/order/...`), not by layer.
- **Playbook** — stack-specific implementation guide under `playbooks/<stack>/`.
- **Standard** — a cross-stack contract under `standards/` (coding, security, performance, git…).
- **Scaffold** — a runnable project template under `scaffolds/`.

## Two kinds of skill

- **User-invoked** (`/aos-*`) — orchestrators a human triggers: `aos-setup`, `aos-scaffold`,
  `aos-feature`, `aos-review`, `aos-audit`, `aos-codereview`, `aos-generate`, `aos-refactor`,
  `aos-frontend`, `aos-ux`, `aos-qa`, `aos-vuetify`, `aos-pragmatic`, `aos-ci`.
- **Model-invoked** — disciplines you apply automatically when the work matches, without being
  asked: `aos-implementing-features`, `aos-debugging`, `aos-tdd`, `aos-hardening`.

A user-invoked skill may call a model-invoked one. Model-invoked skills don't call user-invoked ones.

## Non-negotiables (apply on every change)

- No `any` (TS); type hints on every Python def.
- Validate inputs at the boundary; return DTOs, never entities.
- Auth guard + ownership check on sensitive routes.
- Parameterised queries only.
- Tests cover the error path, not just the happy path.
- Keep changes scoped; reuse existing abstractions before adding new ones.

See [AGENTS.md](AGENTS.md) for operating rules and escalation, and `standards/` for the full contracts.
