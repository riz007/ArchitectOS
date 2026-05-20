---
name: aos-pragmatic
description: Reviews code against Pragmatic Programmer principles — DRY, orthogonality, reversibility, no programming by coincidence, broken windows, boy scout rule, and good-enough software. Reports FAIL/WARN/PASS citing the specific principle violated. Use when user asks for a pragmatic review, engineering quality check, or says "is this code good engineering".
---

# /aos-pragmatic

Select files to review, then run `/aos-pragmatic`.

Based on *The Pragmatic Programmer* by David Thomas and Andrew Hunt (20th Anniversary Edition).

## What gets checked

### DRY — Don't Repeat Yourself
- [ ] No copy-pasted logic in two or more places
- [ ] Magic numbers used more than once are named constants
- [ ] Validation rules exist in one place — not in the DTO, the service, AND the database constraint separately
- [ ] Comments do not restate what the code says — they explain *why*, not *what*

### Orthogonality
- [ ] Modules have a single reason to change — not coupled to unrelated concerns
- [ ] A database schema change does not ripple into UI components
- [ ] A change to a third-party provider does not require touching business logic
- [ ] Functions and classes do one thing — no God objects or Swiss-army functions

### Reversibility
- [ ] Third-party dependencies are behind abstractions — no vendor lock-in inside business code
- [ ] External API calls go through a wrapper or adapter
- [ ] All configuration is externalised — no hardcoded URLs, credentials, or environment-specific values
- [ ] Data format decisions are isolated behind serialisers

### No programming by coincidence
- [ ] Code does not rely on behaviour that is accidental or undocumented
- [ ] Assumptions about external systems are explicit
- [ ] No commented-out code in committed source — it is either live or deleted
- [ ] No `console.log` / `print` debug statements in committed code

### Broken windows
- [ ] No known bugs left without at least a TODO referencing a tracked issue
- [ ] No obviously wrong or unsafe code marked "we'll fix it later" without an issue link
- [ ] No dead code — unreachable branches, unused exports, unused imports
- [ ] Dependencies are not multiple major versions behind without a documented reason

### Boy Scout Rule
- [ ] Files touched in this change are at least as clean as before
- [ ] A confusing name was improved opportunistically while working in the file
- [ ] An already-resolved TODO was removed

### Good enough software
- [ ] No over-engineering for hypothetical future requirements
- [ ] Abstractions have at least two real use cases — no premature generalisation
- [ ] Configuration options not added until a concrete need exists

### Tracer bullets
- [ ] New features implemented end-to-end (thin slice) before all edge cases are filled in
- [ ] Nothing left half-implemented in committed code — every feature either fully works or is behind a flag

## Output format

```
[FAIL] DRY — email validation regex duplicated in RegisterDto and UpdateProfileDto
File: src/auth/dto/register.dto.ts:8, src/users/dto/update-profile.dto.ts:12
Fix: extract isValidEmail(v: string): boolean to src/shared/validators/email.ts
Principle: DRY — "Every piece of knowledge must have a single, unambiguous, authoritative representation" — TPP §9

[WARN] Orthogonality — PaymentService imports StripeClient directly
File: src/payments/payment.service.ts:3
Fix: introduce PaymentGateway interface; create StripeAdapter implementing it
Principle: Orthogonality — "Eliminate effects between unrelated things" — TPP §8

Summary: 1 FAIL · 1 WARN · 14 PASS
```

## Full reference

See [REFERENCE.md](REFERENCE.md) for principle explanations and before/after code examples.
