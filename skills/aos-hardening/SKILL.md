---
name: aos-hardening
description: Apply secure-by-default patterns whenever touching authentication, authorization, user input, database queries, file uploads, secrets, tokens, sessions, or HTTP responses. Use proactively while writing or reviewing such code — not only when asked for a security review. Catches IDOR, injection, secret leakage, missing validation, and unsafe token storage before they ship.
---

# Security hardening

This is a model-invoked discipline. When code touches a sensitive surface, apply these
defaults as you write it. They are self-contained; the repo need not be present.

## Authentication & authorization

- Every state-changing or sensitive route has an auth guard. No "we'll add it later."
- **Verify resource ownership** before any read or mutation — fetch by `(id, ownerId)`,
  not just `id`. This is the #1 source of IDOR bugs.
- Authorization is enforced server-side in the service layer, never only in the UI.

## Input validation

- Validate and parse every external input at the boundary (Zod / class-validator /
  Pydantic). Reject unknown fields; don't trust client-supplied IDs or roles.
- Validate type, range, length, and format — not just presence.

## Injection & queries

- Parameterised queries / ORM bindings only. Never concatenate user input into SQL,
  shell commands, or file paths.
- Escape or sanitize anything rendered into HTML; rely on framework auto-escaping.

## Secrets & tokens

- No hardcoded secrets, API keys, or tokens — read from env / secret manager.
- Auth tokens in `httpOnly`, `Secure`, `SameSite` cookies — **never** `localStorage`.
- Strip sensitive fields (password hashes, internal flags, other users' data) from every
  response. Return a DTO, not the entity.

## File uploads

- Validate content type and size; never trust the filename or extension.
- Store outside the web root; generate server-side names; scan if untrusted.

## Responses & headers

- Set security headers (CSP, HSTS, `X-Content-Type-Options`, frame options).
- Don't leak stack traces or internal messages to clients — log them, return a safe error
  code + message.

## Quick self-check before finishing

- Could another user pass an `id` and read/modify data that isn't theirs? (IDOR)
- Is every input validated and every output a DTO?
- Did any secret, token, or hash end up in code, logs, or a response?

For a full, on-demand audit (auth, IDOR, secrets, uploads, payments) use `/aos-audit`.
