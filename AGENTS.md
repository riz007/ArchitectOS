# AI Agent Operating Instructions

This repository is designed to be agent-aware, but humans retain responsibility for design, validation, and release decisions. Agents should operate as guided contributors, not autonomous maintainers.

## Required behavior

All AI agents operating in this repository must:

- follow ArchitectOS standards (`standards/`, `rules/`, `playbooks/`)
- prioritize maintainability, readability, and consistency
- avoid security anti-patterns and insecure defaults
- generate strongly-typed code when the target stack supports it
- reuse existing abstractions before adding new ones
- avoid unnecessary dependencies and avoid scope creep
- keep changes focused, minimal, and aligned with the feature goal
- document non-trivial decisions in code comments or repo docs

## What agents should do first

1. Read `README.md` to understand the project scope and intent.
2. Review `ARCHITECTURE.md` and `ENGINEERING_PRINCIPLES.md` for repository-level expectations.
3. Inspect the relevant `playbooks/` folder for stack-specific guidance.
4. Consult `standards/` and `rules/` before writing or changing code.
5. Confirm the target output format and directory structure before generating files.

## File and change conventions

- Prefer updating existing files over creating new duplicates.
- When adding code, follow the existing naming, folder, and module conventions.
- Use feature-based organization for new functionality.
- Keep each change scoped to a single feature, module, or fix.
- Do not add new top-level folders without explicit approval.

## Validation and review

- Generate tests for all new behavior: unit, integration, or API-level as appropriate.
- Run repository validation rules when available.
- If a rule or standard is unclear, ask for clarification instead of guessing.
- Avoid producing code that relies on unvetted experimental syntax or libraries.

## Prompting and interaction

- When the prompt asks for architecture, answer with the repo's current folder and standard structure.
- If asked for implementation, prefer code that is immediately usable, not abstract pseudo-code.
- For refactoring tasks, preserve behavior while improving clarity.
- For documentation tasks, keep content concise, actionable, and aligned with the repository's terminology.

## Deliverables

- Work should be commit-ready and repository-aligned.
- Avoid drafts or partial prototypes unless explicitly requested.
- Leave no placeholder comments such as `TODO` unless the task is explicitly to create a work-in-progress.

## When to escalate

- If a requirement conflicts with existing repo standards.
- If a proposed dependency is not already in the target stack or repo.
- If the task could change the architecture or cross-cut major layers.
- If the needed information is missing from `README.md`, `ARCHITECTURE.md`, or playbooks.
