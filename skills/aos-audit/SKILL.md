---
name: aos-audit
description: Security audit that checks code against ArchitectOS security rules — auth, input validation, secrets, SQL injection, IDOR, CSRF, XSS, session management, dependency vulnerabilities, and more. Reports HIGH/MEDIUM/LOW findings with risk descriptions and concrete fixes. Use when user asks for a security review, security audit, or to check for vulnerabilities. Always trigger before PRs that touch auth, payments, uploads, or admin functionality.
---

# /aos-audit

Select the files to audit, then run `/aos-audit`.

For targeted audits: `/aos-audit auth` · `/aos-audit uploads` · `/aos-audit payments` · `/aos-audit admin`

---

## What gets checked

### Input validation
- [ ] All inputs validated at the API boundary with Zod / class-validator / Pydantic
- [ ] File uploads validated by file content (magic bytes), not extension
- [ ] No user input passed to SQL, shell commands, eval, or file paths without sanitisation
- [ ] HTML sanitised with an allowlist before storage or rendering (prevents stored XSS)
- [ ] Redirect destinations validated against an allowlist (prevents open redirects)

### SQL and data access
- [ ] Parameterised queries everywhere — no string concatenation
- [ ] No `SELECT *` returning excess columns
- [ ] Multi-table mutations wrapped in transactions
- [ ] No raw query strings built from user input in ORMs

### Authentication
- [ ] JWT access tokens expire ≤ 15 minutes
- [ ] Refresh tokens rotated on every use and stored server-side
- [ ] Auth endpoints rate-limited (max 10 attempts / 15 min per IP)
- [ ] Constant-time comparison used for tokens, HMAC signatures, and secrets
- [ ] Auth events logged — success and failure, with timestamp and IP
- [ ] Account lockout or CAPTCHA after repeated failures

### Session management
- [ ] Sessions invalidated on logout — not just the client cookie deleted
- [ ] Session IDs regenerated after privilege escalation (e.g. login, role change)
- [ ] Session cookies: `HttpOnly`, `Secure`, `SameSite=Strict` or `Lax`
- [ ] No session data stored in `localStorage` or `sessionStorage`

### Authorization
- [ ] Every non-public endpoint has an auth guard
- [ ] Resource ownership verified before read or mutation (IDOR check)
- [ ] Default is DENY — explicit grants required, never permissive defaults
- [ ] Admin-only operations gated by a role check, not just authentication
- [ ] Horizontal privilege escalation checked (user A cannot act as user B)

### CSRF protection
- [ ] State-changing requests (POST/PUT/PATCH/DELETE) use CSRF tokens or `SameSite` cookies
- [ ] API endpoints that accept `application/json` only reject `text/plain` and form bodies
- [ ] `Origin` / `Referer` headers validated on sensitive state-changing endpoints where tokens are impractical

### Secrets management
- [ ] No hardcoded secrets, keys, or passwords in source code
- [ ] No secrets in log output or error messages returned to clients
- [ ] Required env vars validated at startup — app fails fast if missing
- [ ] Secret rotation possible without a code deploy (stored externally)

### Transport and headers
- [ ] HTTPS enforced in production with HTTP → HTTPS redirect
- [ ] HSTS header with `max-age ≥ 31536000`, `includeSubDomains`, `preload`
- [ ] Content-Security-Policy blocks inline scripts and untrusted origins
- [ ] `X-Frame-Options: DENY` or `frame-ancestors 'none'` in CSP
- [ ] `X-Content-Type-Options: nosniff`
- [ ] CORS restricted to known, explicitly listed origins
- [ ] Sensitive API responses include `Cache-Control: no-store`

### Sensitive data handling
- [ ] Password hashes never appear in API responses or logs
- [ ] PII excluded from logs (emails, phone numbers, addresses)
- [ ] Tokens stored in `httpOnly` cookies — not `localStorage`
- [ ] PII encrypted at rest for highly sensitive fields (SSN, payment data)

### File uploads
- [ ] MIME type checked by reading file bytes, not trusting `Content-Type` or extension
- [ ] File size limit enforced server-side (not just client-side)
- [ ] Uploaded filenames sanitised before use — no path traversal
- [ ] Files stored in object storage — not the app filesystem
- [ ] Virus/malware scanning for user-uploaded content in sensitive contexts

### Dependency vulnerabilities
- [ ] `npm audit` / `pip-audit` / `trivy` shows no HIGH or CRITICAL vulnerabilities
- [ ] Direct dependencies are up-to-date within the current major version
- [ ] No dependencies abandoned > 2 years without a maintained fork

---

## Output format

```
[HIGH] Authorization — IDOR on GET /orders/:id
File: src/orders/orders.controller.ts:28
Risk: any authenticated user can read any order by guessing its ID
Fix:
  const order = await this.orders.findById(id)
  if (!order) throw new NotFoundException()
  if (order.userId !== req.user.id) throw new ForbiddenException()

[HIGH] CSRF — POST /profile/update accepts form body without CSRF protection
File: src/profile/profile.controller.ts:45
Risk: attacker can trick a logged-in user's browser into submitting forged requests
Fix: add CSRF token validation, or ensure cookie is SameSite=Strict and Content-Type is application/json only

[MEDIUM] Authentication — refresh token not rotated on use
File: src/auth/auth.service.ts:67
Risk: a stolen refresh token is valid indefinitely
Fix: delete old token and issue a new one on every refresh call

[LOW] Headers — X-Content-Type-Options not set
File: src/main.ts
Risk: browser may MIME-sniff responses and execute non-script content as scripts
Fix: app.use(helmet()) — or helmet.noSniff() explicitly

Summary: 2 HIGH · 1 MEDIUM · 1 LOW · 12 PASS
```

---

## Detailed rules with code examples

See [REFERENCE.md](REFERENCE.md)
