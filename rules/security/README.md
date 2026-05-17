# ArchitectOS Security Rules

Automated and manual checks that enforce the security standards defined in `standards/security/README.md`. These rules gate every PR and CI pipeline run.

---

## Authentication Rules

### Rule: JWT Access Tokens Must Expire Within 15 Minutes

Short-lived access tokens limit blast radius if a token is compromised.

```typescript
// ✅ 15-minute expiry
const accessToken = jwt.sign(payload, secret, { expiresIn: '15m' })

// ❌ Long-lived access token — hours or days
const accessToken = jwt.sign(payload, secret, { expiresIn: '7d' })
```

Refresh tokens may be long-lived (7-30 days) but must be:
- Stored server-side (Redis or database)
- Rotated on every use
- Revocable

---

### Rule: Refresh Tokens Must Be Rotated

```typescript
async refreshAccessToken(refreshToken: string): Promise<AuthTokens> {
  // 1. Verify the refresh token exists and is valid
  const stored = await this.cache.get(`refresh:${refreshToken}`)
  if (!stored) throw new AuthenticationError('Invalid refresh token')

  // 2. Delete the old refresh token (rotation)
  await this.cache.del(`refresh:${refreshToken}`)

  // 3. Issue new token pair
  const newRefreshToken = crypto.randomBytes(64).toString('hex')
  const newAccessToken = this.generateAccessToken(stored.userId)

  // 4. Store the new refresh token
  await this.cache.set(`refresh:${newRefreshToken}`, stored, { ttl: 604800 })

  return { accessToken: newAccessToken, refreshToken: newRefreshToken }
}
```

---

### Rule: Use Constant-Time Comparison for Secrets

Timing attacks can leak information from naive string comparison.

```typescript
// ✅ Constant-time comparison
import { timingSafeEqual } from 'crypto'

function safeCompare(a: string, b: string): boolean {
  const bufA = Buffer.from(a)
  const bufB = Buffer.from(b)
  if (bufA.length !== bufB.length) return false
  return timingSafeEqual(bufA, bufB)
}

// ❌ Short-circuit comparison leaks timing information
if (providedToken === storedToken) { ... }
```

---

### Rule: Rate Limit Authentication Endpoints

```typescript
// Maximum 10 attempts per 15 minutes per IP
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  skipSuccessfulRequests: false,  // Count successes too — detect credential stuffing
  standardHeaders: true,
  message: {
    statusCode: 429,
    error: 'TOO_MANY_REQUESTS',
    message: 'Too many authentication attempts. Try again in 15 minutes.',
  },
})
```

---

### Rule: Log All Authentication Events

```typescript
// Every login attempt — success or failure
await securityLogger.logAuthAttempt({
  email: credentials.email,
  success: false,
  failureReason: 'invalid_password',
  ip: req.ip,
  userAgent: req.get('User-Agent'),
  timestamp: new Date(),
})
```

---

## Authorization Rules

### Rule: Deny by Default

When evaluating permissions, the default outcome must be `DENY`. Explicit grants are required.

```typescript
// ✅ Deny by default
function hasPermission(user: User, permission: Permission): boolean {
  const userPermissions = rolePermissions[user.role] ?? []
  return userPermissions.includes(permission)
  // If user.role has no mapped permissions, returns false
}

// ❌ Allow by default — any unrecognized role gets access
function hasPermission(user: User, permission: Permission): boolean {
  const userPermissions = rolePermissions[user.role] ?? [permission]  // Dangerous default
  return userPermissions.includes(permission)
}
```

---

### Rule: Validate Resource Ownership

Do not rely solely on route parameter IDs. Verify the requesting user owns or has access to the resource.

```typescript
// ✅ Ownership check
@Get(':id')
@UseGuards(JwtAuthGuard)
async getOrder(@Param('id', ParseUUIDPipe) id: string, @Request() req) {
  const order = await this.orderService.findById(id)
  if (!order) throw new NotFoundException()

  // Verify ownership before returning
  if (order.userId !== req.user.id && req.user.role !== UserRole.ADMIN) {
    throw new ForbiddenException()
  }

  return order
}

// ❌ IDOR vulnerability — any authenticated user can read any order
@Get(':id')
@UseGuards(JwtAuthGuard)
async getOrder(@Param('id') id: string) {
  return this.orderService.findById(id)
}
```

---

## Input Validation Rules

### Rule: Validate and Sanitize All External Inputs

Inputs from users, external APIs, message queues, and files are untrusted.

```typescript
// ✅ Strict schema validation with whitelist
const CreateOrderSchema = z.object({
  items: z.array(z.object({
    productId: z.string().uuid(),
    quantity: z.number().int().min(1).max(100),
  })).min(1).max(50),
  shippingAddressId: z.string().uuid(),
  couponCode: z.string().max(20).optional(),
})

// Validate at the boundary — reject the request if validation fails
const parsed = CreateOrderSchema.safeParse(req.body)
if (!parsed.success) {
  throw new ValidationError(parsed.error.flatten())
}
```

