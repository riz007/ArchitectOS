# ArchitectOS Repository Architecture

ArchitectOS is a reference and execution framework, not a single application. This repository is organized around the latest enterprise architecture model for agent-driven software delivery:

- **governance** and intent in the repo root
- **standards** as the contract for every implementation
- **playbooks** as framework-specific guidance
- **scaffolds** as reusable starter artifacts
- **prompts** as agent workflows and instructions
- **rules** as automated validation
- **examples** as concrete production-facing reference systems
- **tools** as the execution layer for generation, validation, and discovery

## Repository Architecture

This document describes how the repo is composed and where each architectural concern lives.

### 1. Governance layer

- `README.md`
- `AGENTS.md`
- `ARCHITECTURE.md`
- `ENGINEERING_PRINCIPLES.md`

These files define the project vision, repository intent, engineering principles, and the current architecture strategy. Keep them concise, concrete, and aligned with the latest design decisions.

### 2. Standards layer

- `standards/`
  - `coding/`
  - `architecture/`
  - `naming/`
  - `security/`
  - `performance/`
  - `accessibility/`
  - `git/`
  - `reviews/`

This layer captures the stable architectural contract. Implementations consume these standards; agents use them to make decisions; reviewers use them as acceptance criteria.

### 3. Playbook layer

- `playbooks/`
  - `vue/`
  - `react/`
  - `angular/`
  - `nodejs/`
  - `nestjs/`
  - `python/`
  - `fastapi/`
  - `java/`

Each playbook contains a focused set of guides for architecture, state management, API layer design, performance, and testing. These guides are not boilerplate; they are pattern-based prescriptions that AI agents and engineers can follow when implementing enterprise systems.

### 4. Scaffold layer

- `scaffolds/`
  - `vue-enterprise/`
  - `react-enterprise/`
  - `nestjs-clean-arch/`
  - `fastapi-ddd/`
  - `microservice-template/`

Scaffolds are opinionated starter implementations that instantiate the standards and playbook recommendations in working form. Their purpose is to accelerate project creation and preserve architecture consistency.

### 5. Prompt layer

- `prompts/`
  - `claude/`
  - `copilot/`
  - `cursor/`
  - `generic/`

Prompt collections encode the agent-side workflow for repository interaction. They are the integration surface between the repository architecture and the actual AI assistants used to generate, validate, and evolve applications.

### 6. Rule layer

- `rules/`
  - `frontend/`
  - `backend/`
  - `api/`
  - `database/`
  - `security/`

Validation rules operationalize the standards and make the architecture enforceable. The repository should treat these rules as first-class artifacts that gate commits and CI.

### 7. Example layer

- `examples/`
  - `fullstack-saas/`
  - `event-driven-system/`
  - `auth-system/`
  - `enterprise-dashboard/`

Examples are the source of truth for how standards and playbooks are applied in real systems. They should remain deployable, readable, and demonstrative of platform patterns.

### 8. Tooling layer

- `tools/`
  - `cli/`
  - `generators/`
  - `lint-rules/`
  - `validators/`

This layer contains the code that executes repository workflows, scaffolding, and validation. Tools should depend on the architecture defined in standards and playbooks, not the other way around.

## Architectural Intent

### Intent 1: Separation of concern across artifacts

This repository separates design, guidance, generation, and execution. No single folder should mix these roles:

- `standards/` defines what is required
- `playbooks/` describe how to implement it in each technology
- `scaffolds/` provide working examples
- `rules/` check the outcome
- `prompts/` teach the agent how to use it

### Intent 2: Framework-specific guidance, shared principles

The latest architecture emphasizes shared principles with technology-specific application. Every playbook is expected to reflect the same underlying patterns while remaining practical for its target stack.

### Intent 3: Actionable guidance over abstract boilerplate

ArchitectOS is not a catalog of generic architectural vocabulary. It is a system for creating projects that are consistent, secure, and ready for AI-assisted workflows. This document describes the actual repository architecture and its integration model — not abstract patterns.

## Evolution and change

- `README.md` is the entry point and must reflect the current state of the repo.
- `standards/architecture/README.md` contains the canonical architecture principles for implementations.
- `ARCHITECTURE.md` is the repo-level map and integration guide — update it when folder roles change.

When the architecture changes, update this document first to reflect the new folder roles and decision model.
