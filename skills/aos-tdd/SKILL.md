---
name: aos-tdd
description: Test-driven workflow for adding or changing behavior — write a failing test first, make it pass, then refactor. Use proactively when implementing new business logic, a service method, a bug fix that needs a regression test, or any change where correctness matters. Also use when the user asks to "add tests", improve coverage, or write tests for existing code.
---

# Test-driven development

This is a model-invoked discipline. When the change is behavioral, drive it with tests.

## The loop: red → green → refactor

1. **Red** — write one failing test that describes the next small increment of behavior.
   Run it; confirm it fails for the right reason.
2. **Green** — write the minimum code to make it pass. Don't gold-plate.
3. **Refactor** — clean up names, duplication, and structure with the test as your net.
   Re-run; stay green.

Repeat in small steps. Each step is one behavior, not one whole feature.

## Test quality rules (ArchitectOS)

- **Name tests by behavior**: `should throw ConflictError when email is already registered`
  — not `test1`, not `testCreate`.
- **Mock only at boundaries** — HTTP, DB, external APIs. Don't mock the unit under test.
- **Cover error paths and edges**, not just the happy path. Every `throw` deserves a test.
- **Keep tests isolated** — no shared mutable state, no order dependence, no real network.
- **Arrange-Act-Assert** structure; one logical assertion per test.
- **Test the contract, not the implementation** — avoid asserting on private internals.

## The test pyramid

Favor many fast unit tests, fewer integration tests, very few end-to-end tests.
If you reach for an e2e test to cover logic a unit test could catch, push it down.

## When fixing a bug

Write the failing regression test *first* (it reproduces the bug), then fix.
See [aos-debugging](../aos-debugging/SKILL.md) for the full diagnosis loop.

## On-demand suite audit

For a full review of an existing test suite's balance, naming, isolation, and coverage,
use `/aos-qa`.
