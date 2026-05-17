# Security Check — Reference Rules

## JWT configuration

```typescript
// ✅ Short-lived access tokens
const accessToken = jwt.sign(payload, secret, { expiresIn: '15m' })
const refreshToken = crypto.randomBytes(64).toString('hex')

// ❌ Long-lived access tokens
const accessToken = jwt.sign(payload, secret, { expiresIn: '7d' })
```

## Refresh token rotation

```typescript
async refreshAccessToken(token: string) {
  const stored = await cache.get(`refresh:${token}`)
  if (!stored) throw new AuthError('Invalid refresh token')

  await cache.del(`refresh:${token}`)                        // rotate — invalidate old
  const newRefresh = crypto.randomBytes(64).toString('hex')
  await cache.set(`refresh:${newRefresh}`, stored, { ttl: 604800 })

  return { accessToken: generateAccess(stored.userId), refreshToken: newRefresh }
}
```

## Constant-time comparison

```typescript
// ✅
import { timingSafeEqual } from 'crypto'
function safeCompare(a: string, b: string): boolean {
  const ba = Buffer.from(a), bb = Buffer.from(b)
  if (ba.length !== bb.length) return false
  return timingSafeEqual(ba, bb)
}

// ❌ — timing leak
if (providedToken === storedToken) { ... }
```

## IDOR prevention

```typescript
// ✅ — verify ownership before returning
const order = await this.orders.findById(id)
if (!order) throw new NotFoundException()
if (order.userId !== req.user.id) throw new ForbiddenException()
return order

// ❌ — IDOR: any authenticated user can read any order
return this.orders.findById(id)
```

## Deny by default

```typescript
// ✅
function hasPermission(user: User, permission: Permission): boolean {
  const granted = rolePermissions[user.role] ?? []
  return granted.includes(permission)
}

// ❌ — unrecognized role gets access
const granted = rolePermissions[user.role] ?? [permission]
```

## Input validation

```typescript
// ✅ NestJS DTO
class CreateOrderDto {
  @IsUUID() productId: string
  @IsInt() @Min(1) @Max(100) quantity: number
}

// ✅ Zod
const schema = z.object({
  productId: z.string().uuid(),
  quantity: z.number().int().min(1).max(100),
})
```

## Mass assignment prevention

```typescript
// ✅
const safe = pick(dto, ['firstName', 'lastName', 'avatarUrl'])
await this.users.update(id, safe)

// ❌ — user could set role, isAdmin, etc.
await this.users.update(id, { ...req.body })
```

## File upload validation

```typescript
// ✅ — validate by content, not extension
import fileType from 'file-type'
const detected = await fileType.fromBuffer(buffer)
const allowed = ['image/jpeg', 'image/png', 'image/webp']
if (!detected || !allowed.includes(detected.mime)) {
  throw new ValidationError('File type not allowed')
}

// ✅ — store in object storage, not filesystem
await s3.putObject({ Bucket: env.S3_BUCKET, Key: `uploads/${uuid}.${ext}`, Body: buffer })

// ❌ — stores on app filesystem (path traversal risk, not scalable)
fs.writeFileSync(`./uploads/${filename}`, buffer)
```

## Env validation at startup

```typescript
// ✅ — fails fast if config is missing
const envSchema = z.object({
  JWT_SECRET: z.string().min(32),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
})
export const env = envSchema.parse(process.env)
```

## Security headers

```typescript
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      objectSrc: ["'none'"],
      frameAncestors: ["'none'"],
    },
  },
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
}))
```