---

### Rule: Prevent Mass Assignment

Use a whitelist of allowed fields when updating models from request bodies.

```typescript
// ✅ Pick only safe fields from the DTO
async updateUser(id: string, dto: UpdateUserDto): Promise<User> {
  const safeFields = pick(dto, ['firstName', 'lastName', 'avatarUrl'])
  return this.userRepository.update(id, safeFields)
}

// ❌ Spreading entire body — user could set role, isAdmin, etc.
await this.userRepository.update(id, { ...req.body })
```

---

### Rule: Sanitize HTML Before Storage or Display

```typescript
import DOMPurify from 'isomorphic-dompurify'

// ✅ Allowlist-based sanitization
const sanitized = DOMPurify.sanitize(userInput, {
  ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'ul', 'ol', 'li'],
  ALLOWED_ATTR: [],  // No attributes — prevents data: URIs, event handlers
})

// ❌ Storing raw HTML without sanitization
await this.postRepo.save({ content: req.body.content })
```

---

## Secrets Management Rules

### Rule: Secrets Must Never Appear in Code or Logs

CI enforcement via secret scanning:

```yaml
# .github/workflows/security.yml
- name: Secret scanning
  uses: gitleaks/gitleaks-action@v2
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

```typescript
// ✅ Load secrets from environment
const jwtSecret = process.env.JWT_SECRET
if (!jwtSecret || jwtSecret.length < 32) {
  throw new Error('JWT_SECRET must be at least 32 characters')
}

// ❌ Hardcoded secret
const jwtSecret = 'my-secret-key-123'
```

---

### Rule: Validate All Required Secrets at Startup

Fail fast if configuration is missing rather than silently proceeding.

```typescript
const envSchema = z.object({
  JWT_SECRET: z.string().min(32),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),
  ENCRYPTION_KEY: z.string().length(64),  // 256-bit hex key
})

export const env = envSchema.parse(process.env)
// Throws at startup if any required variable is missing or malformed
```

---

## Transport Security Rules

### Rule: HTTPS Only in Production

```typescript
// ✅ Redirect HTTP to HTTPS
app.use((req, res, next) => {
  if (process.env.NODE_ENV === 'production' && !req.secure) {
    return res.redirect(301, `https://${req.headers.host}${req.url}`)
  }
  next()
})

// ✅ HSTS header
app.use(helmet.hsts({
  maxAge: 31536000,
  includeSubDomains: true,
  preload: true,
}))
```

---

### Rule: Security Headers Required

```typescript
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'data:', 'https:'],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      frameAncestors: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  xContentTypeOptions: true,
  xDnsPrefetchControl: { allow: false },
  xDownloadOptions: true,
  xFrameOptions: { action: 'deny' },
  xPermittedCrossDomainPolicies: { permittedPolicies: 'none' },
}))
```

---

## Dependency Security Rules

### Rule: Audit Dependencies on Every Build

```yaml
# .github/workflows/security.yml
- name: Dependency audit
  run: npm audit --audit-level high

- name: OWASP dependency check
  uses: dependency-check/Dependency-Check_Action@main
  with:
    project: 'my-app'
    path: '.'
    format: 'SARIF'
    out: 'reports'
```

### Rule: Keep Dependencies Updated

- Patch versions: update within 1 week
- Minor versions: update within 1 month
- Major versions: evaluate within 1 quarter

Use Dependabot or Renovate to automate dependency update PRs.

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: npm
    directory: /
    schedule:
      interval: weekly
    open-pull-requests-limit: 10
    groups:
      dev-dependencies:
        dependency-type: development
```

---

## File Upload Security Rules

### Rule: Validate File Type by Content, Not Extension

```typescript
import fileType from 'file-type'

async validateUpload(buffer: Buffer, allowedTypes: string[]): Promise<void> {
  const detected = await fileType.fromBuffer(buffer)

  if (!detected || !allowedTypes.includes(detected.mime)) {
    throw new ValidationError(`File type ${detected?.mime ?? 'unknown'} is not allowed`)
  }

  // ✅ Validate size
  const maxSizeMb = 10
  if (buffer.length > maxSizeMb * 1024 * 1024) {
    throw new ValidationError(`File exceeds maximum size of ${maxSizeMb}MB`)
  }
}
```

### Rule: Never Store Uploaded Files in the Application Directory

```typescript
// ✅ Store in object storage (S3, GCS, MinIO)
const key = `uploads/${userId}/${crypto.randomUUID()}.${ext}`
await s3.putObject({ Bucket: process.env.S3_BUCKET, Key: key, Body: buffer })

// ❌ Storing in the app's filesystem — path traversal risk, not scalable
fs.writeFileSync(`./uploads/${filename}`, buffer)
```
