---
name: aos-qa
description: Reviews test suite quality and coverage — test pyramid balance, naming conventions, isolation, mocking strategy, edge-case completeness, snapshot hygiene, and contract testing. Reports FAIL/WARN/PASS. Use when user asks to review tests, improve test quality, write a test plan, or says "are my tests good enough".
---

# /aos-qa

Select test files or name the feature to audit, then run `/aos-qa`.

For targeted reviews: `/aos-qa unit` · `/aos-qa integration` · `/aos-qa e2e` · `/aos-qa coverage` · `/aos-qa contracts`

---

## What gets checked

### Test pyramid
- [ ] Unit tests are the majority (≥ 60% of test count) — fast and isolated
- [ ] Integration tests verify service + real database interaction
- [ ] E2E tests cover critical user journeys only — not implementation details
- [ ] No inverted pyramid (few units, many e2e — slow, brittle, expensive)

### Test naming and structure
- [ ] Names describe behaviour: `should throw when email is taken` — not `test 1` or `works correctly`
- [ ] Arrange–Act–Assert structure with blank lines separating each phase
- [ ] One logical assertion per test (multiple `expect` calls allowed when testing one outcome)
- [ ] Test file lives alongside the module it tests (`user.service.spec.ts` next to `user.service.ts`)

### Test isolation
- [ ] Tests pass in any order — no shared mutable state between tests
- [ ] Each test sets up and tears down its own data
- [ ] `beforeEach` used for fixture setup — not shared mutation across tests
- [ ] No `setTimeout` or `sleep` — use fake timers (`vi.useFakeTimers`) or `waitFor`

### Mocking strategy
- [ ] Mocks only at system boundaries: HTTP clients, database, external APIs, file system
- [ ] No mocking of internal module methods — that tests implementation, not behaviour
- [ ] Mock implementations match the real interface (typed mocks with `satisfies`)
- [ ] Spy assertions check arguments or return values — not just that a function was called

### Coverage and completeness
- [ ] Happy path covered
- [ ] Validation error paths covered (missing fields, wrong types, out-of-range values)
- [ ] Authorization error paths covered (unauthenticated, forbidden, wrong owner)
- [ ] Not-found cases covered
- [ ] Concurrency edge cases covered where relevant (duplicate submission, race conditions)
- [ ] Service / business logic layer at ≥ 80% line coverage

### Test data
- [ ] No hardcoded IDs — use factories or `crypto.randomUUID()`
- [ ] Factories produce valid, complete objects with overridable defaults
- [ ] Database tests rolled back or truncated after each test — no leaking data

### Snapshot tests
- [ ] Snapshot tests used sparingly — only for stable, presentational output
- [ ] Snapshots reviewed before committing (not auto-approved)
- [ ] Failing snapshots investigated — not blindly updated with `--updateSnapshot`
- [ ] Large inline snapshots extracted to `.snap` files

### Contract tests (API consumers and producers)
- [ ] If this service is consumed by other services: consumer-driven contract tests exist (Pact or similar)
- [ ] If the API schema changed: contract tests run before deploying to catch consumer breakage
- [ ] OpenAPI / GraphQL schema kept in sync with implementation

### Performance baselines
- [ ] Critical endpoints have response-time assertions or load test baselines
- [ ] Database-heavy tests run against realistic data volumes — not 3 rows

---

## Output format

```
[FAIL] Isolation — shared mutable users array modified across tests
File: src/users/user.service.spec.ts:15
Fix: move users array into beforeEach so each test gets a fresh copy

[FAIL] Snapshot — large inline snapshot auto-approved without review
File: src/components/__tests__/ProductCard.spec.ts:44
Fix: review the snapshot diff; if the change is intentional, commit the .snap file after inspection

[WARN] Coverage — no test for duplicate email case in UserService.create()
File: src/users/user.service.ts:34
Fix: add: it('should throw ConflictError when email is already registered')

[WARN] Mocking — UserService.sendWelcomeEmail() mocked internally
File: src/users/user.service.spec.ts:22
Fix: inject EmailService as a dependency and mock at the boundary instead

Summary: 2 FAIL · 2 WARN · 13 PASS
```

---

## Full reference

See [REFERENCE.md](REFERENCE.md) for the test pyramid diagram, factory patterns, and contract testing setup.
