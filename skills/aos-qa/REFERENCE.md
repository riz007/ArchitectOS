# QA Testing — Reference Standards

## The test pyramid

```
            /\
           /E2E\          ~10% — critical user journeys only
          /------\
         /Integr. \       ~20% — service + real DB/HTTP
        /----------\
       /    Unit    \     ~70% — pure functions, services, isolated logic
      /--------------\
```

**Unit test — no I/O, runs in milliseconds**
```typescript
it('should calculate order total with tax applied', () => {
  const items = [{ price: 100, qty: 2 }, { price: 50, qty: 1 }]
  const total = calculateTotal(items, 0.1)
  expect(total).toBe(275) // (200 + 50) * 1.10
})
```

**Integration test — real database, real queries**
```typescript
it('should persist a user and return it with a generated id', async () => {
  const repo = new UserRepository(testDb)
  const created = await repo.save({ email: 'test@example.com', name: 'Test' })

  expect(created.id).toBeDefined()
  const found = await repo.findById(created.id)
  expect(found?.email).toBe('test@example.com')
})
```

---

## Test naming

```typescript
// ✅ — describes the behaviour and the scenario
it('should throw ConflictError when email is already registered')
it('should return null when user does not exist')
it('should not include passwordHash in the response DTO')
it('should apply a 10% discount when user holds a valid promo code')
it('should reject the request when the JWT is expired')

// ❌ — tells you nothing about the expected behaviour
it('test create user')
it('works')
it('error case')
it('should call save')
```

---

## Arrange–Act–Assert structure

```typescript
it('should send a welcome email after user registration', async () => {
  // Arrange
  const emailService = { sendWelcome: jest.fn().mockResolvedValue(undefined) }
  const service = new UserService(userRepo, emailService)
  const dto = { email: 'new@example.com', password: 'secret123' }

  // Act
  await service.register(dto)

  // Assert
  expect(emailService.sendWelcome).toHaveBeenCalledWith('new@example.com')
})
```

---

## Mocking strategy

**Mock at system boundaries only**
```typescript
// ✅ — mock the repository interface (boundary with the DB)
const userRepo: jest.Mocked<UserRepository> = {
  findByEmail: jest.fn(),
  save: jest.fn(),
  findById: jest.fn(),
}
const service = new UserService(userRepo)

// ❌ — mocking an internal method tests implementation, not behaviour
jest.spyOn(service, 'hashPassword').mockResolvedValue('hashed')
```

**Typed mocks**
```typescript
// ✅ — satisfies ensures the mock implements the real interface
import type { EmailService } from '../email/email.service'

const emailService = {
  sendWelcome: jest.fn().mockResolvedValue(undefined),
  sendPasswordReset: jest.fn().mockResolvedValue(undefined),
} satisfies jest.Mocked<EmailService>
```

---

## Test isolation

```typescript
// ✅ — fresh dependencies for every test
describe('UserService', () => {
  let service: UserService
  let userRepo: jest.Mocked<UserRepository>

  beforeEach(() => {
    userRepo = { findByEmail: jest.fn(), save: jest.fn(), findById: jest.fn() }
    service = new UserService(userRepo)
  })

  it('should throw when email is taken', async () => {
    userRepo.findByEmail.mockResolvedValue(makeUser())
    await expect(service.register({ email: 'taken@x.com', password: '12345678' }))
      .rejects.toThrow(ConflictError)
  })
})

// ❌ — shared mock state leaks between tests
const userRepo = { findByEmail: jest.fn() }  // defined outside describe
```

---

## Test data factories

```typescript
// ✅ — factory with sensible defaults and unlimited overrides
function makeUser(overrides: Partial<User> = {}): User {
  return {
    id: crypto.randomUUID(),
    email: `user-${Date.now()}@example.com`,
    name: 'Test User',
    role: 'user',
    plan: 'free',
    createdAt: new Date(),
    ...overrides,
  }
}

// Usage
const admin    = makeUser({ role: 'admin' })
const premium  = makeUser({ plan: 'premium' })
const newUser  = makeUser({ createdAt: new Date() })
```

---

## Coverage targets

| Layer | Target | Rationale |
|---|---|---|
| Domain services | ≥ 90% | Pure business logic — cheap and critical to test |
| Controllers | ≥ 70% | Thin, but must catch routing and guard mistakes |
| Repositories | ≥ 60% | Integration tests are slower; focus on critical queries |
| UI components | ≥ 50% | Test user interactions, not render output |
| Utility functions | 100% | Pure functions, no excuse for gaps |

---

## E2E test — critical journey only

```typescript
// ✅ — tests the checkout journey, not every field validation
test('user can complete a purchase', async ({ page }) => {
  await page.goto('/login')
  await page.fill('[name=email]', 'buyer@example.com')
  await page.fill('[name=password]', 'password123')
  await page.click('button[type=submit]')

  await page.goto('/products/widget-pro')
  await page.click('text=Add to cart')
  await page.goto('/checkout')
  await page.click('text=Place order')

  await expect(page.locator('h1')).toHaveText('Order confirmed')
})

// ❌ — e2e testing a single form field; use a unit test instead
test('email field shows error on invalid input', async ({ page }) => { ... })
```
