# Refactoring — Pattern Reference

Patterns from *Refactoring* by Martin Fowler (2nd Edition), applied to TypeScript/JavaScript.

---

## Safety net first

Before changing anything, write a characterisation test that pins the current behaviour.

```typescript
// You are about to refactor OrderService.processOrder().
// Write this test FIRST — before touching a single line.

it('should calculate order total with a valid promo code applied', async () => {
  const order = makeOrder({ items: [{ price: 100, qty: 2 }] })  // total = 200
  const result = await service.processOrder(order, 'SAVE20')     // 20% off
  expect(result.total).toBe(160)
})

it('should use full price when the promo code is expired', async () => {
  const order = makeOrder({ items: [{ price: 100, qty: 1 }] })
  const result = await service.processOrder(order, 'EXPIRED10')
  expect(result.total).toBe(100)
})

// Now refactor. These tests will catch any regression.
```

---

## Extract Function

**When:** A block of code does one thing and can be given a name.

```typescript
// ❌ — before: discount logic buried inside processOrder
async processOrder(order: Order, promoCode?: string) {
  let total = order.items.reduce((sum, i) => sum + i.price * i.qty, 0)
  if (promoCode) {
    const promo = await this.promoRepo.findByCode(promoCode)
    if (promo && promo.expiresAt > new Date()) {
      total = total * (1 - promo.discountPercent / 100)
    }
  }
  order.total = total
  await this.orderRepo.save(order)
}

// ✅ — after: extracted with a name that reveals intent
private async applyPromoCode(subtotal: number, code: string): Promise<number> {
  const promo = await this.promoRepo.findByCode(code)
  if (!promo || promo.expiresAt <= new Date()) return subtotal
  return subtotal * (1 - promo.discountPercent / 100)
}

async processOrder(order: Order, promoCode?: string) {
  let total = order.items.reduce((sum, i) => sum + i.price * i.qty, 0)
  if (promoCode) total = await this.applyPromoCode(total, promoCode)
  order.total = total
  await this.orderRepo.save(order)
}
```

---

## Rename

**When:** A name is misleading, abbreviated, or no longer accurate.

```typescript
// ❌ — abbreviations require decoding
const usr  = await this.r.findOne(uid)
const ts   = usr?.lastLogin?.getTime()
const ok   = ts ? Date.now() - ts < SESSION_TTL : false

// ✅ — names read like prose
const user           = await this.userRepository.findOne(userId)
const lastLoginMs    = user?.lastLoginAt?.getTime()
const isSessionValid = lastLoginMs ? Date.now() - lastLoginMs < SESSION_TTL_MS : false
```

---

## Guard Clauses (Flatten Arrow-Head)

**When:** Nested conditionals make it hard to see the happy path.

```typescript
// ❌ — reader must track three levels of nesting
function processPayment(order: Order | null) {
  if (order) {
    if (order.status === 'pending') {
      if (order.total > 0) {
        charge(order)
      }
    }
  }
}

// ✅ — exit early, happy path is unindented and obvious
function processPayment(order: Order | null) {
  if (!order)                    return
  if (order.status !== 'pending') return
  if (order.total <= 0)           return
  charge(order)
}
```

---

## Decompose Conditional

**When:** A complex `if` condition needs explanation to understand.

```typescript
// ❌ — reader must parse the entire expression to understand the rule
if (
  user.plan === 'premium' &&
  order.items.length > 0 &&
  order.createdAt >= currentPromo.startDate &&
  order.createdAt <= currentPromo.endDate
) {
  applyDiscount()
}

// ✅ — extract the condition into a named predicate
const isEligibleForPromo = (user: User, order: Order, promo: Promo): boolean =>
  user.plan === 'premium' &&
  order.items.length > 0 &&
  order.createdAt >= promo.startDate &&
  order.createdAt <= promo.endDate

if (isEligibleForPromo(user, order, currentPromo)) {
  applyDiscount()
}
```

---

## Replace Magic Number

```typescript
// ❌
const expiry = Date.now() + 900000
if (resetToken.length < 32) throw new Error()
await cache.set(key, value, 604800)

// ✅
const ACCESS_TOKEN_TTL_MS  = 15 * 60 * 1000   // 15 minutes
const RESET_TOKEN_MIN_LEN  = 32
const REFRESH_TOKEN_TTL_S  = 7 * 24 * 60 * 60  // 7 days

const expiry = Date.now() + ACCESS_TOKEN_TTL_MS
if (resetToken.length < RESET_TOKEN_MIN_LEN) throw new Error()
await cache.set(key, value, REFRESH_TOKEN_TTL_S)
```

---

## Introduce Parameter Object

**When:** A function takes 4+ related arguments that always travel together.

```typescript
// ❌ — callers must remember argument order; easy to swap start/end
function searchOrders(
  userId: string,
  status: string,
  from: Date,
  to: Date,
  page: number,
  limit: number
) {}

// ✅ — named, self-documenting, extensible
interface OrderSearchParams {
  userId: string
  status: 'pending' | 'paid' | 'cancelled'
  dateRange: { from: Date; to: Date }
  pagination: { page: number; limit: number }
}

function searchOrders(params: OrderSearchParams) {}
```

---

## Strangle Fig

**When:** Replacing a large, risky legacy system incrementally.

```
                    ┌──────────────┐
Requests ──────────►│ Feature Flag │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
       ┌─────────────┐         ┌──────────────────┐
       │   Legacy V1  │         │   New Service V2  │
       └─────────────┘         └──────────────────┘
```

```typescript
// Step 1 — route a percentage of traffic to V2
if (featureFlags.isEnabled('new-order-service', userId)) {
  return this.orderServiceV2.process(dto)
}
return this.orderServiceV1.process(dto)

// Step 2 — gradually increase to 100%
// Step 3 — remove the flag and delete V1
```

---

## Parallel Change (Expand–Contract)

**When:** Changing a public function signature that many callers depend on.

```typescript
// Step 1 — EXPAND: add new signature, keep old working
function findUser(idOrParams: string | { id: string }): Promise<User | null> {
  const id = typeof idOrParams === 'string' ? idOrParams : idOrParams.id
  return userRepo.findById(id)
}

// Step 2 — migrate all callers from findUser('abc') to findUser({ id: 'abc' })
// (one commit per caller, or a single codemod)

// Step 3 — CONTRACT: remove the old string overload
function findUser(params: { id: string }): Promise<User | null> {
  return userRepo.findById(params.id)
}
```

---

## Inline Function

**When:** A function is used once and its name adds no clarity over the code itself.

```typescript
// ❌ — wrapping a one-liner in a function that's only called once
function isAdult(user: User): boolean {
  return user.age >= 18
}
if (isAdult(currentUser)) { ... }

// ✅ — inline it; no abstraction needed for one call site
if (currentUser.age >= 18) { ... }
// Reserve the function form for when there are ≥ 2 call sites, or the logic grows.
```
