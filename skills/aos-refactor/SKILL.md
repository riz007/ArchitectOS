---
name: aos-refactor
description: Guides safe code refactoring — identifies what to improve, ensures a test safety net exists first, and applies named refactoring patterns (extract function, rename, decompose conditional, strangle fig). Reports REFACTOR/WARN with the pattern name and step-by-step instructions. Use when user wants to refactor, reduce complexity, clean up code, or says "improve this without changing behaviour".
---

# /aos-refactor

Select files to refactor, then run `/aos-refactor`.

For targeted refactors: `/aos-refactor complexity` · `/aos-refactor naming` · `/aos-refactor duplication` · `/aos-refactor debt`

## Golden rule

**Never refactor without a safety net.** If the code has no tests, write characterisation tests first — then refactor.

## What gets checked

### Safety net
- [ ] The behaviour being changed has tests that describe outcomes, not implementation
- [ ] CI runs tests automatically so regressions are caught immediately
- [ ] Tests do not assert internal implementation details — they survive a refactor

### Naming
- [ ] Variable names reveal intent: `user` not `u`, `expiresAt` not `ts`
- [ ] Functions named for what they return or do: `getUserByEmail`, not `process`
- [ ] Booleans are positive and assertive: `isActive`, `hasPermission` — not `notInactive`, `permMissing`
- [ ] No unexplained abbreviations (HTTP, URL, ID, OK are fine; `usr`, `mgr`, `tmp` are not)

### Function complexity
- [ ] Functions have a single responsibility
- [ ] Cyclomatic complexity ≤ 10 per function
- [ ] Functions ≤ 30 lines — if scrolling is needed, extract
- [ ] Nested `if/else` deeper than 3 levels is flattened with guard clauses or extracted

### Duplication
- [ ] Duplicate logic extracted to a shared, named function
- [ ] Duplicate configuration extracted to a named constant
- [ ] Similar classes with minor differences unified with a parameter or strategy pattern

### Abstraction level
- [ ] No premature abstraction — extracted only when used in ≥ 2 real places
- [ ] Abstractions named for *what* they do, not *how*: `PaymentGateway`, not `IStripeWrapper`
- [ ] No leaky abstractions — the caller does not need to know the implementation detail

### Technical debt classification
- [ ] **Reckless / inadvertent** — never acceptable. Fix now.
- [ ] **Prudent / intentional** — documented in a tracked issue with a timeline.
- [ ] **Bit rot** — outdated patterns. Fix opportunistically using the Boy Scout Rule.

## Refactoring patterns

| Pattern | When to apply |
|---|---|
| **Extract function** | A block of code does one thing and can be named |
| **Rename** | The current name is misleading, abbreviated, or inaccurate |
| **Move** | Code lives in the wrong layer or module |
| **Inline** | An abstraction is used once and adds no clarity |
| **Decompose conditional** | A complex `if` condition is hard to read — extract it into a named predicate |
| **Replace magic number** | A literal value appears without explanation |
| **Introduce parameter object** | A function takes 4+ related arguments |
| **Guard clauses** | Nested conditionals — flatten with early returns |
| **Strangle fig** | Replacing a large system incrementally, running old and new in parallel |
| **Parallel change** | Changing a function signature used in many callers without a big-bang migration |

## Output format

```
[WARN] Safety net — OrderService has no tests
Action: write characterisation tests before refactoring
  Suggested: it('should return the correct total for a standard order')

[REFACTOR] Extract function — discount logic on lines 45–68 buried inside processOrder()
File: src/orders/order.service.ts:45
Pattern: Extract Function
Steps:
  1. Create: applyPromoCode(total: number, code: string): Promise<number>
  2. Move lines 45–68 into the new function
  3. Replace with: const finalPrice = await this.applyPromoCode(total, code)
  4. Run tests — no behaviour change should occur

[REFACTOR] Naming — variable 'd' holds a discount percentage
File: src/orders/order.service.ts:47
Pattern: Rename
Fix: rename d → discountPercent
```

## Full reference

See [REFERENCE.md](REFERENCE.md) for before/after examples of every pattern.
