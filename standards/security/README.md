# ArchitectOS Security Standards

Security is paramount in ArchitectOS. All applications must follow these security standards to protect user data, prevent breaches, and maintain compliance with industry regulations.

## Table of Contents

- [Core Security Principles](#core-security-principles)
- [Authentication & Authorization](#authentication--authorization)
- [Data Protection](#data-protection)
- [Input Validation & Sanitization](#input-validation--sanitization)
- [Secure Coding Practices](#secure-coding-practices)
- [Infrastructure Security](#infrastructure-security)
- [Compliance & Auditing](#compliance--auditing)

## Core Security Principles

### 1. Defense in Depth

Implement multiple layers of security controls:
- Network security (firewalls, VPNs)
- Application security (authentication, validation)
- Data security (encryption, access controls)
- Infrastructure security (hardening, monitoring)

### 2. Principle of Least Privilege

Grant minimum necessary permissions for users and systems.

### 3. Fail-Safe Defaults

Default to secure configurations. Require explicit opt-in for insecure options.

### 4. Security by Design

Integrate security considerations from the earliest stages of development.

## Authentication & Authorization

### JWT Implementation

Use secure JWT patterns:

```typescript
// ✅ Secure JWT implementation
import jwt from 'jsonwebtoken'
import crypto from 'crypto'

export class JwtService {
  private readonly accessTokenSecret: string
  private readonly refreshTokenSecret: string

  constructor() {
    // Load secrets from environment variables
    this.accessTokenSecret = process.env.JWT_ACCESS_SECRET!
    this.refreshTokenSecret = process.env.JWT_REFRESH_SECRET!
  }

  generateTokens(user: User): AuthTokens {
    const accessToken = jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role
      },
      this.accessTokenSecret,
      {
        expiresIn: '15m',
        issuer: 'architect-os',
        audience: 'api'
      }
    )

    const refreshToken = crypto.randomBytes(64).toString('hex')

    // Store refresh token securely (e.g., in Redis with expiration)
    await this.storeRefreshToken(user.id, refreshToken)

    return { accessToken, refreshToken }
  }

  async verifyAccessToken(token: string): Promise<UserPayload> {
    try {
      return jwt.verify(token, this.accessTokenSecret, {
        issuer: 'architect-os',
        audience: 'api'
      }) as UserPayload
    } catch (error) {
      throw new AuthenticationError('Invalid access token')
    }
  }
}
```

### Password Security

Implement strong password policies:

```typescript
// ✅ Secure password handling
import bcrypt from 'bcrypt'
import crypto from 'crypto'

export class PasswordService {
  private readonly saltRounds = 12

  async hashPassword(password: string): Promise<string> {
    // Validate password strength
    this.validatePasswordStrength(password)

    return bcrypt.hash(password, this.saltRounds)
  }

  async verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash)
  }

  private validatePasswordStrength(password: string): void {
    if (password.length < 8) {
      throw new ValidationError('Password must be at least 8 characters')
    }

    if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(password)) {
      throw new ValidationError(
        'Password must contain uppercase, lowercase, and numeric characters'
      )
    }
  }

  generateResetToken(): string {
    return crypto.randomBytes(32).toString('hex')
  }
}
```

### Role-Based Access Control (RBAC)

Implement granular permissions:

```typescript
// ✅ RBAC implementation
export enum Permission {
  READ_USER = 'read:user',
  WRITE_USER = 'write:user',
  DELETE_USER = 'delete:user',
  ADMIN = 'admin'
}

export enum Role {
  USER = 'user',
  MODERATOR = 'moderator',
  ADMIN = 'admin'
}

const rolePermissions: Record<Role, Permission[]> = {
  [Role.USER]: [Permission.READ_USER],
  [Role.MODERATOR]: [Permission.READ_USER, Permission.WRITE_USER],
  [Role.ADMIN]: [Permission.ADMIN] // Admin has all permissions
}

export class AuthorizationService {
  hasPermission(user: User, permission: Permission): boolean {
    const userPermissions = rolePermissions[user.role] || []
    return userPermissions.includes(permission) || userPermissions.includes(Permission.ADMIN)
  }

  requirePermission(user: User, permission: Permission): void {
    if (!this.hasPermission(user, permission)) {
      throw new AuthorizationError(`Missing permission: ${permission}`)
    }
  }
}
```

## Data Protection

### Encryption at Rest

Encrypt sensitive data in databases:

```typescript
// ✅ Database encryption
import { encrypt, decrypt } from './crypto-utils'

export class UserRepository {
  async save(user: User): Promise<void> {
    const encryptedEmail = encrypt(user.email)
    const encryptedSSN = user.ssn ? encrypt(user.ssn) : null

    await this.db.users.create({
      ...user,
      email: encryptedEmail,
      ssn: encryptedSSN
    })
  }

  async findById(id: string): Promise<User | null> {
    const userData = await this.db.users.findById(id)
    if (!userData) return null

    return {
      ...userData,
      email: decrypt(userData.email),
      ssn: userData.ssn ? decrypt(userData.ssn) : undefined
    }
  }
}
```

### Data Sanitization

Sanitize data before storage and display:

```typescript
// ✅ Data sanitization
import DOMPurify from 'dompurify'
import validator from 'validator'

export class DataSanitizer {
  sanitizeHtml(html: string): string {
    return DOMPurify.sanitize(html, {
      ALLOWED_TAGS: ['p', 'br', 'strong', 'em'],
      ALLOWED_ATTR: []
    })
  }

  sanitizeEmail(email: string): string {
    return validator.normalizeEmail(email) || ''
  }

  sanitizeSqlInput(input: string): string {
    // Use parameterized queries instead of manual sanitization
    // This is just for display purposes
    return input.replace(/[<>'"&]/g, (char) => {
      const entityMap: Record<string, string> = {
        '<': '&lt;',
        '>': '&gt;',
        "'": '&#x27;',
        '"': '&quot;',
        '&': '&amp;'
      }
      return entityMap[char] || char
    })
  }
}
```

## Input Validation & Sanitization

### Schema Validation

Use comprehensive validation schemas:

```typescript
// ✅ Input validation with Zod
import { z } from 'zod'

export const CreateUserSchema = z.object({
  email: z.string()
    .email('Invalid email format')
    .max(255, 'Email too long'),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, 'Password must contain uppercase, lowercase, and numeric characters'),
  firstName: z.string()
    .min(1, 'First name required')
    .max(100, 'First name too long')
    .regex(/^[a-zA-Z\s'-]+$/, 'Invalid characters in first name'),
  lastName: z.string()
    .min(1, 'Last name required')
    .max(100, 'Last name too long')
    .regex(/^[a-zA-Z\s'-]+$/, 'Invalid characters in last name'),
  dateOfBirth: z.string()
    .refine((date) => {
      const parsed = new Date(date)
      const age = new Date().getFullYear() - parsed.getFullYear()
      return age >= 13 && age <= 120
    }, 'Age must be between 13 and 120')
})

export type CreateUserDto = z.infer<typeof CreateUserSchema>
```

### API Validation Middleware

Validate requests at the API boundary:

```typescript
// ✅ Express validation middleware
import { Request, Response, NextFunction } from 'express'
import { ZodError } from 'zod'

export function validateRequest(schema: z.ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      req.body = schema.parse(req.body)
      next()
    } catch (error) {
      if (error instanceof ZodError) {
        res.status(400).json({
          error: 'Validation failed',
          details: error.errors.map(err => ({
            field: err.path.join('.'),
            message: err.message
          }))
        })
      } else {
        next(error)
      }
    }
  }
}

// Usage
app.post('/users', validateRequest(CreateUserSchema), createUserHandler)
```

## Secure Coding Practices

### Avoiding Common Vulnerabilities

#### SQL Injection Prevention
```typescript
// ✅ Parameterized queries
import { sql } from 'slonik'

export class UserRepository {
  async findByEmail(email: string): Promise<User | null> {
    const result = await this.db.query(sql`
      SELECT * FROM users
      WHERE email = ${email}
      LIMIT 1
    `)

    return result.rows[0] || null
  }
}
```

#### XSS Prevention
```typescript
// ✅ XSS-safe rendering
import DOMPurify from 'dompurify'

export function renderUserComment(comment: string): string {
  const sanitized = DOMPurify.sanitize(comment, {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'a'],
    ALLOWED_ATTR: ['href']
  })

  return `<div class="comment">${sanitized}</div>`
}
```

#### CSRF Protection
```typescript
// ✅ CSRF tokens
import csrf from 'csurf'

const csrfProtection = csrf({
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict'
  }
})

app.use(csrfProtection)

// Include CSRF token in forms
app.get('/form', (req, res) => {
  res.render('form', { csrfToken: req.csrfToken() })
})
```

### Secure Headers

Implement security headers:

```typescript
// ✅ Security headers middleware
import helmet from 'helmet'

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}))
```

## Infrastructure Security

### Container Security

Secure Docker configurations:

```dockerfile
# ✅ Secure Dockerfile
FROM node:18-alpine

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Install dependencies first (for better caching)
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code
COPY --chown=nextjs:nodejs . .

# Switch to non-root user
USER nextjs

EXPOSE 3000

CMD ["npm", "start"]
```

### Environment Configuration

Secure environment variable handling:

```typescript
// ✅ Secure environment configuration
import { config } from 'dotenv'
import { z } from 'zod'

config()

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']),
  PORT: z.string().transform(Number).default(3000),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32, 'JWT secret must be at least 32 characters'),
  REDIS_URL: z.string().url().optional(),
  CORS_ORIGINS: z.string().transform(s => s.split(',')),
})

export const env = envSchema.parse(process.env)

// Validate required secrets exist
if (!env.JWT_SECRET) {
  throw new Error('JWT_SECRET environment variable is required')
}
```

## Compliance & Auditing

### Logging Security Events

Implement comprehensive security logging:

```typescript
// ✅ Security event logging
import winston from 'winston'

export class SecurityLogger {
  private logger: winston.Logger

  constructor() {
    this.logger = winston.createLogger({
      level: 'info',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      ),
      transports: [
        new winston.transports.File({ filename: 'security.log' }),
        new winston.transports.Console({
          format: winston.format.simple()
        })
      ]
    })
  }

  logAuthAttempt(email: string, success: boolean, ip: string): void {
    this.logger.info('Authentication attempt', {
      event: 'auth_attempt',
      email,
      success,
      ip,
      timestamp: new Date().toISOString()
    })
  }

  logSuspiciousActivity(userId: string, action: string, details: any): void {
    this.logger.warn('Suspicious activity detected', {
      event: 'suspicious_activity',
      userId,
      action,
      details,
      timestamp: new Date().toISOString()
    })
  }
}
```

### Audit Trails

Maintain audit logs for sensitive operations:

```typescript
// ✅ Audit trail implementation
export interface AuditEvent {
  id: string
  userId: string
  action: string
  resource: string
  resourceId?: string
  timestamp: Date
  ipAddress: string
  userAgent: string
  changes?: Record<string, any>
}

export class AuditService {
  async logEvent(event: Omit<AuditEvent, 'id' | 'timestamp'>): Promise<void> {
    const auditEvent: AuditEvent = {
      ...event,
      id: crypto.randomUUID(),
      timestamp: new Date()
    }

    // Store in secure audit database
    await this.auditRepository.save(auditEvent)

    // Log to security monitoring system
    this.securityLogger.logAuditEvent(auditEvent)
  }
}

// Usage
await auditService.logEvent({
  userId: req.user.id,
  action: 'user_deleted',
  resource: 'user',
  resourceId: userId,
  ipAddress: req.ip,
  userAgent: req.get('User-Agent'),
  changes: { deletedAt: new Date() }
})
```

### Compliance Standards

Follow industry standards:

- **OWASP Top 10**: Address all critical web application security risks
- **GDPR**: Implement data protection and privacy controls
- **SOC 2**: Maintain security, availability, and confidentiality controls
- **ISO 27001**: Follow information security management standards

### Regular Security Assessments

Implement security testing practices:

- **SAST (Static Application Security Testing)**: Automated code analysis
- **DAST (Dynamic Application Security Testing)**: Runtime vulnerability scanning
- **Dependency Scanning**: Regular checks for vulnerable packages
- **Penetration Testing**: Periodic security assessments

```yaml
# .github/workflows/security.yml
name: Security Checks
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: github/super-linter/slim@v4
        env:
          DEFAULT_BRANCH: main
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - run: npm audit --audit-level high
      - uses: securecodewarrior/github-action-gosec@master
        with:
          args: './...'
```

These security standards provide a comprehensive framework for building secure applications. Regular reviews and updates ensure continued protection against evolving threats.