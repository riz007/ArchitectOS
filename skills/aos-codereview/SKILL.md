---
name: aos-codereview
description: Comprehensive pull request review covering correctness, readability, security, performance, testing, and breaking changes. Produces BLOCK/REQUEST/NIT decisions with specific comments. Use when user asks to review a PR, check code before merging, or says "is this ready to ship".
---

# /aos-codereview

Select the changed files (or paste a diff), then run `/aos-codereview`.

For targeted reviews: `/aos-codereview security` · `/aos-codereview breaking` · `/aos-codereview tests` · `/aos-codereview perf`

## What gets checked

### Correctness
- [ ] All branches handled — no missing `else`, no unhandled `null` / `undefined`
- [ ] Off-by-one errors checked in loops, slices, and pagination
- [ ] Async operations properly awaited — no floating promises
- [ ] Errors not silently swallowed in `catch` blocks
- [ ] Boundary conditions tested: 0, 1, max, and invalid inputs

### Readability
- [ ] Function names are accurate — `getUser` only gets, does not also mutate
- [ ] Functions fit on a screen — if scrolling is needed, it should be split
- [ ] Comments explain *why*, not *what* — no "increment counter by 1"
- [ ] No dead code, commented-out blocks, or leftover development TODOs
- [ ] Style is consistent with the surrounding codebase

### Breaking changes
- [ ] Public API changes are backward-compatible or have a documented migration path
- [ ] Database schema changes include a migration — columns not dropped without deprecation phase
- [ ] New environment variables documented in `.env.example`
- [ ] New dependencies are actively maintained and compatible with the project licence
- [ ] Config format changes handle the previous format gracefully

### Security (quick scan)
- [ ] No SQL string concatenation — parameterised queries only
- [ ] No new secrets in source code
- [ ] User input not passed to `eval`, `exec`, shell commands, or file paths without sanitisation
- [ ] New endpoints have auth guards unless explicitly public
- [ ] Sensitive data not written to logs

### Performance
- [ ] No new N+1 query patterns introduced
- [ ] New collections are paginated
- [ ] No synchronous I/O in async request handlers
- [ ] Cache invalidated where relevant when underlying data changes

### Testing
- [ ] New behaviour has new tests — no uncovered code paths
- [ ] Existing tests still pass — the diff does not break them
- [ ] Tests are meaningful — not just asserting that a function was called

### Review etiquette
- [ ] Comments are kind, specific, and actionable
- [ ] Blocking issues clearly labelled `[BLOCK]`, suggestions labelled `nit:`
- [ ] Positive patterns called out — praise is as useful as critique
- [ ] All comments batched in one review pass, not drip-fed across days

## Output format

```
[BLOCK] Correctness — floating promise in payment handler
File: src/payments/payment.controller.ts:52
Issue: processRefund() called without await — errors silently lost and caller returns before completion
Fix: await this.paymentService.processRefund(id)

[REQUEST] Testing — no test for the new >$500 discount edge case
File: src/orders/order.service.ts:89
Fix: add: it('should apply 20% discount when order total exceeds $500')

nit: variable 'tmp' on line 34 — consider renaming to 'activeUserReport'

DECISION: REQUEST CHANGES — 1 block · 1 request · 1 nit
```

## Full reference

See [REFERENCE.md](REFERENCE.md) for examples of correctness patterns, breaking-change handling, and review comment etiquette.
