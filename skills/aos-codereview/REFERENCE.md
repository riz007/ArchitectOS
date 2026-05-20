# Code Review — Reference Guide

## Correctness patterns

**Floating promises — always `await`**
```typescript
// ❌ — error silently lost; caller continues before work completes
async function handleRefund(req, res) {
  processRefund(req.params.id)   // floating promise
  res.json({ queued: true })
}

// ✅
async function handleRefund(req, res) {
  await processRefund(req.params.id)
  res.json({ done: true })
}

// ✅ — intentional fire-and-forget must handle its own error
processRefund(req.params.id).catch(err =>
  logger.error({ err, id: req.params.id }, 'Refund processing failed')
)
```

**Null / undefined safety**
```typescript
// ❌ — throws TypeError when user is not found
const user = await userRepo.findById(id)
return user.profile.bio

// ✅
const user = await userRepo.findById(id)
if (!user) throw new NotFoundException(`User ${id} not found`)
return user.profile?.bio ?? null
```

**Off-by-one in pagination**
```typescript
// ❌ — page 1 skips the first row when using 0-based math
const skip = page * limit        // page=1 → skip=10, but page=0 → skip=0

// ✅ — explicit 1-indexed: page=1 → skip=0, page=2 → skip=10
const skip = (page - 1) * limit
```

---

## Breaking change patterns

**Adding a field to an API response**
```typescript
// ✅ — additive changes are safe; clients ignore unknown fields
return { id: user.id, email: user.email, createdAt: user.createdAt }  // new field added
```

**Removing or renaming a response field**
```typescript
// ❌ — breaks all clients reading 'username'
return { id: user.id, handle: user.username }  // renamed without deprecation

// ✅ — dual-write during deprecation window
return { id: user.id, username: user.username, handle: user.username }  // both present
// Remove 'username' in the next major version after all clients migrated.
```

**Dropping a database column (phased)**
```sql
-- Phase 1 (this PR): stop writing to legacy_token
-- Phase 2 (next deploy): stop reading from legacy_token
-- Phase 3 (following sprint): drop the column
ALTER TABLE sessions DROP COLUMN legacy_token;
```

**New required environment variable**
```bash
# ✅ — always document in .env.example with a comment
STRIPE_WEBHOOK_SECRET=   # required: found in Stripe Dashboard → Webhooks
```

---

## Security quick scan checklist

| What to check | Pass | Fail |
|---|---|---|
| SQL queries | `WHERE id = $1` | `WHERE id = '${id}'` |
| Shell commands | `execFile('convert', [arg])` | `exec('convert ' + arg)` |
| Auth on new routes | `@UseGuards(JwtAuthGuard)` | No guard |
| Secrets in source | `process.env.API_KEY` | `const key = 'sk_live_...'` |
| Sensitive data in logs | `logger.info({ userId })` | `logger.info({ user })` (includes hash) |

---

## Performance quick scan checklist

**N+1 queries**
```typescript
// ❌ — one query per order item (N+1)
const orders = await orderRepo.findAll()
for (const order of orders) {
  order.items = await itemRepo.findByOrder(order.id)
}

// ✅ — single joined query
const orders = await orderRepo.findAllWithItems()
```

**Unbounded query**
```typescript
// ❌ — returns every row; catastrophic at scale
return this.userRepo.findAll()

// ✅ — always paginate
return this.userRepo.findAll({ page, limit: Math.min(limit, 100) })
```

---

## Review comment examples

**Blocking issue — specific, no ambiguity**
```
[BLOCK] src/orders/orders.controller.ts:28

This endpoint is missing a JwtAuthGuard. Any unauthenticated request
can read any user's order by guessing its ID (IDOR).

Fix:
  @Get(':id')
  @UseGuards(JwtAuthGuard)
  async findOne(@Param('id') id: string, @Request() req) {
    return this.orders.findOneForUser(id, req.user.id)
  }
```

**Non-blocking change request**
```
[REQUEST] src/users/user.service.ts:89

No test covers the case where a user tries to update their email to one
that is already taken. This path exists in the code but has no test — it
will be a regression risk every time this file is touched.

Suggested test name: 'should throw ConflictError when new email is already registered'
```

**Nit — clearly optional, no pressure**
```
nit: `resp` on line 34 — I wasn't sure what it held at first glance.
`apiResponse` would be clearer, but this won't block approval.
```

**Praise — name the pattern you're praising**
```
The repository interface in the domain layer and the TypeORM implementation
in infrastructure is exactly the right split. This means the service tests
don't touch the DB at all. Well done.
```

---

## Review etiquette checklist

1. **Read the PR description and linked issue first.** Understand the *why* before reviewing the *how*.
2. **One thorough pass.** Batch all comments; don't drip-feed review rounds over three days.
3. **Distinguish blocking from optional.** Use `[BLOCK]`, `[REQUEST]`, and `nit:` consistently.
4. **Resolve threads you opened** once addressed — don't leave them open indefinitely.
5. **Approve within 24 business hours** of the last round of changes — stale PRs accumulate conflicts.
6. **Don't bike-shed style** if the project has a linter — let the linter own style.
7. **Praise generously.** A review with only criticism trains authors to dread the process.
