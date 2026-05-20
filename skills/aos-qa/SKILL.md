---
name: aos-qa
description: Reviews test suite quality and coverage — test pyramid balance, naming conventions, isolation, mocking strategy, and edge-case completeness. Reports FAIL/WARN/PASS. Use when user asks to review tests, improve test quality, write a test plan, or says "are my tests good enough".
---

# /aos-qa

Select test files or name the feature to audit, then run `/aos-qa`.

For targeted reviews: `/aos-qa unit` · `/aos-qa integration` · `/aos-qa e2e` · `/aos-qa coverage`

## What gets checked

### Test pyramid
- [ ] Unit tests are the majority (≥ 60% of test count) — fast and isolated
- [ ] Integration tests verify service + real database interaction
- [ ] E2E tests cover critical user journeys only — not implementation details
- [ ] No inverted pyramid (few units, many e2e — slow, brittle, expensive)

### Test naming and structure
- [ ] Names describe behaviour: `should throw when email is taken` — not `test 1` or `works correctly`
- [ ] Arrange–Act–Assert structure with blank lines separating each phase
- [ ] One logical assertion per test (multiple `expect` calls are fine when they test one behaviour)
- [ ] Test file lives alongside the module it tests

### Test isolation
- [ ] Tests pass in any order — no shared mutable state between tests
- [ ] Each test sets up and tears down its own data
- [ ] `beforeEach` used for shared fixture setup
- [ ] No `setTimeout` or `sleep` — use fake timers or await real conditions

### Mocking strategy
- [ ] Mocks only at system boundaries: HTTP clients, database, external APIs, file system
- [ ] No mocking of internal module methods — tests behaviour, not implementation
- [ ] Mock implementations match the real interface (typed mocks)
- [ ] Spy assertions check what matters: arguments passed, not call count unless count is the behaviour

### Coverage and completeness
- [ ] Happy path covered
- [ ] Validation error paths covered (missing fields, wrong types, out-of-range values)
- [ ] Authorization error paths covered (unauthenticated, forbidden)
- [ ] Not-found cases covered
- [ ] Race conditions and duplicate-submission edge cases covered where relevant
- [ ] Service/business logic layer at ≥ 80% coverage

### Test data
- [ ] No hardcoded IDs — use factories or randomised values
- [ ] Factories produce valid, complete objects with overridable defaults
- [ ] Test data cleaned up after each test (database rollback or truncation)

### Performance tests
- [ ] Critical paths have baseline response-time assertions
- [ ] Database-heavy paths tested with realistic data volumes, not 3 rows

## Output format

```
[FAIL] Isolation — shared mutable users array modified across tests
File: src/users/user.service.spec.ts:15
Fix: move the users array inside beforeEach so each test gets a fresh copy

[WARN] Coverage — no test for duplicate email case in UserService.create()
File: src/users/user.service.ts:34
Fix: add: it('should throw ConflictError when email is already registered')

Summary: 1 FAIL · 1 WARN · 15 PASS
```

## Full reference

See [REFERENCE.md](REFERENCE.md) for the test pyramid diagram and annotated examples.
