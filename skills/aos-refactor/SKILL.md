---
name: aos-refactor
description: Guides safe code refactoring — identifies what to improve, ensures a test safety net exists first, and applies named refactoring patterns (extract function, rename, decompose conditional, strangle fig, parallel change). Reports REFACTOR/WARN with the pattern name and step-by-step instructions. Use when user wants to refactor, reduce complexity, clean up code, or says "improve this without changing behaviour".
---

# /aos-refactor

Select files to refactor, then run `/aos-refactor`.

For targeted refactors: `/aos-refactor complexity` · `/aos-refactor naming` · `/aos-refactor duplication` · `/aos-refactor debt` · `/aos-refactor size`

---

## Golden rule

**Never refactor without a safety net.** If the code has no tests, write characterisation tests first — then refactor. A characterisation test is a test that pins the current behaviour, not the desired behaviour.

---

## What gets checked

### Safety net
- [ ] The behaviour being changed has tests that describe outcomes, not implementation details
- [ ] CI runs automatically so regressions are caught immediately
- [ ] Tests do not assert internal state or method calls — they will survive a refactor

### Naming
- [ ] Variable names reveal intent: `user` not `u`, `expiresAt` not `ts`
- [ ] Functions named for what they return or do: `getUserByEmail`, not `process`
- [ ] Booleans positive and assertive: `isActive`, `hasPermission` — not `notInactive`, `permMissing`
- [ ] No unexplained abbreviations (HTTP, URL, ID, OK are fine; `usr`, `mgr`, `tmp` are not)
- [ ] No misleading names — `getUser` that also deletes is a broken contract

### Function complexity
- [ ] Functions have a single responsibility
- [ ] Cyclomatic complexity ≤ 10 per function (count `if`, `else`, `for`, `while`, `case`, `&&`, `||`)
- [ ] Functions ≤ 30 lines — if scrolling is required to understand it, extract
- [ ] Nested `if/else` deeper than 3 levels flattened with guard clauses or extraction
- [ ] No functions that take a boolean flag to switch between two different behaviours — split into two

### Duplication
- [ ] Duplicate logic extracted to a shared, named function
- [ ] Duplicate configuration extracted to a named constant
- [ ] Similar classes with minor differences unified with a parameter or strategy pattern

### Abstraction level
- [ ] No premature abstraction — extracted only when used in ≥ 2 real places
- [ ] Abstractions named for *what* they do, not *how*: `PaymentGateway`, not `IStripeWrapper`
- [ ] No leaky abstractions — the caller does not need to know the implementation detail
- [ ] Code at one level of abstraction per function — no mixing of high-level intent and low-level detail

### Technical debt classification
- [ ] **Reckless / inadvertent** — never acceptable. Fix now.
- [ ] **Prudent / intentional** — documented in a tracked issue with a timeline.
- [ ] **Bit rot** — outdated patterns. Fix opportunistically using the Boy Scout Rule.

---

## Refactoring patterns

| Pattern | When to apply |
|---|---|
| **Extract function** | A block of code does one thing and can be given a name |
| **Rename** | The current name is misleading, abbreviated, or inaccurate |
| **Move** | Code lives in the wrong layer or module |
| **Inline** | An abstraction is used once and adds no clarity |
| **Decompose conditional** | A complex `if` condition is hard to read — extract into a named predicate |
| **Replace magic number** | A literal value appears without explanation |
| **Introduce parameter object** | A function takes 4+ related arguments |
| **Guard clauses** | Nested conditionals — flatten with early returns |
| **Split function** | A function takes a boolean flag to choose between two paths — split it |
| **Strangle fig** | Replacing a large system incrementally alongside the old one |
| **Parallel change** | Changing a public function signature without a big-bang migration |

---

## Output format

```
[WARN] Safety net — OrderService has no tests
Action: write characterisation tests before refactoring
  Suggested: it('should return the correct total for a standard order')
  Suggested: it('should apply promo code discount when code is valid')

[REFACTOR] Extract function — discount logic on lines 45–68 buried inside processOrder()
File: src/orders/order.service.ts:45
Pattern: Extract Function
Steps:
  1. Create: async applyPromoCode(subtotal: number, code: string): Promise<number>
  2. Move lines 45–68 into the new function
  3. Replace with: const finalPrice = await this.applyPromoCode(total, code)
  4. Run tests — no behaviour change should occur

[REFACTOR] Split function — processUser(user, isDryRun: boolean) does two different things
File: src/users/user.service.ts:88
Pattern: Split Function
Steps:
  1. Create validateUser(user) — the dry-run path
  2. Create persistUser(user) — the real path
  3. Call the right one at each call site
  4. Delete processUser

[REFACTOR] Naming — variable 'd' holds a discount percentage
File: src/orders/order.service.ts:47
Pattern: Rename
Fix: rename d → discountPercent
```

---

## Full reference

See [REFERENCE.md](REFERENCE.md) for before/after examples of every pattern.
