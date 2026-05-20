---
name: aos-pragmatic
description: Reviews code against Pragmatic Programmer principles — DRY, orthogonality, reversibility, fail fast, no programming by coincidence, broken windows, boy scout rule, good-enough software, and the power of plain text. Reports FAIL/WARN/PASS citing the specific principle violated. Use when user asks for a pragmatic review, engineering quality check, or says "is this code good engineering".
---

# /aos-pragmatic

Select files to review, then run `/aos-pragmatic`.

Based on *The Pragmatic Programmer* by David Thomas and Andrew Hunt (20th Anniversary Edition).

---

## What gets checked

### DRY — Don't Repeat Yourself
- [ ] No copy-pasted logic in two or more places
- [ ] Magic numbers used more than once are named constants
- [ ] Validation rules exist in one place — not duplicated across DTO, service, and DB constraint
- [ ] Comments do not restate what the code says — they explain *why*, not *what*

### Orthogonality
- [ ] Modules have a single reason to change — not coupled to unrelated concerns
- [ ] A database schema change does not ripple into UI components
- [ ] A change to a third-party provider does not require touching business logic
- [ ] Functions and classes do one thing — no God objects or Swiss-army functions

### Reversibility
- [ ] Third-party dependencies are behind abstractions — no vendor lock-in inside business code
- [ ] External API calls go through a wrapper or adapter
- [ ] All configuration externalised — no hardcoded URLs, credentials, or environment-specific values
- [ ] Data format decisions isolated behind serialisers — callers do not know JSON vs Protobuf

### Fail Fast
- [ ] Invalid state is detected and rejected at the earliest possible point
- [ ] Required configuration validated at startup — app crashes immediately if a secret is missing
- [ ] Assertions used to catch impossible states during development
- [ ] Functions validate their preconditions before doing work — don't fail silently halfway through

### No programming by coincidence
- [ ] Code does not rely on behaviour that is accidental or undocumented
- [ ] Assumptions about external systems are explicit and documented
- [ ] No commented-out code in committed source — it is either live or deleted
- [ ] No `console.log` / `print` debug statements in committed code

### Broken windows
- [ ] No known bugs left without a TODO referencing a tracked issue
- [ ] No obviously wrong or unsafe code marked "we'll fix it later" without an issue link
- [ ] No dead code — unreachable branches, unused exports, unused imports
- [ ] Dependencies are not multiple major versions behind without a documented reason

### Boy Scout Rule
- [ ] Files touched in this change are at least as clean as before
- [ ] A confusing name improved opportunistically while working in the file
- [ ] An already-resolved TODO removed

### Good enough software
- [ ] No over-engineering for hypothetical future requirements
- [ ] Abstractions have at least two real use cases — no premature generalisation
- [ ] Configuration options not added until a concrete need exists
- [ ] No half-finished implementations in committed code — everything is either done or behind a flag

### The power of plain text
- [ ] Configuration stored in a human-readable format (JSON, YAML, TOML) — not binary blobs
- [ ] Logs are structured and human-readable — not binary serialised
- [ ] Protocols and interchange formats prefer text (JSON, CSV, Markdown) over proprietary binary unless performance requires it

### Tracer bullets
- [ ] New features implemented end-to-end (thin slice) before all edge cases are filled in
- [ ] Nothing half-implemented in committed code — every feature either fully works or is behind a flag
- [ ] Architecture validated with a running spike before committing to full implementation

### Estimating
- [ ] Estimates communicated with an appropriate unit of precision (hours for small tasks, weeks for large)
- [ ] Estimates include a range, not a single point — "3–5 days" is more honest than "4 days"
- [ ] Estimates updated when scope or understanding changes — not silently missed

---

## Output format

```
[FAIL] DRY — email validation regex duplicated in RegisterDto and UpdateProfileDto
File: src/auth/dto/register.dto.ts:8, src/users/dto/update-profile.dto.ts:12
Fix: extract isValidEmail(v: string): boolean to src/shared/validators/email.ts
Principle: DRY — "Every piece of knowledge must have a single, unambiguous, authoritative representation" — TPP §9

[FAIL] Fail Fast — missing startup validation for STRIPE_SECRET_KEY
File: src/main.ts
Fix:
  const env = z.object({ STRIPE_SECRET_KEY: z.string().startsWith('sk_') }).parse(process.env)
Principle: Fail Fast — "Crash early. Dead programs tell no lies." — TPP §23

[WARN] Orthogonality — PaymentService imports StripeClient directly
File: src/payments/payment.service.ts:3
Fix: introduce PaymentGateway interface; create StripeAdapter implementing it
Principle: Orthogonality — "Eliminate effects between unrelated things" — TPP §8

Summary: 2 FAIL · 1 WARN · 14 PASS
```

---

## Full reference

See [REFERENCE.md](REFERENCE.md) for principle explanations and before/after code examples.
