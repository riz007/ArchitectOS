---
name: aos-review
description: Reviews code against ArchitectOS standards — architecture layering, type safety, security, testing, performance, API design, and naming. Reports FAIL/WARN/PASS with file references and concrete fixes. Use when user asks to review code, check standards compliance, review a PR, or says "does this follow ArchitectOS".
---

# /aos-review

Select the files to review (or paste code), then run `/aos-review`.

For targeted reviews: `/aos-review architecture` · `/aos-review security` · `/aos-review tests` · `/aos-review naming`

For deeper specialist reviews, chain with:
- `/aos-audit` — full security audit
- `/aos-qa` — test suite quality
- `/aos-frontend` — UI component standards
- `/aos-codereview` — full PR decision with BLOCK/REQUEST/NIT

---

## What gets checked

### Architecture
- [ ] Business logic in services — not in controllers, components, or route handlers
- [ ] Controllers delegate in one line — no if/else, no DB calls, no calculations
- [ ] No direct DB access in controllers or UI components
- [ ] DTOs used for all API inputs/outputs — no raw entity objects exposed
- [ ] Feature-based folder structure — grouped by domain, not technical layer
- [ ] No circular dependencies between modules
- [ ] Domain errors thrown by services, not HTTP exceptions

### API design
- [ ] Routes use nouns for resources, HTTP verbs for actions (`GET /orders`, not `GET /getOrders`)
- [ ] Collections return paginated responses — no unbounded list endpoints
- [ ] Consistent response envelope across all endpoints
- [ ] Breaking changes versioned — new behaviour behind `/v2/`, old `/v1/` still works
- [ ] Error responses include a code, message, and (where safe) details

### Type safety
- [ ] No `any` in TypeScript — use `unknown` or a proper type
- [ ] All function parameters and return types declared
- [ ] Domain IDs use branded types to prevent ID mixup
- [ ] No unsafe type assertions (`as X`) without a comment explaining why

### Security
- [ ] Inputs validated at the boundary (Zod / class-validator / Pydantic)
- [ ] Parameterised queries — no SQL string concatenation
- [ ] No hardcoded secrets, tokens, or API keys
- [ ] Auth guard on every state-changing or sensitive endpoint
- [ ] Sensitive fields stripped before response (password hashes, internal flags)
- [ ] Tokens in `httpOnly` cookies, not `localStorage`
- [ ] Resource ownership verified before read or mutation (IDOR check)

### Naming and readability
- [ ] Names are accurate — `getUser` only gets, does not also mutate
- [ ] No unexplained abbreviations: `usr`, `mgr`, `tmp`, `d`, `ts` — spell them out
- [ ] Booleans are positive and assertive: `isActive`, `hasPermission` — not `notDisabled`
- [ ] No dead code — unreachable branches, unused exports, unused imports
- [ ] No `console.log` / `print` debug statements
- [ ] No commented-out code blocks — delete or put behind a feature flag

### Testing
- [ ] Unit tests for all service / use-case logic
- [ ] Test names describe behaviour: `should throw when email is already registered`
- [ ] Mocks only at system boundaries (HTTP, DB, external APIs)
- [ ] Error paths and edge cases covered — not just the happy path
- [ ] New behaviour has new tests — no uncovered code paths

### Performance
- [ ] No N+1 query patterns
- [ ] No unbounded queries — pagination on all collections
- [ ] No synchronous I/O in async request handlers
- [ ] Expensive computations memoised or cached where appropriate

### Dependencies
- [ ] New packages are actively maintained (last release < 12 months)
- [ ] No packages that duplicate something already in the project
- [ ] No `npm audit` high/critical vulnerabilities introduced

---

## Output format

```
[FAIL] Architecture — business logic in controller
File: src/users/users.controller.ts:34
Fix: move validation and duplicate check to UserService.create()
Standard: playbooks/nestjs/architecture.md — Thin Controllers

[FAIL] API design — GET /getUsers is RPC-style, not RESTful
File: src/users/users.controller.ts:12
Fix: rename to GET /users

[WARN] Testing — no test for the duplicate email case
File: src/users/user.service.spec.ts
Fix: add it('should throw ConflictError when email is already registered')

[WARN] Naming — variable 'd' on line 47 holds a discount percentage
File: src/orders/order.service.ts:47
Fix: rename d → discountPercent

Summary: 2 FAIL · 2 WARN · 11 PASS
```

---

## Full standards reference

See [REFERENCE.md](REFERENCE.md) for annotated code examples for each rule.
