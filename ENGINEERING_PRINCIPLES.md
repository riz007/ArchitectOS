# ArchitectOS Engineering Principles

ArchitectOS is built around practical enterprise engineering principles that guide both human teams and AI-assisted workflows. These principles are intentionally narrow, actionable, and aligned with the repository's current architecture model.

## 1. AI is an assistant, not the architect

- Treat AI as a productivity tool, not the final decision maker.
- Humans own architecture decisions, validation, and risk management.
- Use prompts and playbooks to shape outputs, then verify them against standards and tests.

## 2. Design around clear contracts

- Define expectations in `standards/`, `playbooks/`, and `rules/`.
- Prefer explicit interfaces, DTOs, and service boundaries over implicit behavior.
- Keep contracts stable so implementations can evolve without breaking other layers.

## 3. Organize by feature and domain intent

- Structure applications around domain features rather than technical layers.
- Each feature should own its UI, state, API, and tests when possible.
- Avoid large shared folders that become catch-alls for unrelated concerns.

## 4. Separate responsibility and dependency direction

- Business logic belongs in services, not in controllers, pages, or route handlers.
- Presentation layers should consume feature APIs from shared services or stores.
- Higher-level modules depend on abstractions, not concrete implementations.

## 5. Keep technology boundaries thin

- Use `playbooks/` to capture stack-specific implementation patterns.
- Keep the core architecture principles independent of any particular framework.
- Avoid mixing framework-specific code with portable business logic.

## 6. Ship incrementally with safety

- Deliver vertical slices: a complete feature from UI through persistence.
- Validate each slice with unit, integration, and smoke tests.
- Use CI/CD and automated validation pipelines before merging changes.

## 7. Secure and observable by default

- Apply security controls early: auth, validation, secrets handling, and access checks.
- Log and monitor important business events, errors, and health signals.
- Make observability part of the architecture, not an afterthought.

## 8. Prefer readable patterns over cleverness

- Use straightforward code that teammates can understand quickly.
- Favor small, composable modules and clear naming.
- If a pattern is hard to explain, it is probably too complex.

## 9. Document decisions and keep them current

- Capture architecture decisions in `SPEC.md`, `ARCHITECTURE.md`, and repo docs.
- Update principles and playbooks when the architecture changes.
- Treat documentation as part of the implementation, not optional collateral.

## 10. Measure and improve

- Use standards and rules to identify gaps early.
- Review implementation quality against the repository's playbooks and templates.
- Iterate the architecture based on real usage, not just theoretical models.
