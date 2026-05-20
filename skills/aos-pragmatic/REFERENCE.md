# Pragmatic Engineering — Reference

Principles from *The Pragmatic Programmer* by David Thomas and Andrew Hunt (20th Anniversary Edition).

---

## DRY — Don't Repeat Yourself

> "Every piece of knowledge must have a single, unambiguous, authoritative representation within a system."

DRY is about *knowledge*, not just text. A validation rule that appears in the DTO, the service, and the database migration is three representations of one fact — change the rule and you'll miss one.

```typescript
// ❌ — password policy duplicated across three files
class CreateUserDto {
  @MinLength(8) password: string                // file 1
}
class UserService {
  if (dto.password.length < 8) throw new Error() // file 2
}
// migration: CHECK (length(password) >= 8)         // file 3

// ✅ — one constant, one rule
export const PASSWORD_MIN_LENGTH = 8
class CreateUserDto {
  @MinLength(PASSWORD_MIN_LENGTH) password: string
}
// service trusts the DTO; DB constraint removed — enforced at app boundary
```

---

## Orthogonality

> "Eliminate effects between unrelated things. Design components that are self-contained, independent, and have a single, well-defined purpose."

Two components are orthogonal if changing one does not require changing the other.

```typescript
// ❌ — business logic coupled directly to Stripe
class OrderService {
  async charge(order: Order) {
    const stripe = new Stripe(process.env.STRIPE_KEY!)
    const intent = await stripe.paymentIntents.create({
      amount: order.totalCents,
      currency: 'usd',
    })
    order.status = intent.status === 'succeeded' ? 'paid' : 'failed'
  }
}
// Changing payment provider requires rewriting OrderService.

// ✅ — orthogonal: OrderService knows nothing about Stripe
interface PaymentGateway {
  charge(amountCents: number, currency: string): Promise<{ success: boolean }>
}

class OrderService {
  constructor(private readonly payments: PaymentGateway) {}
  async charge(order: Order) {
    const result = await this.payments.charge(order.totalCents, 'usd')
    order.status = result.success ? 'paid' : 'failed'
  }
}

class StripeAdapter implements PaymentGateway { /* Stripe specifics isolated here */ }
class BraintreeAdapter implements PaymentGateway { /* swap with zero OrderService changes */ }
```

---

## Reversibility

> "There are no final decisions."

Design so you can change your mind. Every external dependency you write against directly is a decision locked into every call site.

```typescript
// ❌ — S3 SDK imported in 12 files; migrating to GCS means 12 edits
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3'
await s3.send(new PutObjectCommand(...))  // scattered everywhere

// ✅ — one seam; swap storage provider by editing one file
interface ObjectStorage {
  put(key: string, body: Buffer, contentType: string): Promise<string>  // returns public URL
  get(key: string): Promise<Buffer>
  delete(key: string): Promise<void>
}

class S3Storage implements ObjectStorage { ... }
class LocalStorage implements ObjectStorage { ... }  // used in tests
// Inject via DI; callers never import AWS SDK.
```

---

## Programming by Coincidence

> "Don't rely on coincidences or assumptions. Code deliberately and understand what you're doing."

Code that works but whose author cannot explain *why* it works will break when the accidental behaviour changes.

```typescript
// ❌ — works because the ORM happens to return results in insertion order
function getLatestOrder(orders: Order[]): Order {
  return orders[0]  // coincidence; ORDER BY not specified
}

// ✅ — explicit about the intent
function getMostRecentOrder(orders: Order[]): Order {
  return orders.reduce((latest, o) =>
    o.createdAt > latest.createdAt ? o : latest
  )
}
```

**No debug artefacts in committed code**
```typescript
// ❌
console.log('DEBUG user:', user)
// const result = await legacyProcessor.run(data)
const result = await newProcessor.run(data)

// ✅ — remove debug logs; delete dead code, or put it behind a feature flag
const result = await newProcessor.run(data)
```

---

## Broken Windows

> "Don't leave broken windows unrepaired. Fix each one as soon as it is discovered."

A single ignored problem signals that quality doesn't matter, and invites more decay.

```typescript
// ❌ — known-wrong code with an untracked comment
function calculateDiscount(price: number, user: any): number {
  // FIXME: doesn't handle premium users
  return price * 0.9
}

// ✅ — either fix it now or create a tracked issue
// Issue: https://github.com/org/repo/issues/142
function calculateDiscount(price: number, user: User): number {
  if (user.plan === 'premium') return price * 0.8
  return price * 0.9
}
```

**Dead code is a broken window**
```typescript
// ❌ — unreachable code that confuses readers
export function legacyFormat(data: unknown) {
  // no longer called anywhere; two major versions behind
}

// ✅ — delete it. Git history preserves it.
```

---

## Boy Scout Rule

> "Always leave the campground cleaner than you found it."

Every commit should leave the codebase slightly better than before — a better name, a removed console.log, a deleted unused import.

```typescript
// You are in user.service.ts fixing an unrelated bug.
// While you are there:

// ❌ — leave the mess
const usr = await this.r.findOne(id)
const d = usr?.dateJoined

// ✅ — rename opportunistically (zero behaviour change)
const user = await this.userRepository.findOne(id)
const joinedAt = user?.createdAt
```

*The campground rule does not mean refactor the entire file — it means leave it slightly better.*

---

## Good Enough Software

> "Know when to stop adding features or layers."

Every abstraction has a maintenance cost. Build for the use cases you have, not the ones you imagine.

```typescript
// ❌ — generic event bus built for a single event
class EventBus<T extends EventMap> {
  private subs = new Map<keyof T, Set<(payload: T[keyof T]) => void>>()
  subscribe<K extends keyof T>(event: K, fn: (p: T[K]) => void): () => void { ... }
  publish<K extends keyof T>(event: K, payload: T[K]): void { ... }
}
// Used exactly once to emit one event.

// ✅ — direct callback; promote to bus when there are ≥ 2 real subscribers
class OrderService {
  constructor(
    private readonly onCharged: (order: Order) => void
  ) {}

  async charge(order: Order) {
    // ...
    this.onCharged(order)
  }
}
```

---

## Tracer Bullets

> "Use tracer bullets to find your target. Build a thin slice end-to-end first."

Rather than building each layer completely before moving to the next, build a thin path from input to output that actually runs. Then thicken it.

```
Sprint 1 — tracer bullet:
  POST /invoices → minimal service → minimal DB row → 201 Created
  (no PDF, no email, no audit log — just the skeleton working end-to-end)

Sprint 2 — flesh it out:
  Add PDF generation, email notification, audit trail, validation edge cases
```

*Tracer bullets are not prototypes — they are production code, just minimal.*
