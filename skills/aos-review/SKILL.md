---
name: aos-review
description: Reviews code against ArchitectOS standards — architecture layering, type safety, security, testing, and performance. Reports FAIL/WARN/PASS with file references and concrete fixes. Use when user asks to review code, check standards compliance, review a PR, or says "does this follow ArchitectOS".
---

# /aos-review

Select the files to review (or paste code), then run `/aos-review`.

## What gets checked

### Architecture
- [ ] Business logic in services — not in controllers, components, or route handlers
- [ ] Controllers delegate in one line, no logic
- [ ] No direct DB access in controllers or UI components
- [ ] DTOs used for all API inputs/outputs — no raw entity objects exposed
- [ ] Feature-based folder structure — grouped by domain, not technical layer

### Type safety
- [ ] No `any` in TypeScript
- [ ] All function parameters and return types declared
- [ ] Domain IDs use branded types

### Security
- [ ] Inputs validated at the boundary (Zod / class-validator / Pydantic)
- [ ] Parameterized queries — no SQL string concatenation
- [ ] No hardcoded secrets
- [ ] Auth guard on every state-changing endpoint
- [ ] Sensitive fields stripped before response
- [ ] Tokens in `httpOnly` cookies, not `localStorage`

### Testing
- [ ] Unit tests for all service / use-case logic
- [ ] Test names describe behavior (`should throw when...`)
- [ ] Mocks only at system boundaries (HTTP, DB, external APIs)
- [ ] Error paths and edge cases covered

### Performance
- [ ] No N+1 query patterns
- [ ] No unbounded queries — pagination on all collections
- [ ] No blocking I/O in async paths

## Output format

```
[FAIL] Architecture — business logic in controller
File: src/users/users.controller.ts:34
Fix: move validation and duplicate check to UserService.create()
Standard: playbooks/nestjs/architecture.md — Thin Controllers

[WARN] Testing — missing error path test
File: src/users/user.service.spec.ts
Fix: add test for duplicate email case

Summary: 1 FAIL · 1 WARN · 13 PASS
```

## Full standards reference

See [REFERENCE.md](REFERENCE.md) for annotated code examples for each rule.
