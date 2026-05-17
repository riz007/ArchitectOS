# Security Policy

## Reporting a Vulnerability

If you find a security vulnerability in ArchitectOS content — such as an insecure code example, a missing security control in a standard, or a pattern that could lead users to write vulnerable code — please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

### How to report

Open a [private GitHub security advisory](https://github.com/riz007/architect-os/security/advisories/new)

Include:
- A description of the vulnerability
- Which file(s) and section(s) are affected
- A proof-of-concept showing how the insecure pattern leads to a vulnerability
- Your suggested fix or correction

### Response timeline

| Step | Target |
|---|---|
| Acknowledgement | Within 48 hours |
| Initial assessment | Within 5 business days |
| Fix published | Within 14 days for critical issues |

## Scope

This repository contains documentation, code examples, configuration templates, and CLI scripts. Security concerns include:

- **Insecure code examples** — examples that demonstrate vulnerable patterns (SQL injection, XSS, hardcoded secrets, IDOR, etc.)
- **Missing security controls** — standards or playbooks that omit required security controls
- **Vulnerable scaffold dependencies** — dependencies in scaffold `package.json` or `requirements.txt` with known CVEs
- **Insecure CLI scripts** — shell scripts in `tools/` that are vulnerable to injection or path traversal

Out of scope:

- Theoretical or highly speculative issues with no demonstrated impact
- Issues in third-party dependencies that have upstream fixes and are not used in scaffolds
- Missing features that are not security-related

## Security Standards in This Repository

ArchitectOS enforces the following security standards in all generated code and examples:

- OWASP Top 10 compliance
- JWT best practices (short-lived access tokens, refresh token rotation)
- Input validation at every system boundary
- Parameterized queries for all database access
- Secret management via environment variables
- Authorization checks on every state-changing endpoint
- Security headers (CSP, HSTS, X-Frame-Options)
- Rate limiting on authentication endpoints

See [standards/security/README.md](standards/security/README.md) and [rules/security/README.md](rules/security/README.md) for details.
