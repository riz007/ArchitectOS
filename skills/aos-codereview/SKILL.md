---
name: aos-codereview
description: Comprehensive pull request review covering correctness, readability, security, performance, testing, breaking changes, and dependencies. Produces BLOCK/REQUEST/NIT decisions with specific comments and a final APPROVE or REQUEST CHANGES verdict. Use when user asks to review a PR, check code before merging, or says "is this ready to ship".
---

# /aos-codereview

Select the changed files (or paste a diff), then run `/aos-codereview`.

For targeted reviews: `/aos-codereview security` · `/aos-codereview breaking` · `/aos-codereview tests` · `/aos-codereview perf`

For a deeper security audit, follow up with `/aos-audit`.

---

## What gets checked

### Correctness
- [ ] All branches handled — no missing `else`, no unhandled `null` / `undefined`
- [ ] Off-by-one errors in loops, slices, and pagination
- [ ] Async operations properly awaited — no floating promises
- [ ] Errors not silently swallowed in `catch` blocks
- [ ] Boundary conditions: 0, 1, max, empty string, empty array, invalid inputs
- [ ] Concurrency risks: race conditions, duplicate submissions, non-atomic read-modify-write

### Readability
- [ ] Function names are accurate — `getUser` only gets, does not also mutate
- [ ] Functions fit on a screen — if scrolling is needed, split it
- [ ] Comments explain *why*, not *what* — no "increment counter by 1"
- [ ] No dead code, commented-out blocks, or leftover development TODOs
- [ ] No unexplained abbreviations — spell out `usr`, `mgr`, `tmp`, `d`
- [ ] Style consistent with the surrounding codebase

### Breaking changes
- [ ] Public API changes are backward-compatible or have a documented migration path
- [ ] Database schema changes include a migration — columns not dropped without deprecation phase
- [ ] New required environment variables documented in `.env.example`
- [ ] Config format changes handle the previous format gracefully
- [ ] Consumers of shared libraries or modules notified if the interface changes

### Dependencies
- [ ] New packages are actively maintained (last release < 12 months)
- [ ] New packages don't duplicate functionality already in the project
- [ ] Licence of new packages is compatible with the project (no GPL in a proprietary codebase)
- [ ] `npm audit` / `pip audit` shows no new HIGH or CRITICAL vulnerabilities
- [ ] Lock file updated and committed

### Security (quick scan — use `/aos-audit` for a full audit)
- [ ] No SQL string concatenation — parameterised queries only
- [ ] No new secrets in source code
- [ ] User input not passed to `eval`, `exec`, shell commands, or file paths without sanitisation
- [ ] New endpoints have auth guards unless explicitly public
- [ ] Sensitive data not written to logs

### Performance
- [ ] No new N+1 query patterns introduced
- [ ] New collections are paginated — no unbounded list endpoints
- [ ] No synchronous I/O in async request handlers
- [ ] Cache invalidated where relevant when underlying data changes

### Testing
- [ ] New behaviour has new tests — no uncovered code paths
- [ ] Existing tests still pass — the diff does not break them
- [ ] Tests are meaningful — not just asserting a function was called
- [ ] Tests cover the error paths introduced in this change

### Review etiquette
- [ ] Comments are kind, specific, and actionable
- [ ] Blocking issues labelled `[BLOCK]`, non-blocking changes labelled `[REQUEST]`, minor points labelled `nit:`
- [ ] Positive patterns called out — praise reinforces good decisions
- [ ] All comments batched in one review pass — not drip-fed across days

---

## Output format

```
[BLOCK] Correctness — floating promise in payment handler
File: src/payments/payment.controller.ts:52
Issue: processRefund() called without await — errors silently lost, caller returns before work completes
Fix: await this.paymentService.processRefund(id)

[BLOCK] Security — new admin endpoint missing auth guard
File: src/admin/admin.controller.ts:18
Issue: DELETE /admin/users/:id has no @UseGuards — any unauthenticated request can delete users
Fix: add @UseGuards(JwtAuthGuard, AdminGuard)

[REQUEST] Testing — no test for the new >$500 discount edge case
File: src/orders/order.service.ts:89
Fix: add: it('should apply 20% discount when order total exceeds $500')

[REQUEST] Dependencies — lodash added but only _.get() is used
Fix: replace with optional chaining (user?.address?.city) and remove the dependency

nit: variable 'tmp' on line 34 — consider renaming to 'activeUserReport'

DECISION: REQUEST CHANGES — 2 blocks · 1 request · 1 nit
```

---

## Comment severity guide

| Label | Meaning | Must fix before merge? |
|---|---|---|
| `[BLOCK]` | Correctness bug, security issue, or breaking change without migration | Yes |
| `[REQUEST]` | Missing test, unclear code, or improvable design — important but not blocking | Author's call |
| `nit:` | Minor naming, formatting, or style point | No |
| `[praise]` | Pattern worth calling out positively | No action |

---

## Full reference

See [REFERENCE.md](REFERENCE.md) for correctness patterns, breaking-change handling, and comment examples.
