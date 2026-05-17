---
name: aos-audit
description: Security audit that checks code against ArchitectOS security rules — auth, input validation, secrets, SQL injection, IDOR, XSS, and more. Reports HIGH/MEDIUM/LOW findings with risk descriptions and fixes. Use when user asks for a security review, security audit, or to check for vulnerabilities. Always trigger before PRs that touch auth, payments, or file uploads.
---

# /aos-audit

Select the files to audit, then run `/aos-audit`.

For targeted audits: `/aos-audit auth` · `/aos-audit uploads` · `/aos-audit payments`

## What gets checked

### Input validation
- [ ] All inputs validated at the API boundary with Zod / class-validator / Pydantic
- [ ] File uploads validated by content (not extension)
- [ ] No user input passed to SQL, shell commands, or file paths without validation

### SQL and data access
- [ ] Parameterized queries everywhere — no string concatenation
- [ ] No `SELECT *` returning excess columns
- [ ] Multi-table mutations in transactions

### Authentication
- [ ] JWT access tokens expire ≤ 15 minutes
- [ ] Refresh tokens rotated on every use and stored server-side
- [ ] Auth endpoints rate-limited
- [ ] Constant-time comparison used for secrets and tokens
- [ ] Auth events logged (success and failure, with IP)

### Authorization
- [ ] Every non-public endpoint has an auth guard
- [ ] Resource ownership verified before read or mutation (IDOR check)
- [ ] Default is DENY — explicit grants required

### Secrets
- [ ] No hardcoded secrets, keys, or passwords in source
- [ ] No secrets in log output
- [ ] Required env vars validated and present at startup

### Transport and headers
- [ ] HTTPS enforced in production with redirect
- [ ] HSTS, CSP, X-Frame-Options, X-Content-Type-Options set
- [ ] CORS restricted to known origins

### Sensitive data handling
- [ ] Password hashes never appear in API responses
- [ ] PII excluded from logs
- [ ] Tokens stored in `httpOnly` cookies — not `localStorage`

### File uploads
- [ ] MIME type checked by reading file bytes, not trusting extension
- [ ] File size limit enforced server-side
- [ ] Files stored in object storage — not the app filesystem

## Output format

```
[HIGH] Authorization — IDOR on GET /orders/:id
File: src/orders/orders.controller.ts:28
Risk: any authenticated user can read any order by guessing its ID
Fix:
  const order = await this.orders.findById(id)
  if (order.userId !== req.user.id) throw new ForbiddenException()

[MEDIUM] Authentication — refresh token not rotated
File: src/auth/auth.service.ts:67
Risk: stolen refresh token is valid indefinitely
Fix: delete old token and issue new one on every refresh call

Summary: 1 HIGH · 1 MEDIUM · 14 PASS
```

## Detailed rules with code examples

See [REFERENCE.md](REFERENCE.md)
